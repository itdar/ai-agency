# 스킬: 배포/릴리즈 워크플로우

## 트리거
새 버전 릴리즈 또는 배포 요청 시

## 단계
1. 현재 상태 확인 — `git status`, `git log` 로 미커밋 변경 확인
2. 버전 결정 — Conventional Commits 기반 semver 판단
3. 릴리즈 준비
   - README.md 및 HOW_TO_AGENTS.md 최신 상태 확인
   - 번역 파일 동기화 여부 확인 (`docs/` 내 모든 언어 파일)
   - `shellcheck src/ai-agency.sh src/setup.sh` 통과 확인
   - `bash -n src/ai-agency.sh && bash -n src/setup.sh` 문법 검증
4. 태그 생성 — `git tag -a v{버전} -m "{릴리즈 메시지}"`
5. 변경 이력 정리 — 주요 변경사항 요약

## 완료 조건
- 모든 셸 스크립트 검증 통과
- 번역 파일이 영문 원본과 동기화됨
- 태그 생성 완료
- 릴리즈 노트 작성 완료

## 컨텍스트 의존
- `.ai-agents/context/domain-overview.md` — 프로젝트 정책 및 산출물 확인
