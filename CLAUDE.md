## 세션 시작
CWD 기준 가장 가까운 `AGENTS.md`만 읽고 지시를 따른다.
상위 디렉토리의 `AGENTS.md`, `.ai-agents/context/`, `CLAUDE.md`는 읽지 않는다.

PM 에이전트(루트): 루트 `AGENTS.md`를 읽고, `.ai-agents/context/`가 있으면 AGENTS.md의 컨텍스트 파일 섹션에 나열된 파일을 로딩한다.
서브에이전트: 자신의 `AGENTS.md`만 읽는다. 루트 AGENTS.md와 루트 `.ai-agents/context/`는 읽지 않는다.
