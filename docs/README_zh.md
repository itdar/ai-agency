🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md)

> ⚠️ 此翻译可能已过时。最新内容请参阅 [English README](../README.md) 或 [한국어](README_ko.md)。

<div align="center">

# ai-agency

**围绕你的目标打造的专属 AI 机构。**

项目上下文只需构建一次，无需再次解释。
开发、策划、商务、设计 — 专业代理共享同一知识库协同工作。
不再浪费 token，只剩面向目标的协作。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## ai-agency 是什么？

每次 AI 会话都从零开始。它不知道你的 API、团队规则或业务目标。你反复解释同样的内容 — 浪费时间和金钱。

**ai-agency** 为你的组织构建持久化上下文，并在此基础上编排 AI 专家：

1. **上下文一次构建，永久生效** — 只需构建一次项目知识层。每个代理都以完全了解的状态启动 — 代码库、规范、业务规则、团队结构。无重复 token 成本，无预热时间。

2. **编排协作的专家团队** — 不只是一个代理处理一个仓库。开发、策划、商务、设计、QA、运维 — 每位专家共享相同上下文并协作。PM 代理协调他们处理任务、解决问题，并在整个组织范围内交付成果。

无论是单个服务还是整个公司的工作流 — ai-agency 都能将合适的专家与合适的上下文编排在一起。

适用于所有 AI 工具：Claude Code、Codex、Cursor、Copilot、Gemini CLI、Windsurf、Aider。

<!-- TODO: 30秒演示 GIF — ai-agency init → 代理会话启动 → 代理在已加载上下文的状态下立即工作 -->

---

## 安装

### Homebrew（推荐）

```bash
brew install itdar/tap/ai-agency
```

### 不使用 Homebrew

```bash
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global
```

### 仅项目级安装

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash
```

---

## 快速开始

### 1. 初始化项目

```bash
cd ~/my-project
ai-agency init
```

也可以从其他位置运行：`ai-agency init ~/my-project`

自动完成三件事：
1. **扫描** — 探索目录结构并分类每个目录（backend、frontend、infra、business 等）
2. **生成** — 为每个区域生成 `AGENTS.md` 和 `.ai-agents/` 上下文
3. **验证** — 检查生成文件的完整性

<!-- TODO: ai-agency init 运行截图 — 显示 AI 工具/语言选择 CUI 的画面 -->

选择 AI 工具（Claude Code、Codex 或 Gemini）和语言。AI 随后分析项目并构建上下文。这是一次性设置 — 需要几分钟，但之后每次会话都能节省时间。

### 2. 启动代理会话

```bash
ai-agency
```

就这么简单。从交互菜单中选择一个代理即可开始工作。代理已经了解你的项目。

<!-- TODO: ai-agency 交互式 CUI 截图 — 显示箭头键导航的代理列表，彩色代理 -->

### 3. 日常使用

日常工作流不会改变。只需运行 `ai-agency` 而不是直接启动 AI 工具。

```bash
ai-agency                     # 交互式选择代理
ai-agency --agent api         # 直接进入 API 代理
```

当你选择顶层代理（PM、Domain Coordinator）时，它会根据需要自动调用和协调子代理 — 你无需自己管理。

在 tmux 分屏面板中并行运行多个独立代理：

```bash
ai-agency --multi             # 选择要并行运行的代理
```

<!-- TODO: tmux 多代理分屏面板截图 — 2-3个代理同时运行，带彩色面板边框 -->

---

## 为什么需要

### 没有 ai-agency

每次会话从零开始。AI 花时间（和你的 token）来了解项目：

- "这是什么框架？" — 需要读 20 个文件才能搞清楚
- "API 端点有哪些？" — 扫描每个控制器
- "团队规范是什么？" — 不知道，猜错了
- "谁批准部署？" — 不知道，直接跳过

> 研究（ETH Zurich, 2026）：重新分析已知项目的 AI 代理**多消耗 20% 的 token**，且结果比拥有预构建上下文的代理**更差**。

### 使用 ai-agency

AI 在几秒内加载所有内容并立即开始工作：

```
会话开始
  → 读取 AGENTS.md            "我是 order-api 的后端专家"
  → 加载 .ai-agents/context/  "我了解 API、数据模型、团队规则"
  → 立即开始工作               无需探索阶段
```

<!-- TODO: Before/After 对比图 — 左侧：AI 漫无目的地探索文件，右侧：加载上下文后 AI 立即高效工作 -->

---

## 生成的内容

运行 `ai-agency init` 后，会创建三层上下文：

```
your-project/
├── AGENTS.md                    # 我是谁？（角色、规则、权限）
├── .ai-agents/
│   ├── context/                 # 我知道什么？（领域知识）
│   │   ├── domain-overview.md   #   业务目的、政策、约束
│   │   ├── api-spec.json        #   API 端点映射
│   │   ├── data-model.md        #   实体和关系
│   │   └── ...                  #   （根据项目类型生成）
│   ├── skills/                  # 如何工作？（工作流标准）
│   │   ├── develop/SKILL.md     #   开发：分析 → 实现 → 测试 → PR
│   │   └── review/SKILL.md      #   审查：安全、性能检查清单
│   └── roles/                   # 角色级上下文加载策略
│       ├── pm.md
│       └── backend.md
├── apps/
│   ├── api/AGENTS.md            # 服务级代理
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**只存储不可推断的信息。** AI 通过读代码就能知道的（如"这是一个 React 应用"）会被排除。无法推断的（如"我们使用 squash merge"、"部署前需要 QA 批准"）才会被包含。

---

## 项目结构示例

ai-agency 适配项目的形态。运行 `ai-agency init` 的目录成为 PM（协调者）。

