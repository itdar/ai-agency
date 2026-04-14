🌐 [English](../README.md) | [한국어](README_ko.md) | [中文](README_zh.md) | [日本語](README_ja.md) | [Español](README_es.md) | [Português](README_pt.md)

<div align="center">

# ai-agency

**당신의 목표를 중심으로 만들어지는, 나만의 AI 에이전시.**

프로젝트 컨텍스트를 한 번 만들면, 다시 설명할 필요가 없습니다.
개발, 기획, 비즈니스, 디자인 — 전문 에이전트들이 동일한 지식을 공유하며 함께 일합니다.
반복되는 토큰 낭비는 사라지고, 목표를 향한 협업만 남습니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## ai-agency가 뭔가요?

매 AI 세션이 처음부터 시작됩니다. API도 모르고, 팀 규칙도 모르고, 비즈니스 목표도 모릅니다. 같은 것을 반복해서 설명하느라 시간과 비용이 낭비됩니다.

**ai-agency**는 조직의 영속 컨텍스트를 만들고, 그 위에서 AI 전문가들을 오케스트레이션합니다:

1. **컨텍스트는 한 번, 영원히** — 프로젝트의 지식 레이어를 한 번만 만들면 됩니다. 모든 에이전트가 완벽히 브리핑된 상태로 시작합니다 — 코드베이스, 컨벤션, 비즈니스 규칙, 팀 구조. 반복되는 토큰 비용도, 워밍업 시간도 없습니다.

2. **오케스트레이션되는 전문가들** — 하나의 에이전트가 하나의 레포만 다루는 게 아닙니다. 개발, 기획, 비즈니스, 디자인, QA, 운영 — 각 전문가가 동일한 컨텍스트를 공유하며 협업합니다. PM 에이전트가 이들을 조율하여 업무를 처리하고, 문제를 해결하고, 조직 전반에 걸쳐 결과물을 만들어냅니다.

단일 서비스든, 회사 전체의 워크플로든 — ai-agency는 올바른 전문가를 올바른 컨텍스트와 함께 오케스트레이션합니다.

모든 AI 도구에서 동작합니다: Claude Code, Codex, Cursor, Copilot, Gemini CLI, Windsurf, Aider.

<!-- TODO: 30초 데모 GIF — ai-agency init → 에이전트 세션 실행 → 컨텍스트가 로딩된 상태로 에이전트가 즉시 작업하는 모습 -->

---

## 설치

### Homebrew (권장)

```bash
brew install itdar/tap/ai-agency
```

### Homebrew 없이

```bash
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash -s -- --global
```

