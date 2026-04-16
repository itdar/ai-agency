🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md)

<div align="center">

# ai-agency

**이제 프로젝트 설명은 그만.**

AI 도구(Claude Code, Codex, Cursor, Gemini, Copilot, Windsurf, Aider)가
매 세션마다 다시 파악하지 않도록 — 벤더 중립 컨텍스트 레이어를 한 번 만들어 두는 CLI.
코드베이스, 컨벤션, 비즈니스 규칙을 이미 알고 있는 상태로 세션이 시작됩니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## 60초 만에 시작

```bash
brew install itdar/tap/ai-agency

cd ~/your-project
ai-agency init      # 스캔 후 AGENTS.md + .ai-agents/ 컨텍스트 생성
ai-agency           # 에이전트 선택 — 이미 브리핑된 상태로 시작
```

Homebrew 미사용 시: `curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global`

---

## 왜 필요한가

AI 세션은 매번 제로에서 시작합니다. 모델은 토큰을 낭비하며 다시 파악합니다:

- "이거 무슨 프레임워크지?" — 파일 20개 훑기
- "팀 컨벤션은?" — 잘못 추측
- "배포 승인자는?" — 그냥 건너뜀

> 연구(ETH Zurich, 2026-03 리뷰): 이미 분석된 프로젝트를 에이전트가 다시 분석하면 토큰을 **약 20% 더 쓰고** 결과 품질도 **사전 큐레이션된 컨텍스트 파일을 가진 에이전트보다 떨어집니다**. [리뷰 기사 ↗](https://www.infoq.com/news/2026/03/agents-context-file-value-review/)

`ai-agency`는 그 컨텍스트 파일을 한 번만 작성합니다 — 벤더 중립, 에이전트당 300 토큰 이내 — 이후 어떤 AI 도구를 쓰든 매 세션마다 로딩합니다.

---

## 실제로 뭐가 만들어지는가

`ai-agency init`은 각 디렉토리를 분류한 뒤 계층화된 컨텍스트를 생성합니다:

```
your-project/
├── AGENTS.md                     # 나는 누구인가? — 역할/규칙/권한 (≤300 토큰)
├── .ai-agents/
│   ├── context/                  # 무엇을 아는가? — 추론 불가 사실만
│   │   ├── domain-overview.md    #   비즈니스 목적, 정책, 제약
│   │   ├── api-spec.json         #   엔드포인트 맵 (JSON DSL — 산문 대비 ~3배 저렴)
│   │   ├── data-model.md         #   엔티티 + 관계
│   │   ├── business-metrics.md   #   KPI, OKR
│   │   ├── stakeholder-map.md    #   RACI, 승인 흐름
│   │   └── planning-roadmap.md   #   마일스톤, 의사결정 로그
│   ├── skills/                   # 어떻게 일하는가? — 필요 시 로딩
│   │   └── develop/SKILL.md
│   ├── roles/                    # 역할별 로딩 전략
│   │   ├── pm.md
│   │   └── backend.md
│   └── coordination/             # 크로스 벤더 태스크 보드 (멀티에이전트 모드)
│       ├── task-board.md
│       ├── messages.md
│       └── agent-status.json
├── apps/
│   ├── api/AGENTS.md             # 서비스별 에이전트
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**AI가 코드만 보고 알 수 없는 것만 저장합니다.** "이건 React 앱이다"는 `package.json`을 보면 자명하므로 빠집니다. "우리는 squash merge를 쓰고 배포 전 QA 승인이 필수다"는 추론 불가 — 이게 들어갑니다.

---

## 코드만의 도구가 아닙니다

대부분의 AI 도구는 레포 경계에서 멈춥니다. `ai-agency`는 조직 전체를 프로젝트로 봅니다:

```
my-product/              ← PM 에이전트 (조율자)
├── api/                 ← 백엔드 에이전트
├── web/                 ← 프론트엔드 에이전트
├── planning/            ← 테크니컬 라이터 (스펙, ADR, 로드맵)
├── business/            ← 비즈니스 분석가 (GTM, KPI, 이해관계자)
└── infra/               ← 인프라 에이전트
```

PM 에이전트가 작업에 맞는 전문가에게 위임합니다 — 코드 변경은 백엔드, 가격 문의는 비즈니스, 스펙 초안은 기획. 각 전문가는 자기 컨텍스트만 로드하므로 토큰 사용량이 예측 가능합니다.

멀티 도메인 플랫폼의 경우, 빌드 파일을 가진 서브 프로젝트가 2개 이상이면 도메인이 자동 감지됩니다:

```
platform/
├── commerce/           ← 도메인 코디네이터 (자동 감지)
│   ├── order-api/
│   └── storefront/
├── social/             ← 도메인 코디네이터 (자동 감지)
│   ├── feed-api/
│   └── chat-api/
└── infra/
```

---

## 에이전트 실행

### 단일 에이전트

```bash
ai-agency                       # 대화형 메뉴
ai-agency --agent api           # 특정 에이전트로 직행
```

### 팀 모드 (Claude Code)

메뉴에서 "team" 선택. PM 에이전트가 Claude Code의 네이티브 에이전트 팀 기능으로 서브 작업을 전문가에게 위임합니다. 서브 에이전트를 직접 관리할 필요 없음 — PM이 처리합니다.

### 병렬 에이전트 (모든 AI 도구)

```bash
ai-agency --multi               # tmux 분할 패널, 패널당 에이전트 1개
```

각 패널은 원하는 도구로 독립 실행됩니다. 에이전트들은 `.ai-agents/coordination/` — 평문 태스크 보드, 메시지 로그, 상태 JSON — 을 통해 협업합니다. 한 패널의 Claude Code 에이전트가 다른 패널의 Codex 에이전트에게 작업을 넘기는 방식. 독점 프로토콜 없이 파일로만.

---

## 지원 AI 도구

`ai-agency`는 `AGENTS.md` ([오픈 표준](https://agents.md/))에 더해 벤더별 부트스트랩 파일을 생성합니다 — 단, 프로젝트에 이미 존재하는 벤더에 한해서만.

| 도구 | 즉시 동작 | 자동 생성 부트스트랩 |
|---|---|---|
| OpenAI Codex | `AGENTS.md` 네이티브 지원 | — |
| Gemini CLI | `AGENTS.md` 네이티브 지원 | — |
| Claude Code | ✓ | `CLAUDE.md` |
| Cursor | ✓ | `.cursor/rules/agents.mdc` |
| GitHub Copilot | ✓ | `.github/copilot-instructions.md` |
| Windsurf | ✓ | `.windsurfrules` |
| Aider | ✓ | `.aider.conf.yml` (read 지시문 추가) |

도구를 바꿔도 컨텍스트 레이어는 그대로입니다.

---

## 컨텍스트 최신성 유지

각 `AGENTS.md`에 유지보수 트리거가 내장되어 있습니다("API 계약이 바뀌면 `api-spec.json` 갱신"). AI가 세션 중에 컨텍스트를 갱신합니다.

세션 종료 후 `ai-agency`가 코드 체크섬을 컨텍스트 파일과 비교하여 드리프트를 경고합니다:

```
[ai-agency] Code changes detected but no context files updated.
  Run: ai-agency verify --staleness
```

수동 점검:

```bash
ai-agency verify                # 구조 + 완결성
ai-agency verify --staleness    # 코드-컨텍스트 드리프트
```

대규모 리팩토링 이후에는 `ai-agency init`을 다시 실행 — **증분 모드**가 새로/변경된 디렉토리만 재생성합니다.

---

## CLI 레퍼런스

```bash
# 셋업
ai-agency init [path]            # 스캔 → 분류 → 생성 → 검증
ai-agency classify [path]        # 생성 없이 분류만 미리보기

# 일상 사용
ai-agency                        # 대화형 런처
ai-agency --agent <keyword>      # 특정 에이전트 실행
ai-agency --multi                # tmux 패널 병렬 실행
ai-agency --tool <claude|codex|gemini>
ai-agency --lang <code>          # UI 언어: en ko ja zh es fr de ru hi ar

# 프로젝트 레지스트리
ai-agency register [path]
ai-agency scan [dir]
ai-agency list
ai-agency unregister [path]

# 유지보수
ai-agency verify [path]
ai-agency verify --staleness
ai-agency clear [path]           # 생성 파일 모두 제거
```

---

## 설계 원칙

- **벤더 중립.** `AGENTS.md`가 공용 표준. 부트스트랩 파일은 얇은 포인터일 뿐.
- **추론 불가 사실만.** 코드를 읽어서 알 수 있는 정보는 컨텍스트에 담지 않습니다.
- **토큰 예산.** 각 `AGENTS.md`는 템플릿 치환 후 ~300 토큰 이내. API/이벤트 스펙은 JSON DSL(산문 대비 ~3배 저렴).
- **지식 / 행동 / 역할 분리.** context(항상 로딩), skills(필요 시), roles(에이전트별 로딩 전략) — 섞으면 토큰 사용이 예측 불가.
- **파일 기반 협업.** 멀티에이전트 핸드오프는 `.ai-agents/coordination/`의 Markdown + JSON으로. 어떤 도구든 참여 가능.

---

## 내부 동작 (Internals)

1. `classify-dirs.sh`가 19개 파일 패턴 규칙으로 각 디렉토리 타입 힌트 제공. 최종 판단은 AI.
2. `scaffold.sh`가 루트와 서브 프로젝트마다 `.ai-agents/` 생성.
3. `setup.sh`가 `HOW_TO_AGENTS.md`(7단계 메타 지시문)로 AI 도구를 실행해 생성을 주도.
4. `validate.sh`가 필수 섹션, 토큰 한도, 참조 무결성 검증.
5. `sync-ai-rules.sh`가 벤더 부트스트랩 파일 생성 (이미 쓰는 벤더만).
6. `ai-agency.sh`가 대화형 CUI 실행, 세션 체크섬 추적, 멀티에이전트 세션에 협업 프로토콜 주입.

> **비용 안내:** 최초 생성은 프로젝트 전체를 스캔하므로 수만 토큰이 들 수 있습니다. 이건 일회성 비용 — 이후 세션은 사전 구축된 컨텍스트를 즉시 로딩합니다.

---

## 참고 자료

- [AGENTS.md](https://agents.md/) — 본 도구가 기반하는 벤더 중립 표준
- [ETH Zurich 컨텍스트 파일 리뷰 (InfoQ, 2026-03)](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "추론 불가한 것만 문서화"
- [컬리 OMS 팀 워크플로](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 컨텍스트 설계 영감

---

## 라이선스

MIT

---

<p align="center">
  <sub>한 번 설정하면, 영원히 작동합니다.</sub>
</p>
