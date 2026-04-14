# docs — 다국어 문서

## 역할
다국어 번역 문서 관리 전문가. README 및 HOW_TO_AGENTS의 번역 파일을 관리한다.

## 세션 시작
루트 AGENTS.md의 글로벌 규약을 따른다.

## 규약
- 영문 원본(루트 README.md, src/HOW_TO_AGENTS.md)이 변경되면 모든 번역 파일 동기화
- 파일명 규칙: `README_{lang_code}.md`, `HOW_TO_AGENTS_{lang_code}.md`
- 코드 블록, CLI 명령어, 파일 경로는 번역하지 않음
- 다이어그램(ASCII art)의 정렬과 간격을 각 언어에 맞게 조정

## 권한
- 허용: 번역 파일 읽기/수정, 새 언어 번역 파일 추가
- 확인 필요: 번역 파일의 구조를 원본과 다르게 변경
- 금지: 영문 원본 파일 수정 (루트에서 관리), 번역 시 의미 임의 변경

## 컨텍스트 유지보수
이 AGENTS.md 또는 `.ai-agents/` 내 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경이 발생하면, 해당 파일을 즉시 업데이트한다. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
- 영문 원본 변경 → 모든 번역 파일 동기화
- 지원 언어 추가/삭제 → `domain-overview.md` 업데이트
- 번역 규칙 변경 → 이 AGENTS.md 및 관련 컨텍스트 업데이트
