# 스킬: 긴급 수정 워크플로우

## 트리거
프로덕션 긴급 버그 수정 요청 시 (src/setup.sh 실행 실패, src/ai-agency.sh 오류, src/HOW_TO_AGENTS.md 템플릿 결함 등)

## 단계
1. 문제 재현 — 보고된 오류를 로컬에서 재현
2. 원인 분석 — 해당 스크립트 또는 템플릿의 문제 지점 특정
3. 핫픽스 브랜치 생성 — `hotfix/{설명}` 브랜치
4. 최소 범위 수정 — 문제 해결에 필요한 최소한의 변경만 수행
   - 셸 스크립트: `bash -n {파일}` 문법 검증
   - `shellcheck src/ai-agency.sh src/setup.sh` 통과 확인
5. 번역 영향 확인 — HOW_TO_AGENTS.md 변경 시 번역 파일 동기화 필요 여부 판단
6. PR 생성 — `hotfix:` 접두사 커밋, squash merge

## 완료 조건
- 문제 재현 → 수정 후 재현 불가 확인
- shellcheck 및 bash 문법 검증 통과
- 변경 범위가 최소한인지 확인
- PR 생성 완료

## 컨텍스트 의존
- `.ai-agents/context/domain-overview.md` — 프로젝트 정책 확인
