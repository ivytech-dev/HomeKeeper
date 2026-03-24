# Dify × データ分析 調査レポート

## 概要

Difyを活用したデータ分析の実例・ユースケースを調査し、各事例の完成度を独自評価した。

---

## 事例一覧と参照リンク

| # | 事例名 | 参照URL | 評価 |
|---|--------|---------|------|
| 1 | 売上分析システム（S3 + Athena + Dify） | https://cloudassist.jp/knowledge/dify-intro/case-rag02/ | ★★★★☆ |
| 2 | CSVデータ分析ワークフロー | https://x.com/gijigae/status/1793293475737391120 | ★★★☆☆ |
| 3 | 顧客アンケート分析の自動化 | https://note.com/conaxam/n/n8e9d1993263e | ★★★★☆ |
| 4 | ドキュメント→CSV→ECharts可視化 | https://qiita.com/engchina/items/10161b33fd1c53056551 | ★★★☆☆ |
| 5 | Marketplace「data analysis」プラグイン | https://marketplace.dify.ai/plugins/digitforce/data_analysis | ★★★☆☆ |
| 6 | Awesome-Dify-Workflow テンプレート集 | https://github.com/svcvit/Awesome-Dify-Workflow/blob/main/README_EN.md | ★★★★☆ |
| 7 | SQL生成チャットBot（セルフレビュー付き） | https://future-architect.github.io/articles/20240404a/ | ★★★★☆ |
| 8 | Deep Research（自動調査・レポート生成） | https://dify.ai/blog/deep-research-workflow-in-dify-a-step-by-step-guide | ★★★★★ |

---

## 各事例の詳細と評価

### 1. 売上分析システム（S3 + Athena + Dify）

- **URL**: https://cloudassist.jp/knowledge/dify-intro/case-rag02/
- **概要**: 自然言語で「先月の売上は？」と質問→LLMがSQL自動生成→Athenaで実行→ビジネス洞察を返す。半日でPoC構築。
- **構成**: Amazon S3（CSVデータ） → Difyチャット → LLM（質問明確化+SQL生成） → API Gateway + Lambda → Athena → 回答生成
- **評価: ★★★★☆（4/5）**
  - 構成が明確でAWSとの連携も実用的
  - ただしAthenaへの接続はDify外（Lambda + API Gateway）に依存しており「Difyだけで完結」ではない
  - SQL生成の精度はLLM依存。複雑なクエリは不安定になりうる
  - PoCとしては優秀。本番運用には追加の検証・ガードレールが必要

### 2. CSVデータ分析ワークフロー（コードブロック実装）

- **URL**: https://x.com/gijigae/status/1793293475737391120
- **概要**: CSVファイルのURLを渡すとデータを自動分析するワークフロー。Difyのコードブロックで実装。DSLファイルをダウンロード可能。
- **評価: ★★★☆☆（3/5）**
  - Difyのコードブロックは**pandas等の外部ライブラリが使えない**のが致命的
  - 標準ライブラリだけでのCSV処理は限界がある
  - 簡単な集計・フィルタリングなら可能だが、本格的なデータ分析には力不足

### 3. 顧客アンケート分析の自動化

- **URL**: https://note.com/conaxam/n/n8e9d1993263e
- **概要**: CSVアンケートをイテレーションで行ごとにLLM処理し、ポジネガ分析→表形式レポート出力。
- **処理フロー**: テキスト抽出（CSV→プレーンテキスト）→ コードブロック（行分割）→ イテレーション（各行処理）→ LLM（ポジネガ判定）→ 表形式レポート
- **評価: ★★★★☆（4/5）**
  - テキスト分析はLLMの得意領域なので相性が良い
  - イテレーション+LLMの組み合わせは実用的
  - 大量データ（数千行）になるとLLM呼び出し回数とコストが爆発する点に注意
  - 数百行規模なら現実的

### 4. ドキュメント→CSV→ECharts可視化

- **URL**: https://qiita.com/engchina/items/10161b33fd1c53056551
- **概要**: テキスト抽出→CSV変換→EChartsでグラフ描画まで一気通貫のワークフロー。
- **評価: ★★★☆☆（3/5）**
  - 可視化まで一気に行けるのは魅力
  - EChartsの設定をLLMに生成させるため、グラフの品質が安定しない
  - シンプルな棒グラフ・折れ線なら問題ないが、複雑な可視化は期待しないほうがいい

### 5. Dify Marketplace「data analysis」プラグイン（digitforce製）

