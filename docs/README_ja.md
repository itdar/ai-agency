🌐 [English](../README.md) | [한국어](README_ko.md) | [中文](README_zh.md) | [日本語](README_ja.md) | [Español](README_es.md) | [Português](README_pt.md)

<div align="center">

# ai-agency

**あなたの目標を中心に作られる、専属AIエージェンシー。**

プロジェクトのコンテキストを一度作れば、二度と説明する必要はありません。
開発、企画、ビジネス、デザイン — 専門エージェントが同じ知識を共有して協働します。
繰り返しのトークン浪費はなくなり、目標に向けた協業だけが残ります。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## ai-agencyとは？

AIエージェントはセッションが終わると全てを忘れます。毎回ファイルを読み直し、APIを再発見し、チームルールを学び直します。毎セッション、時間とお金が無駄になります。

**ai-agency**は組織の永続コンテキストを構築し、その上でAI専門家をオーケストレーションします：

1. **コンテキストは一度だけ、永遠に** — プロジェクトの知識レイヤーを一度だけ構築します。全てのエージェントが完全にブリーフィングされた状態で開始します — コードベース、規約、ビジネスルール、チーム構造。繰り返しのトークンコストも、ウォームアップ時間もありません。

2. **オーケストレーションされる専門家たち** — 1つのエージェントが1つのリポジトリだけを扱うのではありません。開発、企画、ビジネス、デザイン、QA、運用 — 各専門家が同じコンテキストを共有して協業します。PMエージェントがこれらを調整し、タスクを処理し、問題を解決し、組織全体で成果を生み出します。

単一サービスでも、企業全体のワークフローでも — ai-agencyは適切な専門家を適切なコンテキストとともにオーケストレーションします。

全てのAIツールで動作します：Claude Code、Codex、Cursor、Copilot、Gemini CLI、Windsurf、Aider。

<!-- TODO: 30秒デモGIF — ai-agency init → エージェントセッション起動 → コンテキストがロードされた状態でエージェントが即座に作業 -->

---

## インストール

### Homebrew（推奨）

```bash
brew install itdar/tap/ai-agency
```

### Homebrewなし

```bash
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global
```

### プロジェクト単位インストール

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash
```

---

## はじめに

### 1. プロジェクトの初期化

```bash
cd ~/my-project
ai-agency init
```

別のパスからも実行できます：`ai-agency init ~/my-project`

3つのことが自動的に行われます：
1. **スキャン** — ディレクトリ構造を探索し、各ディレクトリを分類します（backend、frontend、infra、business等）
2. **生成** — 各領域に `AGENTS.md` と `.ai-agents/` コンテキストを生成します
3. **検証** — 生成されたファイルの完全性を検査します

<!-- TODO: ai-agency init実行画面のスクリーンショット — AIツール/言語選択CUIが表示される画面 -->

AIツール（Claude Code、Codex、またはGemini）と言語を選択すると、AIがプロジェクトを分析してコンテキストを構築します。初回1回だけの設定です — 数分かかりますが、以降の全セッションで時間を節約します。

### 2. エージェントセッションの開始

```bash
ai-agency
```

これだけです。インタラクティブメニューからエージェントを選択すれば、すぐに作業を開始します。エージェントはすでにプロジェクトを理解しています。

<!-- TODO: ai-agencyインタラクティブCUIスクリーンショット — 矢印キーで操作するエージェントリスト、カラーエージェント -->

### 3. 日常的な使用

日常のワークフローは変わりません。AIツールを直接起動する代わりに `ai-agency` を実行するだけです。

```bash
ai-agency                     # インタラクティブにエージェントを選択
ai-agency --agent api         # APIエージェントに直接進入
```

上位エージェント（PM、Domain Coordinator）を選択すると、必要に応じてサブエージェントを自動的に呼び出して調整します — 自分で管理する必要はありません。

複数の独立したエージェントをtmux分割パネルで並行実行するには：

```bash
ai-agency --multi             # 並行実行するエージェントを選択
```

<!-- TODO: tmuxマルチエージェント分割パネルスクリーンショット — 2-3個のエージェントがカラーパネルボーダーとともに同時実行 -->

---

## なぜ必要か

### ai-agencyなし

毎セッションがゼロから始まります。AIがプロジェクトを把握するために時間（とトークン）を費やします：

- 「このフレームワークは何？」 — ファイル20個を読んでようやく把握
- 「APIエンドポイントは？」 — 全コントローラーをスキャン
- 「チーム規約は？」 — 知らないので間違って推測
- 「デプロイの承認は誰？」 — 知らないのでスキップ

> 研究（ETH Zurich, 2026）：既知のプロジェクトを再分析するAIエージェントは**トークンを20%多く消費**し、事前構築されたコンテキストを持つエージェントよりも**悪い結果**を出す。

### ai-agencyあり

AIが数秒で全てをロードし、即座に作業を開始します：

```
セッション開始
  → AGENTS.mdを読む            「私はorder-apiのバックエンド専門家です」
  → .ai-agents/context/をロード 「API、データモデル、チームルールを把握しています」
  → すぐに作業開始              探索フェーズ不要