### 프로젝트 단위 설치

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/itdar/ai-agency/main/src/install.sh | bash
```

---

## 시작하기

### 1. 프로젝트 초기화

```bash
cd ~/my-project
ai-agency init
```

다른 경로에서 실행할 수도 있습니다: `ai-agency init ~/my-project`

세 가지가 자동으로 진행됩니다:
1. **스캔** — 디렉토리 구조를 탐색하고 각 디렉토리를 분류합니다 (backend, frontend, infra, business 등)
2. **생성** — 각 영역에 `AGENTS.md`와 `.ai-agents/` 컨텍스트를 생성합니다
3. **검증** — 생성된 파일의 완전성을 검사합니다

<!-- TODO: ai-agency init 실행 화면 스크린샷 — AI 도구/언어 선택 CUI가 보이는 화면 -->

AI 도구(Claude Code, Codex, Gemini)와 언어를 선택하면, AI가 프로젝트를 분석하고 컨텍스트를 빌드합니다. 최초 1회만 하면 됩니다 — 몇 분 걸리지만 이후 매 세션에서 시간을 절약합니다.

### 2. 에이전트 세션 시작

```bash
ai-agency
```

끝입니다. 인터랙티브 메뉴에서 에이전트를 선택하면 즉시 작업을 시작합니다. 에이전트는 이미 프로젝트를 알고 있습니다.

<!-- TODO: ai-agency 인터랙티브 CUI 스크린샷 — 화살표로 탐색하는 에이전트 목록, 컬러 에이전트들 -->

### 3. 일상적 사용

일상적인 워크플로가 바뀌지 않습니다. AI 도구를 직접 실행하는 대신 `ai-agency`를 실행하면 됩니다.

```bash
ai-agency                     # 인터랙티브하게 에이전트 선택
ai-agency --agent api         # API 에이전트로 바로 진입
```

상위 에이전트(PM, Domain Coordinator)를 선택하면 필요에 따라 하위 에이전트를 자동으로 소환하고 조율합니다 — 직접 관리할 필요가 없습니다.

여러 독립적인 에이전트를 tmux 분할 패널에서 나란히 실행하려면:

```bash
ai-agency --multi             # 병렬 실행할 에이전트 선택
```

<!-- TODO: tmux 멀티에이전트 분할 패널 스크린샷 — 2-3개 에이전트가 컬러 패널 테두리와 함께 동시 실행되는 화면 -->

---

## 왜 필요한가

### ai-agency 없이

매 세션이 처음부터 시작됩니다. AI가 프로젝트를 파악하느라 시간(과 토큰)을 씁니다:

- "이 프레임워크가 뭐지?" — 파일 20개를 읽어야 파악
- "API 엔드포인트가 뭐가 있지?" — 컨트롤러 전부 스캔
- "팀 컨벤션이 뭐지?" — 모르니까 틀리게 추측
- "배포 승인은 누가 하지?" — 모르니까 그냥 건너뜀

> 연구 (ETH Zurich, 2026): 이미 파악된 프로젝트를 다시 분석하는 AI 에이전트는 **토큰 20% 추가 소모**하고, 사전 구축된 컨텍스트가 있는 에이전트보다 **더 나쁜 결과**를 냄.

### ai-agency와 함께

AI가 몇 초 만에 모든 것을 로딩하고 즉시 작업을 시작합니다:

```
세션 시작
  → AGENTS.md 읽기              "나는 order-api의 백엔드 전문가야"
  → .ai-agents/context/ 로딩    "API, 데이터 모델, 팀 규칙 다 알고 있어"
  → 바로 작업 시작               탐색 단계 필요 없음
