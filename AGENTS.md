# ai-agency

## 역할
이 프로젝트의 PM 에이전트. 전체 구조를 파악하고 하위 에이전트에 작업을 위임한다.

## 에이전트 트리
```
AGENTS.md (루트 PM — 현재 파일)
├── src/AGENTS.md (비어 있음 — 파일 추가 시 컨텍스트 갱신 필요)
├── docs/AGENTS.md (다국어 문서 관리)
├── planning/AGENTS.md (기술 문서 / 기획)
└── business/AGENTS.md (사업화 기획 / 전략)
```

## 컨텍스트 파일
- 도메인: `.ai-agents/context/domain-overview.md`
- 로드맵: `.ai-agents/context/planning-roadmap.md`
- 이해관계자: `.ai-agents/context/stakeholder-map.md`
- 비즈니스 지표: `.ai-agents/context/business-metrics.md`

## 세션 시작
세션 시작 시 위 컨텍스트 파일과 에이전트 트리를 읽고 전체 프로젝트를 파악한다.

## 위임
- 셸 스크립트 / CLI 변경 (src/setup.sh, src/ai-agency.sh, src/install.sh, src/bin/, src/scripts/) → `src/AGENTS.md` 참조
- HOW_TO_AGENTS.md 변경 → `src/AGENTS.md` 참조 (핵심 산출물)
- 문서/번역 변경 → `docs/AGENTS.md` 참조
- 스펙/로드맵/아키텍처 문서 변경 → `planning/AGENTS.md` 참조
- 사업 전략/KPI/GTM 문서 변경 → `business/AGENTS.md` 참조

## 글로벌 규약

### 커밋
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- 제목 50자 이내, 본문에 Why 포함

### 브랜치
- `feature/{설명}`, `hotfix/{설명}`
- main 직접 푸시 금지

### PR
- squash merge 사용
- 최소 1명 approve 후 병합

### 코드 스타일
- 셸 스크립트: `set -euo pipefail` 필수, 변수 `"${VAR}"` 형태로 인용
- Markdown: 각 언어별 번역 파일은 영문 원본과 구조 동일하게 유지

### 다국어
- 영문(README.md, src/HOW_TO_AGENTS.md)이 원본, docs/ 내 파일은 번역본
- 번역 시 코드 블록, 명령어, 경로명은 번역하지 않음
- 지원 언어: en, ko, ja, zh, es, fr, de, ru, hi, ar (10개)

## 글로벌 권한
- 금지(Never): 사용자 프로젝트의 실제 코드를 수정, `.env`/시크릿 커밋, src/HOW_TO_AGENTS.md 내 플레이스홀더(`{snake_case}`)를 실제 값으로 치환한 채 커밋
- 확인 필요(Ask First): src/HOW_TO_AGENTS.md 템플릿 구조 변경, 지원 언어 추가/삭제, src/setup.sh의 AI 도구 실행 명령어 변경

## 컨텍스트 유지보수
이 AGENTS.md 또는 `.ai-agents/` 내 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경이 발생하면, 해당 파일을 즉시 업데이트한다.
코드, 설정, 문서, 비즈니스 규칙, 의존성 등 모든 유형의 변경에 적용된다. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
- src/HOW_TO_AGENTS.md 템플릿 변경 → `domain-overview.md` 업데이트
- src/ 셸 스크립트 명령어/옵션 변경 → `domain-overview.md` 업데이트
- 지원 언어/번역 구조 변경 → `domain-overview.md` 업데이트
- 업데이트하지 않으면 다음 세션이 오래된 컨텍스트로 작업하게 됨