### 单一产品

```
my-app/               ← PM 代理
├── api/              ← 后端代理
├── web/              ← 前端代理
└── infra/            ← 基础设施代理
```

### 产品 + 业务团队

```
my-product/            ← PM 代理
├── api/              ← 后端代理
├── web/              ← 前端代理
├── business/         ← 业务分析师代理
├── planning/         ← 策划代理
└── infra/            ← 基础设施代理
```

不仅仅是代码 — 业务、策划、QA、运维等每个领域都有专业代理。

### 多领域平台

```
platform/              ← PM 代理
├── commerce/         ← 领域协调者（自动检测）
│   ├── order-api/    ← 后端代理
│   └── storefront/   ← 前端代理
├── social/           ← 领域协调者（自动检测）
│   ├── feed-api/     ← 后端代理
│   └── chat-api/     ← 后端代理
└── infra/            ← 基础设施代理
```

领域会自动检测 — 当一个目录包含 2 个以上各自拥有构建文件的子目录时，会被分类为领域边界。

---

## 团队模式

PM 代理协调子代理，或并行运行多个代理。

### 协调团队（Claude Code）

PM 代理通过 Claude Code 的原生代理团队功能将任务委派给专家：

```bash
ai-agency                     # 从菜单中选择 "team" 模式
```

<!-- TODO: 团队模式选择截图 — 显示 single/team/multi 选项的 CUI -->

### 并行代理（任何 AI 工具）

在 tmux 分屏面板中同时运行多个代理。通过基于文件的协作进行协调：

```bash
ai-agency --multi             # 选择代理后在分屏面板中运行
```

代理通过 `.ai-agents/coordination/` 进行协调 — 适用于任何 AI 工具的共享任务板和消息日志。

<!-- TODO: tmux 多代理会话 + task-board.md 可见的截图 -->

---

## 保持上下文更新

上下文文件在 AI 会话期间自动更新 — 每个 AGENTS.md 包含维护触发器，告诉代理何时更新什么。

会话结束后，ai-agency 会检查代码是否更改但上下文未更新，并发出警告：

```
[ai-agency] 检测到代码更改但未更新上下文文件。
  运行: ai-agency verify --staleness
```

也可以手动检查：

```bash
ai-agency verify              # 验证结构和完整性
ai-agency verify --staleness  # 检查上下文是否与代码同步
```

大幅更改后，以增量模式重新 init — 仅为新目录生成上下文：

```bash
ai-agency init                # 在提示中选择 "incremental"
```

---

## 支持的 AI 工具

ai-agency 是厂商中立的。AGENTS.md 适用于任何工具，需要的工具会自动生成引导文件。

| 工具 | 开箱即用 | 自动引导 |
|---|---|---|
| **OpenAI Codex** | Yes | 不需要 |
| **Claude Code** | Yes | 生成 `CLAUDE.md` |
| **Cursor** | 通过规则 | 生成 `.cursor/rules/` |
| **GitHub Copilot** | 通过指令 | 生成 `.github/copilot-instructions.md` |
| **Windsurf** | 通过规则 | 生成 `.windsurfrules` |
| **Aider** | 通过配置 | 更新 `.aider.conf.yml` |
| **Gemini CLI** | Yes | 不需要 |

引导文件仅为你实际使用的工具生成。不会为未使用的工具创建任何文件。

---

## CLI 参考

```bash
# 设置
ai-agency init [path]           # 初始化项目（扫描、生成、验证）
ai-agency classify [path]       # 预览目录分类（不生成）

# 日常使用
ai-agency                       # 交互式代理启动器
ai-agency --agent <keyword>     # 启动特定代理
ai-agency --multi               # tmux 分屏面板并行运行
ai-agency --tool <claude|codex> # 指定 AI 工具
ai-agency --lang <code>         # 设置 UI 语言 (en ko ja zh es fr de ru hi ar)

# 项目管理
ai-agency register [path]       # 注册项目
ai-agency scan [dir]            # 自动发现含 AGENTS.md 的项目
ai-agency list                  # 列出已注册项目
ai-agency unregister [path]     # 取消注册

# 维护
ai-agency verify [path]         # 验证生成的文件
ai-agency verify --staleness    # 检查上下文新鲜度
ai-agency clear [path]          # 删除所有生成的文件
```

---

## 内部工作原理

对于好奇的朋友：

1. **classify-dirs.sh** — 扫描项目并将 19 条规则作为提示提供。AI 通过分析文件内容、结构和用途，对每个目录是否为独立子项目做出最终判断
2. **scaffold.sh** — 基于分类结果，在根目录及各子项目下创建 `.ai-agents/` 目录结构和占位文件
3. **setup.sh** — 将 `HOW_TO_AGENTS.md` 传递给所选 AI 工具 — 引导 AI 执行 7 步分析和生成流程的元指令
4. **validate.sh** — 检查生成文件的结构完整性（必要章节、token 限制、引用完整性）
5. **sync-ai-rules.sh** — 创建指向 AGENTS.md 的厂商特定引导文件
6. **ai-agency.sh** — 管理交互式代理选择 CUI 和会话生命周期，包括上下文校验和跟踪和多代理协调

> **Token 提示：** 初始设置会分析整个项目，可能消耗数万 token。这是一次性成本 — 后续会话会即时加载预构建的上下文。

---

## 参考资料

- [AGENTS.md Standard](https://agents.md/) — 本项目所基于的厂商中立代理指令标准
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "只记录不可推断的内容"
- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 上下文设计的灵感来源

---

## 许可证

MIT

---

<p align="center">
  <sub>别再每次都向 AI 重新解释你的项目。设置一次，永远使用。</sub>
</p>