```

<!-- TODO: Before/After比較画像 — 左側：AIがファイルを彷徨う様子、右側：コンテキストロード後にAIが即座に生産的に作業 -->

---

## 生成されるもの

`ai-agency init`を実行すると、3層のコンテキストが作成されます：

```
your-project/
├── AGENTS.md                    # 私は誰か？（役割、ルール、権限）
├── .ai-agents/
│   ├── context/                 # 私が知っていることは？（ドメイン知識）
│   │   ├── domain-overview.md   #   事業目的、ポリシー、制約
│   │   ├── api-spec.json        #   APIエンドポイントマップ
│   │   ├── data-model.md        #   エンティティと関係
│   │   └── ...                  #   （プロジェクトタイプに応じて生成）
│   ├── skills/                  # どう働くか？（ワークフロー標準）
│   │   ├── develop/SKILL.md     #   開発：分析 → 実装 → テスト → PR
│   │   └── review/SKILL.md      #   レビュー：セキュリティ、パフォーマンスチェックリスト
│   └── roles/                   # 役割別コンテキストロード戦略
│       ├── pm.md
│       └── backend.md
├── apps/
│   ├── api/AGENTS.md            # サービス別エージェント
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**推論できない情報だけが保存されます。** AIがコードを読めば分かること（「これはReactアプリだ」）は除外されます。推論できないこと（「squash mergeを使う」「デプロイ前にQA承認が必要」）だけが含まれます。

---

## プロジェクト構造例

ai-agencyはプロジェクトの形に適応します。`ai-agency init`を実行したディレクトリがPM（コーディネーター）になります。

### 単一プロダクト

```
my-app/               ← PMエージェント
├── api/              ← バックエンドエージェント
├── web/              ← フロントエンドエージェント
└── infra/            ← インフラエージェント
```

### プロダクト + ビジネスチーム

```
my-product/            ← PMエージェント
├── api/              ← バックエンドエージェント
├── web/              ← フロントエンドエージェント
├── business/         ← ビジネスアナリストエージェント
├── planning/         ← プランナーエージェント
└── infra/            ← インフラエージェント
```

コードだけではありません — ビジネス、企画、QA、運用など全ての領域に専門エージェントが配置されます。

### マルチドメインプラットフォーム

```
platform/              ← PMエージェント
├── commerce/         ← ドメインコーディネーター（自動検出）
│   ├── order-api/    ← バックエンドエージェント
│   └── storefront/   ← フロントエンドエージェント
├── social/           ← ドメインコーディネーター（自動検出）
│   ├── feed-api/     ← バックエンドエージェント
│   └── chat-api/     ← バックエンドエージェント
└── infra/            ← インフラエージェント
```

ドメインは自動検出されます — サブディレクトリ2つ以上がそれぞれビルドファイルを持っている場合、ドメイン境界として分類されます。

---

## チームモード

PMエージェントがサブエージェントを調整するか、複数のエージェントを並行実行できます。

### 調整チーム（Claude Code）

PMエージェントがClaude Codeのネイティブエージェントチーム機能で専門家にタスクを委任します：

```bash
ai-agency                     # メニューから "team" モードを選択
```

<!-- TODO: チームモード選択画面スクリーンショット — single/team/multiオプションが表示されるCUI -->

### 並行エージェント（全AIツール）

tmux分割パネルで複数のエージェントを同時実行します。ファイルベースの協業で調整されます：

```bash
ai-agency --multi             # エージェントを選択すると分割パネルで実行
```

エージェントは `.ai-agents/coordination/` を通じて調整します — 全てのAIツールで動作する共有タスクボードとメッセージログです。

<!-- TODO: tmuxマルチエージェントセッション + task-board.mdが見えるスクリーンショット -->

---

## コンテキストの最新維持

