# ai-agency 도메인 개요

## 비즈니스 목적
AI 코딩 도구(Claude Code, Codex, Gemini CLI, Cursor 등)가 프로젝트를 즉시 이해할 수 있도록 `AGENTS.md` + 지식/스킬/역할 컨텍스트를 자동 생성하는 CLI 도구.

AI 에이전트가 매 세션마다 코드베이스 전체를 다시 분석하는 비효율을 해결한다. 한 번 생성한 컨텍스트를 이후 세션에서 즉시 로딩하여 비용과 시간을 절감.

## 핵심 산출물
모든 엔지니어링 파일은 `src/` 디렉토리에 위치한다.
1. **src/HOW_TO_AGENTS.md** — AI가 읽고 실행하는 메타 가이드. 7단계 절차로 프로젝트를 분석하여 AGENTS.md를 생성하는 명령서. Step 3-4에 멀티에이전트 협업 프로토콜 포함
2. **src/setup.sh** — 대화형 원커맨드 셋업. AI 도구 선택 → 언어 선택 → HOW_TO_AGENTS.md 자동 실행. 기존 설정 감지 시 증분 업데이트 모드 지원. 완료 후 자동 검증(validate.sh) 실행
3. **src/ai-agency.sh** — 생성된 AGENTS.md 기반으로 에이전트 세션을 시작하는 런처. tmux 멀티세션, iTerm2 배경색, 팀 모드(분할 패널) 지원. 세션 시작/종료 시 컨텍스트 체크섬 추적(.session-meta.json). tmux 멀티모드에서 파일 기반 협업 프로토콜 주입. UI 영문
4. **src/install.sh** — 글로벌(`--global`) 및 로컬 설치 스크립트. curl 원라인 설치 지원
5. **src/bin/ai-agency** — 글로벌 설치 시 CLI 진입점. `ai-agency init`, `ai-agency`, `ai-agency register`, `ai-agency scan`, `ai-agency verify`, `ai-agency classify` 명령 제공. init 시 사전분류+스캐폴딩 자동 실행
6. **src/scripts/sync-ai-rules.sh** — 벤더별 부트스트랩 파일 자동 생성 (CLAUDE.md, .cursor/rules/, .github/copilot-instructions.md 등)
7. **src/scripts/classify-dirs.sh** — 파일 패턴 기반 사전 분류 힌트 제공 엔진. AI가 최종 서브 프로젝트 판단을 내림
8. **src/scripts/scaffold.sh** — 분류 결과 기반 .ai-agents/ 디렉토리 구조 생성. 서브 프로젝트에는 개별 .ai-agents/context/ 생성
9. **src/scripts/validate.sh** — 생성된 AGENTS.md 및 .ai-agents/ 구조 검증기. 섹션 검사, 토큰 추정, 참조 무결성, staleness 체크
10. **src/Formula/ai-agency.rb** — Homebrew 배포용 Formula

## 핵심 정책 / 제약
- **벤더 중립**: 특정 AI 도구에 종속되지 않음. AGENTS.md는 모든 도구에서 동작
- **비추론 가능 정보만 포함**: ETH Zurich 연구(2026.03) 기반 — 추론 가능한 내용을 포함하면 성공률 하락 + 비용 20% 증가
- **상대 경로**: 모든 경로 참조는 상대 경로 사용
- **300 토큰 제한**: AGENTS.md 하나당 치환 후 300 토큰 이내 권장
- **JSON DSL**: api-spec.json, event-spec.json은 자연어 대비 3배 토큰 절약

## 디렉토리 분류 체계
AI가 디렉토리 내용을 분석하여 독립 서브 프로젝트 여부를 판단. classify-dirs.sh의 19개 파일 패턴 규칙은 사전 분류 힌트로 제공:
- k8s-workload, infra-component, gitops-appset, bootstrap
- frontend, backend-node/go/jvm/python
- cicd, github-actions, docs-planning, docs-technical
- env-config, business, customer-support, secrets
- domain-grouping, grouping, generic

서브 프로젝트 판별 기준: 독립 빌드 시스템, 고유 목적/범위, 자체 팀/이해관계자, 코드 외 프로젝트(연구, 기획 등)도 해당

## 컨텍스트 계층 구조
- **루트** `.ai-agents/context/`: 프로젝트 전체 범위 (domain-overview, stakeholder-map, planning-roadmap, business-metrics)
- **서브 프로젝트** `.ai-agents/context/`: 타입별 기술 파일 (api-spec, data-model, infra-spec, ops-runbook 등)
- 서브에이전트는 자기 `.ai-agents/context/`만 로드, 루트는 PM 전용

```
.ai-agents/
├── context/        # 지식 — 프로젝트 전체 범위 (세션 시작 시 로딩)
├── skills/         # 행동 (필요 시 동적 로딩, 유연성)
├── roles/          # 역할 (로딩 전략이 역할마다 다름)
├── coordination/   # 협업 (멀티에이전트 프로젝트에서 파일 기반 크로스 벤더 통신)
│   ├── task-board.md       # 마크다운 태스크 보드
│   ├── messages.md         # 에이전트 간 메시지 로그
│   └── agent-status.json   # 에이전트 상태
└── .session-meta.json      # 세션 메타데이터 (체크섬, 타임스탬프)
```
지식과 행동을 분리하는 이유: 혼합하면 토큰 사용량이 불예측하고 불필요한 정보로 컨텍스트가 오염됨.

## 배포 방식
- Homebrew: `brew install itdar/tap/ai-agency`
- curl 원라인: `curl -fsSL .../install.sh | bash -s -- --global`
- 로컬: `curl -fsSL .../install.sh | bash` (프로젝트 디렉토리 내)

## 벤더 부트스트랩 전략
AGENTS.md를 직접 읽지 않는 도구를 위해 각 벤더의 자동 로딩 파일에 부트스트랩 지시문을 삽입. 이미 사용 중인 벤더만 대상으로 하며, 사용하지 않는 벤더의 파일은 생성하지 않음.

## 레거시 특이사항
<!-- HUMAN INPUT NEEDED: 프로젝트 히스토리에서 비코드적 맥락이 있다면 여기에 기록 -->
