import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var store: AssetStore

    private var activeAssets: [Asset] {
        store.assets.filter { !$0.disposed }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                summaryCards
                purchaseByYearCard
                usefulLifeProgressCard
            }
            .padding(24)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("ダッシュボード")
        .frame(minWidth: 700, minHeight: 400)
    }

    // MARK: - サマリーカード

    @ViewBuilder
    private var summaryCards: some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "稼働中",
                value: "\(activeAssets.count)",
                unit: "件",
                icon: "checkmark.circle.fill",
                color: .green
            )
            SummaryCard(
                title: "除却済み",
                value: "\(store.assets.count - activeAssets.count)",
                unit: "件",
                icon: "archivebox.fill",
                color: .secondary
            )
            SummaryCard(
                title: "稼働中 合計金額",
                value: "¥\(activeAssets.reduce(0) { $0 + $1.purchasePrice }.formatted())",
                unit: "",
                icon: "yensign.circle.fill",
                color: .blue
            )
            let overdueCount = activeAssets.filter {
                $0.usefulLifeYears > 0 && $0.elapsedYears > Double($0.usefulLifeYears)
            }.count
            SummaryCard(
                title: "耐用年数 超過",
                value: "\(overdueCount)",
                unit: "件",
                icon: "exclamationmark.triangle.fill",
                color: overdueCount > 0 ? .red : .green
            )
        }
    }

    // MARK: - 年別 購入推移

    private struct YearlyTotal: Identifiable {
        let id: Int
        let total: Int
    }

    private var yearlyData: [YearlyTotal] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: activeAssets) { cal.component(.year, from: $0.purchaseDate) }
        return grouped
            .map { YearlyTotal(id: $0.key, total: $0.value.reduce(0) { $0 + $1.purchasePrice }) }
            .sorted { $0.id < $1.id }
    }

    @ViewBuilder
    private var purchaseByYearCard: some View {
        ChartCard(title: "年別 購入推移", subtitle: "稼働中の資産を購入年ごとに集計") {
            if yearlyData.isEmpty {
                emptyState
            } else {
                Chart(yearlyData) { item in
                    BarMark(
                        x: .value("年", String(item.id)),
                        y: .value("金額", item.total)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue, .blue.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                    .annotation(position: .top, spacing: 4) {
                        Text("¥\(item.total.formatted())")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(.quaternary)
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text(Self.compactYen(v))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartPlotStyle { plot in
                    plot.frame(height: 220)
                }
            }
        }
    }

    // MARK: - 耐用年数 消化率

    private struct LifeProgress: Identifiable {
        let id: UUID
        let name: String
        let category: String
        let percent: Double
        let overdue: Bool
    }

    private var lifeProgressData: [LifeProgress] {
        activeAssets
            .filter { $0.usefulLifeYears > 0 }
            .map { asset in
                let pct = asset.elapsedYears / Double(asset.usefulLifeYears) * 100
                return LifeProgress(
                    id: asset.id,
                    name: asset.productName,
                    category: asset.category,
                    percent: pct,
                    overdue: pct > 100
                )
            }
            .sorted { $0.percent > $1.percent }
    }

    @ViewBuilder
    private var usefulLifeProgressCard: some View {
        ChartCard(title: "耐用年数 消化率", subtitle: "100% を超えると買い替え検討の目安") {
            if lifeProgressData.isEmpty {
                emptyState
            } else {
                Chart {
                    RuleMark(x: .value("基準", 100))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                        .foregroundStyle(.red.opacity(0.5))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("耐用年数")
                                .font(.caption2)
                                .foregroundStyle(.red.opacity(0.7))
                                .padding(.trailing, 2)
                        }

                    ForEach(lifeProgressData) { item in
                        BarMark(
                            x: .value("消化率", min(item.percent, 200)),
                            y: .value("製品", item.name)
                        )
                        .foregroundStyle(barGradient(for: item.percent))
                        .cornerRadius(4)
                        .annotation(position: .trailing, spacing: 6) {
                            Text(String(format: "%.0f%%", item.percent))
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(item.overdue ? .red : .secondary)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [0, 50, 100, 150, 200]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(.quaternary)
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v))%")
                                    .font(.caption)
                                    .foregroundStyle(v >= 100 ? .red.opacity(0.8) : .secondary)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
                .chartXScale(domain: 0...200)
                .chartPlotStyle { plot in
                    plot.frame(height: max(CGFloat(lifeProgressData.count) * 36, 120))
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundStyle(.quaternary)
            Text("データがありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
    }

    private func barGradient(for percent: Double) -> LinearGradient {
        if percent > 100 {
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        } else if percent > 75 {
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        }
    }

    private static func compactYen(_ value: Int) -> String {
        if value >= 10_000 {
            return "¥\(value / 10_000)万"
        }
        return "¥\(value.formatted())"
    }
}

// MARK: - サマリーカードコンポーネント

private struct SummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .monospacedDigit()
                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

// MARK: - チャートカードコンポーネント

private struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}