```

<!-- TODO: Before/After 비교 이미지 — 왼쪽: AI가 파일을 헤매는 모습, 오른쪽: 컨텍스트 로딩 후 즉시 생산적으로 작업하는 모습 -->

---

## 생성되는 것들

`ai-agency init`을 실행하면 세 가지 레이어의 컨텍스트가 생성됩니다:

```
your-project/
├── AGENTS.md                    # 나는 누구인가? (역할, 규칙, 권한)
├── .ai-agents/
│   ├── context/                 # 내가 아는 것은? (도메인 지식)
│   │   ├── domain-overview.md   #   사업 목적, 정책, 제약사항
│   │   ├── api-spec.json        #   API 엔드포인트 맵
│   │   ├── data-model.md        #   엔티티와 관계
│   │   └── ...                  #   (프로젝트 타입에 따라 생성)
│   ├── skills/                  # 어떻게 일하는가? (워크플로 표준)
│   │   ├── develop/SKILL.md     #   개발: 분석 → 구현 → 테스트 → PR
│   │   └── review/SKILL.md      #   리뷰: 보안, 성능 체크리스트
│   └── roles/                   # 역할별 컨텍스트 로딩 전략
│       ├── pm.md
│       └── backend.md
├── apps/
│   ├── api/AGENTS.md            # 서비스별 에이전트
│   └── web/AGENTS.md
└── infra/AGENTS.md
```

**추론할 수 없는 정보만 저장됩니다.** AI가 코드를 읽으면 알 수 있는 것("이건 React 앱이다")은 제외됩니다. 추론할 수 없는 것("우리는 squash merge를 쓴다", "배포 전 QA 승인이 필요하다")만 포함됩니다.

---

## 프로젝트 구조 예시

ai-agency는 프로젝트의 형태에 맞게 적응합니다. `ai-agency init`을 실행한 디렉토리가 PM(조율자)이 됩니다.

### 단일 제품

```
my-app/               ← PM 에이전트
├── api/              ← 백엔드 에이전트
├── web/              ← 프론트엔드 에이전트
└── infra/            ← 인프라 에이전트
```

### 제품 + 비즈니스 팀

```
my-product/            ← PM 에이전트
├── api/              ← 백엔드 에이전트
├── web/              ← 프론트엔드 에이전트
├── business/         ← 비즈니스 분석가 에이전트
├── planning/         ← 기획자 에이전트
└── infra/            ← 인프라 에이전트
```

코드뿐만이 아닙니다 — 비즈니스, 기획, QA, 운영 등 모든 영역에 전문 에이전트가 배치됩니다.

### 멀티 도메인 플랫폼

```
platform/              ← PM 에이전트
├── commerce/         ← 도메인 코디네이터 (자동 감지)
│   ├── order-api/    ← 백엔드 에이전트
│   └── storefront/   ← 프론트엔드 에이전트
├── social/           ← 도메인 코디네이터 (자동 감지)
│   ├── feed-api/     ← 백엔드 에이전트
│   └── chat-api/     ← 백엔드 에이전트
└── infra/            ← 인프라 에이전트
```

도메인은 자동으로 감지됩니다 — 하위 디렉토리 2개 이상이 각자 빌드 파일을 가지고 있으면 도메인 경계로 분류됩니다.

---

## 팀 모드

PM 에이전트가 하위 에이전트를 조율하거나, 여러 에이전트를 병렬로 실행할 수 있습니다.

### 조율 팀 (Claude Code)

PM 에이전트가 Claude Code의 네이티브 에이전트 팀 기능으로 전문가에게 작업을 위임합니다:

```bash
ai-agency                     # 메뉴에서 "team" 모드 선택
```

<!-- TODO: 팀모드 선택 화면 스크린샷 — single/team/multi 옵션이 보이는 CUI -->

### 병렬 에이전트 (모든 AI 도구)

tmux 분할 패널에서 여러 에이전트를 동시에 실행합니다. 파일 기반 협업으로 조율됩니다:

```bash
ai-agency --multi             # 실행할 에이전트를 선택하면 분할 패널로 실행
```

에이전트들은 `.ai-agents/coordination/`을 통해 조율합니다 — 모든 AI 도구에서 동작하는 공유 태스크 보드와 메시지 로그입니다.

<!-- TODO: tmux 멀티에이전트 세션 + task-board.md가 보이는 스크린샷 -->

---

## 컨텍스트 최신 유지

컨텍스트 파일은 AI 세션 중에 자동으로 업데이트됩니다 — 각 AGENTS.md에 유지보수 트리거가 포함되어 있어서 에이전트가 언제 무엇을 업데이트해야 하는지 알고 있습니다.

세션 종료 후, ai-agency는 코드가 변경되었는데 컨텍스트가 업데이트되지 않았으면 경고합니다:

```
[ai-agency] 코드 변경이 감지되었지만 컨텍스트 파일이 업데이트되지 않았습니다.
  실행: ai-agency verify --staleness
