import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                helpSection(title: "一覧画面", icon: "list.bullet", items: [
                    "列のヘッダーをクリックで並べ替え",
                    "行をダブルクリックで編集",
                    "右クリックで編集・除却・削除",
                    "経過年数が赤字 → 耐用年数を超過",
                    "行がグレー → 除却済み",
                ])
                helpSection(title: "ツールバー", icon: "toolbar", items: [
                    "👁 除却済みの表示/非表示を切り替え",
                    "＋ 新しい資産を登録",
                    "↓ CSV ファイルからデータを取り込み",
                    "↑ データを CSV ファイルとして出力",
                    "🗑 選択した資産を削除",
                ])
                helpSection(title: "CSV 取込", icon: "square.and.arrow.down", items: [
                    "フォーマット: 分類,製品,購入店,購入日,購入金額,耐用年数,備考",
                    "購入日: yyyy/MM/dd, yyyy-MM-dd, yyyy.MM.dd, yyyy年MM月dd日",
                    "1行目がヘッダーなら自動スキップ",
                    "既存データに追加（上書きではありません）",
                    "メニュー: ファイル → CSV 取込（⇧⌘I）",
                ])
                helpSection(title: "CSV 出力", icon: "square.and.arrow.up", items: [
                    "全データを CSV ファイルとして保存",
                    "出力ファイルはそのまま再取込が可能",
                    "メニュー: ファイル → CSV 出力（⇧⌘E）",
                ])
                helpSection(title: "ダッシュボード", icon: "chart.bar", items: [
                    "サマリーカード: 稼働中・除却済み・合計金額・超過数",
                    "年別購入推移: 購入年ごとの金額を棒グラフで表示",
                    "耐用年数消化率: 100% 超で赤表示（買い替え目安）",
                ])
                helpSection(title: "データ保存", icon: "externaldrive", items: [
                    "保存先: ~/Library/Application Support/HomeKeeper/",
                    "追加・編集・削除のたびに自動保存",
                    "バックアップは CSV 出力をご利用ください",
                ])
                Text("Home Keeper v1.0")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 8)
            }
            .padding(24)
        }
        .frame(width: 480, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 8) {
            if let icon = NSImage(named: "AppIcon") {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            Text("Home Keeper ヘルプ")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    private func helpSection(title: String, icon: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(item)
                            .font(.callout)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
