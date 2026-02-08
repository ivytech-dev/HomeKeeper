import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: AssetStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary Cards
                HStack(spacing: 16) {
                    SummaryCard(title: "稼働中", value: "\(store.activeAssets.count)", color: .blue)
                    SummaryCard(title: "除却済み", value: "\(store.retiredAssets.count)", color: .gray)
                    SummaryCard(title: "合計金額", value: formatCurrency(store.totalCost), color: .green)
                    SummaryCard(title: "耐用年数超過", value: "\(store.overUsefulLifeCount)", color: .red)
                }

                // Life Gauges
                GroupBox("耐用年数消化率") {
                    VStack(spacing: 12) {
                        ForEach(store.activeAssets.prefix(10)) { asset in
                            HStack {
                                Text(asset.name)
                                    .font(.caption)
                                    .frame(width: 120, alignment: .trailing)
                                    .lineLimit(1)

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))

                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(gaugeColor(for: asset.usefulLifeProgress))
                                            .frame(width: geo.size.width * min(asset.usefulLifeProgress, 1.0))
                                    }
                                }
                                .frame(height: 14)

                                Text(String(format: "%.0f%%", asset.usefulLifeProgress * 100))
                                    .font(.caption2)
                                    .frame(width: 40)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(24)
        }
        .navigationTitle("ダッシュボード")
    }

    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "¥0"
    }

    private func gaugeColor(for progress: Double) -> Color {
        if progress >= 1.0 { return .red }
        if progress >= 0.7 { return .orange }
        return .green
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