```

수동으로 확인할 수도 있습니다:

```bash
ai-agency verify              # 구조 및 완전성 검증
ai-agency verify --staleness  # 컨텍스트가 코드와 동기화되어 있는지 확인
```

큰 변경 후에는 증분 모드로 다시 init하면 됩니다 — 새로운 디렉토리에 대해서만 컨텍스트를 생성합니다:

```bash
ai-agency init                # 프롬프트에서 "incremental" 선택
```

---

## 지원 AI 도구

ai-agency는 벤더 중립적입니다. AGENTS.md는 어떤 도구에서든 동작하고, 필요한 도구에는 부트스트랩 파일이 자동 생성됩니다.

| 도구 | 바로 동작 | 자동 부트스트랩 |
|---|---|---|
| **OpenAI Codex** | Yes | 불필요 |
| **Claude Code** | Yes | `CLAUDE.md` 생성 |
| **Cursor** | 규칙 경유 | `.cursor/rules/` 생성 |
| **GitHub Copilot** | 지시문 경유 | `.github/copilot-instructions.md` 생성 |
| **Windsurf** | 규칙 경유 | `.windsurfrules` 생성 |
| **Aider** | 설정 경유 | `.aider.conf.yml` 갱신 |
| **Gemini CLI** | Yes | 불필요 |

부트스트랩 파일은 실제로 사용 중인 도구에 대해서만 생성됩니다. 사용하지 않는 도구의 파일은 만들지 않습니다.

---

## CLI 레퍼런스

```bash
# 설정
ai-agency init [path]           # 프로젝트 초기화 (스캔, 생성, 검증)
ai-agency classify [path]       # 생성 없이 디렉토리 분류 미리보기

# 일상 사용
ai-agency                       # 인터랙티브 에이전트 실행기
ai-agency --agent <keyword>     # 특정 에이전트 바로 실행
ai-agency --multi               # tmux 분할 패널에서 병렬 실행
ai-agency --tool <claude|codex> # AI 도구 지정
ai-agency --lang <code>         # UI 언어 설정 (en ko ja zh es fr de ru hi ar)

# 프로젝트 관리
ai-agency register [path]       # 프로젝트 등록
ai-agency scan [dir]            # AGENTS.md가 있는 프로젝트 자동 탐색
ai-agency list                  # 등록된 프로젝트 목록
ai-agency unregister [path]     # 등록 해제

# 유지보수
ai-agency verify [path]         # 생성된 파일 검증
ai-agency verify --staleness    # 컨텍스트 신선도 확인
ai-agency clear [path]          # 생성된 파일 전부 삭제
```

---

## 내부 동작 원리

궁금한 분들을 위해:

1. **classify-dirs.sh** — 프로젝트를 스캔하고 19개 규칙을 힌트로 제공합니다. AI가 파일 내용, 구조, 목적을 분석하여 각 디렉토리가 독립 서브 프로젝트인지 최종 판단합니다
2. **scaffold.sh** — 분류 결과를 기반으로 루트 및 각 서브 프로젝트별 `.ai-agents/` 디렉토리 구조와 플레이스홀더 파일을 생성합니다
3. **setup.sh** — 선택한 AI 도구에 `HOW_TO_AGENTS.md`를 전달합니다 — AI가 7단계 분석/생성 프로세스를 실행하는 메타 명령서입니다
4. **validate.sh** — 생성된 파일의 구조적 정합성을 검사합니다 (필수 섹션, 토큰 제한, 참조 무결성)
5. **sync-ai-rules.sh** — AGENTS.md를 가리키는 벤더별 부트스트랩 파일을 생성합니다
6. **ai-agency.sh** — 인터랙티브 에이전트 선택 CUI와 세션 라이프사이클을 관리합니다. 컨텍스트 체크섬 추적과 멀티에이전트 조율을 포함합니다

> **토큰 참고:** 최초 설정은 전체 프로젝트를 분석하므로 수만 토큰을 소비할 수 있습니다. 이것은 1회성 비용이며, 이후 세션에서는 미리 빌드된 컨텍스트를 즉시 로딩합니다.

---

## 참고 자료

- [AGENTS.md Standard](https://agents.md/) — 이 프로젝트가 기반하는 벤더 중립 에이전트 명령 표준
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "추론할 수 없는 것만 문서화하라"
- [컬리 OMS팀 AI 워크플로](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 컨텍스트 설계의 영감

---

## 라이선스

MIT

---

<p align="center">
  <sub>프로젝트를 AI에게 매번 다시 설명하는 것을 멈추세요. 한 번 설정하고, 영원히 사용하세요.</sub>
</p>
