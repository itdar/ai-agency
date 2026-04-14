# 스킬: 개발 워크플로우

## 트리거
새로운 기능 구현, 버그 수정, 셸 스크립트 또는 HOW_TO_AGENTS.md 템플릿 변경 요청 시

## 단계
1. 요구사항 분석 — `.ai-agents/context/domain-overview.md` 참조
2. 영향 범위 파악 — HOW_TO_AGENTS.md 변경이면 모든 번역 파일에 영향
3. 구현
   - 셸 스크립트: `bash -n {파일}` 으로 문법 검증
   - Markdown: 구조 일관성 확인
4. 테스트
   - `shellcheck src/ai-agency.sh src/setup.sh` 실행
   - `bash -n src/ai-agency.sh && bash -n src/setup.sh` 문법 검증
5. 번역 파일 동기화 필요 여부 확인
6. PR 생성 — 루트 AGENTS.md의 글로벌 규약 준수

## 완료 조건
- shellcheck 경고 없음
- bash 문법 검증 통과
- 영문 원본 변경 시 번역 파일 동기화 완료 (또는 TODO 기록)
- PR 생성 완료

## 컨텍스트 의존
- `.ai-agents/context/domain-overview.md` — 프로젝트 목적과 정책 이해
