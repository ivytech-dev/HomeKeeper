import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var store: AssetStore

    private var activeAssets: [Asset] {
        store.assets.filter { !$0.disposed }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                purchaseByYearChart
                usefulLifeProgressChart
            }
            .padding()
        }
        .navigationTitle("ダッシュボード")
        .frame(minWidth: 700, minHeight: 400)
    }

    // MARK: - 年別 購入推移

    private struct YearlyTotal: Identifiable {
        let id: Int // year
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
    private var purchaseByYearChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("年別 購入推移（稼働中のみ）")
                .font(.headline)

            if yearlyData.isEmpty {
                Text("データがありません").foregroundColor(.secondary).frame(height: 200)
            } else {
                Chart(yearlyData) { item in
                    BarMark(
                        x: .value("年", String(item.id)),
                        y: .value("金額", item.total)
                    )
                    .foregroundStyle(.blue.gradient)
                    .annotation(position: .top, alignment: .center) {
                        Text("¥\(item.total.formatted())")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("¥\(v.formatted())")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .frame(height: 250)
            }
        }
    }

    // MARK: - 耐用年数 消化率

    private struct LifeProgress: Identifiable {
        let id: UUID
        let name: String
        let percent: Double   // 0...∞ (100 = ちょうど耐用年数)
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
                    percent: pct,
                    overdue: pct > 100
                )
            }
            .sorted { $0.percent > $1.percent }
    }

    @ViewBuilder
    private var usefulLifeProgressChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("耐用年数 消化率（稼働中のみ）")
                .font(.headline)

            if lifeProgressData.isEmpty {
                Text("データがありません").foregroundColor(.secondary).frame(height: 200)
            } else {
                Chart(lifeProgressData) { item in
                    BarMark(
                        x: .value("消化率", min(item.percent, 200)),
                        y: .value("製品", item.name)
                    )
                    .foregroundStyle(item.overdue ? Color.red.gradient : Color.green.gradient)
                    .annotation(position: .trailing, alignment: .leading) {
                        Text(String(format: "%.0f%%", item.percent))
                            .font(.caption2)
                            .foregroundColor(item.overdue ? .red : .secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100, 150, 200]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v))%")
                                    .font(.caption)
                                    .foregroundColor(v > 100 ? .red : .primary)
                            }
                        }
                    }
                }
                .chartXScale(domain: 0...200)
                .chartPlotStyle { plot in
                    plot.overlay(alignment: .leading) {
                        GeometryReader { geo in
                            Rectangle()
                                .fill(Color.red.opacity(0.15))
                                .frame(width: geo.size.width * 0.5)
                                .offset(x: geo.size.width * 0.5)
                        }
                    }
                }
                .frame(height: max(CGFloat(lifeProgressData.count) * 32, 120))
            }
        }
    }
}
