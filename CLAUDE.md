## 세션 시작
PM 에이전트(루트): 매 세션 시작 시 `AGENTS.md`(프로젝트 루트)를 읽고 지시를 따른다.
`.ai-agents/context/`가 존재하면 AGENTS.md의 컨텍스트 파일 섹션에 나열된 파일을 로딩한다.
서브에이전트: 자신의 `AGENTS.md`만 읽는다. 루트 AGENTS.md와 `.ai-agents/context/` 파일은 읽지 않는다.
