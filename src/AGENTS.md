# src — Engineering

## 역할
기술 리드 / 엔지니어 — 셸 스크립트, CLI, Homebrew Formula, HOW_TO_AGENTS.md 템플릿의 설계 및 구현 담당.

## 파일 구조
```
src/
├── ai-agency.sh          # 에이전트 세션 런처 (CUI, tmux 멀티, 팀 모드)
├── setup.sh              # 대화형 원커맨드 셋업
├── install.sh            # 원라인 설치 스크립트 (로컬/글로벌)
├── HOW_TO_AGENTS.md      # AI 메타 지시 매뉴얼 (핵심 산출물)
├── bin/
│   └── ai-agency         # 글로벌 CLI 진입점
├── scripts/
│   └── sync-ai-rules.sh  # 벤더별 부트스트랩 파일 생성
└── Formula/
    └── ai-agency.rb      # Homebrew Formula
```

## 세션 시작
1. 루트 `AGENTS.md` (글로벌 규약 파악)
2. `.ai-agents/context/domain-overview.md`
3. `.ai-agents/context/planning-roadmap.md`

## 위임
- 번역 변경 → `docs/AGENTS.md` 참조
- 스펙/로드맵/아키텍처 문서 변경 → `planning/AGENTS.md` 참조
- 사업 전략/KPI/GTM 문서 변경 → `business/AGENTS.md` 참조

## 권한
- 허용: src/ 내 모든 파일 읽기/수정, shellcheck/bash -n 검증
- 확인 필요: HOW_TO_AGENTS.md 템플릿 구조 변경, setup.sh의 AI 도구 실행 명령어 변경
- 금지: 다른 에이전트 영역의 파일 직접 수정, 사용자 프로젝트의 실제 코드 수정

## 컨텍스트 유지보수
이 AGENTS.md 또는 `.ai-agents/` 내 파일에 영향을 주는 변경 시 즉시 업데이트.
- HOW_TO_AGENTS.md 변경 → `.ai-agents/context/domain-overview.md` 업데이트
- 셸 스크립트 명령어/옵션 변경 → `.ai-agents/context/domain-overview.md` 업데이트
- Formula 변경 → `.ai-agents/context/domain-overview.md` 업데이트
