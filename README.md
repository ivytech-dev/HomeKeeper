# HomeKeeper

HomeKeeperは、家電・耐久消費財の購入履歴・耐用年数・コストを美しいダッシュボードで一元管理するmacOSネイティブアプリです。

## 機能

- ダッシュボード - 資産状況をグラフで一目で把握
- 一覧管理 - 全資産を表形式で整理、ソート対応
- 20カテゴリ - 標準耐用年数を自動設定
- CSV入出力 - 4種の日付形式対応、Excel連携
- 除却管理 - 処分済み資産の表示/非表示切り替え
- 自動保存 - JSON形式で操作ごとに自動保存

## 動作環境

- macOS 13 Ventura 以降
- Apple Silicon / Intel 両対応
- SwiftUI Native

## インストール

1. [Releases](https://github.com/ivytech-dev/HomeKeeper/releases) から最新版をダウンロード
2. `HomeKeeper.app` を Applications フォルダにドラッグ&ドロップ
3. Launchpad または Spotlight (`Cmd + Space`) から起動

## 開発環境

- Xcode 15+
- macOS 13+
- Swift 5.9+

```bash
git clone https://github.com/ivytech-dev/HomeKeeper.git
cd HomeKeeper
open HomeKeeper.xcodeproj
```

## ブランチ戦略

| ブランチ | 用途 |
|---------|------|
| `main` | 本番リリース用 |
| `develop` | 開発統合ブランチ |
| `feature/*` | 機能開発用 |
| `fix/*` | バグ修正用 |

## ライセンス

MIT License - &copy; 2025 [Polaris Technologies](https://github.com/ivytech-dev)