- **URL**: https://marketplace.dify.ai/plugins/digitforce/data_analysis
- **概要**: Text2SQL / Text2Data / Text2Code対応。Excel/CSVアップロードでクエリ・可視化・レポート生成。マルチシートクエリ、クロスシート分析をサポート。
- **裏側**: ChartGen AIのAPIを利用。クレジット制（月200無料、1回20消費=月10回）。
- **評価: ★★★☆☆（3/5）**
  - 機能は豊富だが、実質ChartGen AIのラッパー
  - 無料枠が月10回と少なく、業務利用には課金が前提
  - ユーザーレビューがほぼなく、成熟度は未知数

### 6. Awesome-Dify-Workflow（ワークフローテンプレート集）

- **URL**: https://github.com/svcvit/Awesome-Dify-Workflow/blob/main/README_EN.md
- **概要**: データ分析含む各種ワークフローのDSLテンプレートを無料公開。Difyにインポートしてすぐ使える。CSV分析、チャート生成、サンドボックスでのコード実行例あり。
- **評価: ★★★★☆（4/5）**
  - DSLファイルをそのままインポートできるので学習コストが低い
  - あくまでスターターキット。そのまま本番投入というよりカスタマイズ前提
  - コミュニティ主導で継続的に更新されている点は好材料

### 7. SQL生成チャットBot（セルフレビュー付き）

- **URL**: https://future-architect.github.io/articles/20240404a/
- **概要**: LLMがSQL生成→実行→エラー時は自動でやり直し（セルフレビュー）。DifyのPostgreSQLに直接接続。生成SQLのログを記録して後から分析も可能。
- **評価: ★★★★☆（4/5）**
  - セルフレビュー（生成SQLの自動検証・再試行）を入れているのが実践的
  - エラーハンドリングまで考慮されている点が他の事例より一段上
  - ただしDB直接接続はセキュリティ面で要注意（本番DBには使わないこと）

### 8. Deep Research（自動調査・レポート生成）

- **URL**: https://dify.ai/blog/deep-research-workflow-in-dify-a-step-by-step-guide
- **概要**: ループ変数+構造化出力+エージェントノードを組み合わせ、多段階の検索・要約を自動化するワークフロー。
- **評価: ★★★★★（5/5）**
  - Difyの強みが最も活きるユースケース
  - ワークフローのループ・分岐・エージェントノードをフル活用
  - データ「分析」というより「調査・整理」だが、完成度が高い
  - 公式ブログで手順も詳しく、再現性が高い

---

## 追加の参考リンク

| リソース | URL | 内容 |
|----------|-----|------|
| Dify GitHub Discussion #12941 | https://github.com/langgenius/dify/discussions/12941 | MySQL + Difyでデータ分析ワークフローを作る議論 |
| CSVリスト自動処理ワークフロー | https://note.com/settie/n/n237d5083c8bc | CSVアップロード→一括ワークフロー処理 |
| PDF→CSV→Google Drive自動化 | https://www.ai-native.jp/blog/dify-pdf-csv-google-automation | GAS + Dify APIでPDF解析→CSV化 |
| Excelデータの自動QAナレッジ化 | https://zenn.dev/upgradetech/articles/d3f46c2f0ffdfe | ナレッジパイプラインでExcel→QA形式変換 |
| Googleスプレッドシート連携 | https://www.ai-native.jp/blog/dify-sheets-integration | 営業データをDifyで自動分析→シートに書き戻し |
| DifyWorkFlowGenerator | https://github.com/Tomatio13/DifyWorkFlowGenerator | プロンプトからDify DSLを自動生成 |
| Dify連載サンプルコード | https://github.com/kenzauros/2026-dify2-sample | Webページ要約等のサンプルDSL |
| Dify公式 - 活用事例 | https://docs.dify.ai/ja-jp/learn-more/use-cases | 公式ユースケース集 |

---

## 総合評価

| 分析カテゴリ | 評価 | コメント |
|---|---|---|
| テキスト分析（感情分析・要約） | ★★★★★ | LLMの得意領域。Difyとの相性最高 |
| 自然言語→SQL→BI的分析 | ★★★★☆ | 実用的だがDB接続部分は外部依存が多い |
| CSV/Excel数値分析 | ★★☆☆☆ | pandasが使えないのが痛い。簡単な集計のみ |
| 可視化 | ★★★☆☆ | ECharts生成は可能だが安定性に欠ける |
| 調査・レポート生成 | ★★★★★ | Difyの最も得意な領域 |

### 結論

Difyはデータ「分析」ツールというより、**LLMを使ったテキスト処理・調査・レポート生成のオーケストレーター**として見るのが正しい。ガチの数値分析（pandas, numpy的な処理）を期待すると物足りない。「非エンジニアが自然言語でデータに触れるUI」としては価値があるが、裏側のデータ処理基盤は別途必要。