コンテキストファイルはAIセッション中に自動更新されます — 各AGENTS.mdにメンテナンストリガーが含まれており、エージェントがいつ何を更新すべきかを知っています。

セッション終了後、ai-agencyはコードが変更されたのにコンテキストが更新されていない場合に警告します：

```
[ai-agency] コード変更が検出されましたがコンテキストファイルが更新されていません。
  実行: ai-agency verify --staleness
```

手動で確認することもできます：

```bash
ai-agency verify              # 構造と完全性の検証
ai-agency verify --staleness  # コンテキストがコードと同期しているか確認
```

大きな変更後は、インクリメンタルモードで再initします — 新しいディレクトリに対してのみコンテキストを生成します：

```bash
ai-agency init                # プロンプトで "incremental" を選択
```

---

## 対応AIツール

ai-agencyはベンダー中立です。AGENTS.mdはどのツールでも動作し、必要なツールにはブートストラップファイルが自動生成されます。

| ツール | そのまま動作 | 自動ブートストラップ |
|---|---|---|
| **OpenAI Codex** | Yes | 不要 |
| **Claude Code** | Yes | `CLAUDE.md` 生成 |
| **Cursor** | ルール経由 | `.cursor/rules/` 生成 |
| **GitHub Copilot** | 指示経由 | `.github/copilot-instructions.md` 生成 |
| **Windsurf** | ルール経由 | `.windsurfrules` 生成 |
| **Aider** | 設定経由 | `.aider.conf.yml` 更新 |
| **Gemini CLI** | Yes | 不要 |

ブートストラップファイルは実際に使用しているツールに対してのみ生成されます。使用していないツールのファイルは作成しません。

---

## CLIリファレンス

```bash
# セットアップ
ai-agency init [path]           # プロジェクト初期化（スキャン、生成、検証）
ai-agency classify [path]       # 生成なしでディレクトリ分類をプレビュー

# 日常使用
ai-agency                       # インタラクティブエージェントランチャー
ai-agency --agent <keyword>     # 特定エージェントを直接起動
ai-agency --multi               # tmux分割パネルで並行実行
ai-agency --tool <claude|codex> # AIツールを指定
ai-agency --lang <code>         # UI言語設定 (en ko ja zh es fr de ru hi ar)

# プロジェクト管理
ai-agency register [path]       # プロジェクトを登録
ai-agency scan [dir]            # AGENTS.mdのあるプロジェクトを自動検出
ai-agency list                  # 登録済みプロジェクト一覧
ai-agency unregister [path]     # 登録解除

# メンテナンス
ai-agency verify [path]         # 生成ファイルの検証
ai-agency verify --staleness    # コンテキスト鮮度チェック
ai-agency clear [path]          # 全生成ファイルを削除
```

---

## 内部動作原理

興味のある方へ：

1. **classify-dirs.sh** — プロジェクトをスキャンし、19のルールをヒントとして提供します。AIがファイルの内容・構造・目的を分析して、各ディレクトリが独立したサブプロジェクトかどうかを最終判断します
2. **scaffold.sh** — 分類結果に基づいて、ルートおよび各サブプロジェクトに `.ai-agents/` ディレクトリ構造とプレースホルダーファイルを作成します
3. **setup.sh** — 選択したAIツールに `HOW_TO_AGENTS.md` を渡します — AIが7ステップの分析/生成プロセスを実行するメタ命令書です
4. **validate.sh** — 生成ファイルの構造的整合性を検査します（必須セクション、トークン制限、参照完全性）
5. **sync-ai-rules.sh** — AGENTS.mdを指すベンダー固有のブートストラップファイルを作成します
6. **ai-agency.sh** — インタラクティブなエージェント選択CUIとセッションライフサイクルを管理します。コンテキストチェックサム追跡とマルチエージェント調整を含みます

> **トークンについて：** 初回セットアップはプロジェクト全体を分析するため、数万トークンを消費する可能性があります。これは1回限りのコストで、以降のセッションでは事前構築されたコンテキストを即座にロードします。

---

## 参考資料

- [AGENTS.md Standard](https://agents.md/) — このプロジェクトが基づくベンダー中立エージェント命令標準
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — 「推論できないことだけを文書化せよ」
- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — コンテキスト設計のインスピレーション

---

## ライセンス

MIT

---

<p align="center">
  <sub>プロジェクトをAIに毎回説明し直すのをやめましょう。一度設定すれば、ずっと使えます。</sub>
</p>
