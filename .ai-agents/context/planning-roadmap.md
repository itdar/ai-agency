# ai-agency 기획 로드맵

## 현재 마일스톤

### v1.0 — 핵심 릴리스 (완료)
- [x] HOW_TO_AGENTS.md 메타 가이드 (6단계 생성 절차)
- [x] ai-agency.sh 세션 런처 (단일 + tmux 멀티에이전트)
- [x] setup.sh 대화형 셋업 (도구 + 언어 선택)
- [x] `--lang` 10종 UI 언어 수용 (en/ko/ja/zh/es/fr/de/ru/hi/ar)
- [x] 실제 번역본 5종(en + ko/ja/zh/es) 운용 — fr/de/ru/hi/ar는 `--lang`만 지원, README 번역은 미작성

### v1.1 — 비즈니스 컨텍스트 통합 (완료)
- [x] 비즈니스/기획/운영 컨텍스트 파일 (business-metrics.md, stakeholder-map.md, ops-runbook.md, planning-roadmap.md)
- [x] B-9, B-10 템플릿 확장
- [x] 역할 템플릿 갱신 (business-analyst, planner, cs-specialist)
- [x] setup.sh 증분 업데이트 모드

### v3.x — 현재 (진행 중)
- [x] 네이티브 에이전트 팀 모드, 분할 패널 멀티세션
- [x] `--lang` 플래그 지원
- [x] Homebrew Formula 배포 (itdar/tap/ai-agency)
- [x] 글로벌 설치 (`ai-agency init`, `ai-agency register`, `ai-agency scan`)

### 향후
<!-- HUMAN INPUT NEEDED: 다음 마일스톤 범위, 목표 일정, 담당자 정의 -->

## 의존성
- src/HOW_TO_AGENTS.md 템플릿 변경은 모든 생성 프로젝트에 영향
- README 변경은 10개 언어 동기화 필요
- 셸 스크립트 변경은 claude/codex/gemini 전체 테스트 필요
- Homebrew Formula 변경은 tap 저장소 동기화 필요

## 의사결정 로그
| 일자 | 결정 | 근거 |
|---|---|---|
| 2026-03 | 벤더 중립 AGENTS.md 표준 | 특정 AI 도구 종속 회피 |
| 2026-03 | api-spec/event-spec에 JSON DSL 채택 | 자연어 대비 3배 토큰 절약 |
| 2026-03 | ETH Zurich 원칙: 비추론 가능 정보만 포함 | 추론 가능 정보 포함 시 성공률 하락 + 비용 20% 증가 |
| 2026-04 | Homebrew 글로벌 배포 | 설치 편의성 및 접근성 향상 |
