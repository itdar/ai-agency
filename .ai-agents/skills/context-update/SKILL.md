# 스킬: 컨텍스트 업데이트

## 트리거
코드, 설정, 인프라, 문서, 비즈니스 규칙, 의존성 등의 변경으로 `.ai-agents/` 내 파일(context, roles, skills)이 현재 프로젝트 상태와 불일치할 때

## 단계
1. 변경된 영역 식별 (코드, 설정, 문서, 인프라 등 모든 유형)
2. 영향받는 `.ai-agents/` 파일 식별 (context, roles, skills)
3. 해당 파일 업데이트 및 상위/하위 AGENTS.md 일관성 확인
4. 검증: "이 파일만 읽고 새 세션에서 프로젝트를 정확히 설명할 수 있는가?"

## 완료 조건
- `.ai-agents/` 내 모든 파일(context, roles, skills)이 현재 프로젝트 상태와 일치
- 상위/하위 AGENTS.md 간 일관성 확인 완료
- 업데이트된 파일이 단독으로 읽혀도 정확한 정보를 제공

## 컨텍스트 의존
- `.ai-agents/context/domain-overview.md` — 현재 도메인 정보와 비교
