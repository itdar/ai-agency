# AGENTS.md 자동 생성 메타 지침서 v2

> 이 문서는 AI 에이전트가 읽고 **실행**하는 지침서다.
> 프로젝트 디렉토리 구조를 분석하여 AGENTS.md + 지식/스킬/역할 컨텍스트를 자동 생성한다.
>
> **핵심 원칙:**
> - ETH Zurich(2026.03): 추론 가능한 내용 기재 시 성공률 하락, 비용 +20%
> - **AGENTS.md에는 추론 불가능한 것만 기재한다**
> - **추론 비용이 높은 것**은 `.ai-agents/context/`에 별도 정리하고 AGENTS.md는 경로만 가리킨다
> - 모든 경로 참조는 상대 경로. 벤더 중립 — Claude, Codex, Cursor, 어떤 AI든 동일하게 동작

---

## Part A: 실행 지침

아래 7단계를 순서대로 실행하라.

### 1단계: 디렉토리 구조 스캔

```
최상위 디렉토리부터 depth 3까지 탐색한다.
숨김 디렉토리(.git, .idea, node_modules, __pycache__, .omc 등)는 제외한다.
각 디렉토리에 대해:
  - 포함된 파일 목록과 확장자 패턴을 기록한다
  - 하위 디렉토리 구조를 기록한다
  - README.md, package.json 등 메타 파일이 있으면 내용을 읽는다
```

### 1.5단계: 기존 벤더 컨텍스트 흡수

AGENTS.md를 생성하기 전에, 기존 AI 도구 설정 파일을 스캔하여 지식을 추출한다.
벤더 파일에 이미 기록된 컨벤션, 규칙, 도메인 지식이 벤더 중립적인 AGENTS.md + `.ai-agents/context/` 체계로 통합되도록 한다.

**스캔 대상 (존재하면 읽기):**

| 파일 / 디렉토리 | 도구 |
|---|---|
| `CLAUDE.md` | Claude Code |
| `.claude/settings.json` | Claude Code |
| `.cursor/rules/*.mdc` | Cursor |
| `.github/copilot-instructions.md` | GitHub Copilot |
| `.windsurfrules` | Windsurf |
| `.aider.conf.yml` | Aider |
| `AGENTS.md` (기존 존재) | Codex / 수동 작성 |

**추출한 내용을 아래 기준으로 분류 후 병합:**

| 분류 | 병합 대상 | 예시 |
|---|---|---|
| 컨벤션 | 루트 `AGENTS.md` → 글로벌 컨벤션 | 커밋 형식, 브랜치 네이밍, PR 규칙, 코드 스타일 |
| 권한 / 금지사항 | 루트 `AGENTS.md` → 글로벌 권한 | "main 직접 푸시 금지", "DB 스키마 변경 시 확인 필요" |
| 도메인 지식 | `.ai-agents/context/domain-overview.md` | 비즈니스 규칙, 서비스 설명, 아키텍처 노트 |
| API / 기술 스펙 | `.ai-agents/context/api-spec.json` 등 | API 엔드포인트, 데이터 모델, 인프라 정보 |
| 워크플로 절차 | `.ai-agents/skills/` | 배포 절차, 리뷰 체크리스트 |
| 도구 전용 설정 | 폐기 (이식 불가) | 모델 설정, IDE 단축키, 플러그인 설정 |

**규칙:**
- 맹목적으로 복사하지 않는다 — 분석, 중복 제거, 적절한 AGENTS.md 섹션에 정리한다
- 여러 벤더 파일에 동일한 컨벤션이 있으면, 글로벌 컨벤션에 하나의 정규 버전만 유지한다
- 도메인 지식이 파일 간에 충돌하면, 가장 상세한 버전을 유지하고 `<!-- VENDOR MERGE CONFLICT: {내용} -->`으로 표시한다
- 도구 전용 설정(모델명, IDE 단축키, 플러그인 설정)은 이식 불가 — 폐기한다
- AGENTS.md 생성 완료 후, 벤더 파일은 부트스트랩 인덱스로 변환한다 (7단계 참조)

**벤더 파일이 없으면:** 이 단계를 건너뛴다.

### 2단계: 디렉토리 유형 자동 판별

각 디렉토리의 파일 목록, 디렉토리 구조, 추론된 목적을 분석한다. **AI가 파일 패턴만 기계적으로 매칭하는 것이 아니라, 내용·목적·복잡도를 기반으로 해당 디렉토리가 독립 서브 프로젝트인지 직접 판단한다.**

이 판단은 코드 프로젝트, 비즈니스 문서 저장소, 연구 디렉토리, 데이터 분석 작업공간 등 모든 프로젝트 유형에 적용된다. 핵심 질문은 항상 같다: "이 디렉토리는 독립적인 정체성과 범위를 가지는가, 아니면 단순한 폴더 정리인가?"

**사전 분류 힌트:** 분류 전에 `.ai-agents/.classification.tsv`가 존재하면 읽는다. 형식: `directory\ttype\tevidence\tsubproject_hint`. 이 힌트를 출발점으로 사용하되, 자체 분석과 다를 경우 힌트를 무시한다 — TSV는 캐시일 뿐, 진실이 아니다.

아래 참조 표는 유형을 식별하는 데 유용한 파일 패턴 신호를 나열한다. 힌트로 활용하고, 최종 판단은 AI가 내린다.

**분류 참조 표 (힌트 — 최종 판단은 AI가 수행):**

| 우선순위 | 매칭 기준 | 유형 | 에이전트 인격 | 템플릿 |
|---|---|---|---|---|
| 1 | 파일: `deployment.yaml` + `service.yaml` + `ingress.yaml` | `k8s-workload` | 서비스 배포 전문가 | B-2 |
| 2 | 파일: `values.yaml` (Helm) | `infra-component` | SRE / Platform Engineer | B-3 |
| 3 | 파일: `*-appset.yaml` 또는 `ApplicationSet` 리소스 | `gitops-appset` | GitOps 전문가 | B-4 |
| 4 | 파일: `*-app.yaml` (ArgoCD Application) | `bootstrap` | 초기 설정 전문가 | B-5 |
| 5 | 파일: `package.json` + (`*.tsx` \| `*.vue` \| `*.svelte`) | `frontend` | 프론트엔드 엔지니어 | B-6 |
| 6 | 파일: `package.json` + (`*.ts` \| `*.js`) (프론트 프레임워크 없음) | `backend-node` | Node.js 백엔드 엔지니어 | B-7 |
| 7 | 파일: `go.mod` \| `go.sum` | `backend-go` | Go 백엔드 엔지니어 | B-7 |
| 8 | 파일: `pom.xml` \| `build.gradle` \| `build.gradle.kts` | `backend-jvm` | Java/Kotlin 백엔드 엔지니어 | B-7 |
| 9 | 파일: `requirements.txt` \| `pyproject.toml` \| `setup.py` | `backend-python` | Python 백엔드 엔지니어 | B-7 |
| 10 | 파일: `Dockerfile` + CI 설정 (`Jenkinsfile`, `.github/workflows/`, `Makefile`) | `cicd` | CI/CD 엔지니어 | B-11 |
| 11 | 파일: `.github/workflows/` 만 존재 | `github-actions` | GitHub Actions 전문가 | B-11 |
| 12 | 파일: `*.md` + (`*.pptx` \| `*.xlsx` \| `*.pdf` \| `*.docx`) 위주 | `docs-planning` | 기획자 / 테크니컬 라이터 | B-9 |
| 13 | 파일: `*.md` 위주 (기술 문서) | `docs-technical` | 테크니컬 라이터 | B-9 |
| 14 | 구조: 환경별 하위 디렉토리 (`dev/`, `staging/`, `prod/`, `real/`) 보유 | `env-config` | 환경 설정 관리자 | B-8 |
| 15 | 내용: 비즈니스 관련 파일 (계약서, 제안서, 매출 데이터 등) | `business` | 비즈니스 애널리스트 | B-10 |
| 16 | 내용: CS/고객 관련 문서 | `customer-support` | CS 운영 전문가 | B-10 |
| 17 | 구조: `secret/`, 인증서, 키 관련 디렉토리명 | `secrets` | 보안 전문가 | B-12 |
| 18a | 구조: 직접 파일 없이 하위 디렉토리만 보유, 그 중 2개 이상이 독립 서비스 유형 (자체 빌드 파일: `package.json`, `go.mod`, `pom.xml`, `pyproject.toml` 등 보유) | `domain-grouping` | 도메인 코디네이터 | B-13a |
| 18b | 구조: 직접 파일 없이 하위 디렉토리만 보유 (단순 폴더 정리) | `grouping` | 영역 관리자 | B-13b |
| 19 | (기타: 위 규칙 모두 불일치) | `generic` | 범용 에이전트 | B-14 |

**우선순위 18a 적용 시:** 해당 디렉토리는 도메인 경계를 나타낸다 (예: `commerce/`, `social/`, `platform/`). 하위 디렉토리가 동일 비즈니스 도메인을 공유하는 독립 서비스들이다. 도메인 코디네이터는 도메인 내 서비스 간 연계를 관리한다.

**우선순위 18b 적용 시:** 단순 폴더 정리 목적의 디렉토리이다 (예: `apps/`, `src/`, `packages/`). 의미 있는 도메인 경계가 아닌 조직적 그룹핑이므로 thin passthrough를 사용한다.

**우선순위 19 적용 시:** 파일 내용을 샘플링(상위 3개 파일의 첫 30줄)하여 맥락을 파악한 후 가장 가까운 유형을 재선택한다. 그래도 불명확하면 B-14(범용) 템플릿을 사용한다.

**빈 디렉토리:** Role과 Permissions만 포함하는 최소 AGENTS.md를 생성한다. "파일 추가 시 컨텍스트 갱신 필요" 메모를 남긴다.

#### 서브 프로젝트 판단 기준

위 표에서 유력한 유형을 파악한 후, 해당 디렉토리가 **독립 서브 프로젝트**인지 단순 폴더 정리인지 판단한다. 이 판단이 AGENTS.md + `.ai-agents/context/` 전체 생성 여부를 결정한다.

**독립 서브 프로젝트로 판단하는 조건 (하나 이상 해당):**
- 자체 빌드·패키지 시스템 보유 (`package.json`, `go.mod`, `pom.xml`, `pyproject.toml`, `Makefile` 빌드 타겟 등)
- 형제 디렉토리와 구별되는 독자적인 결과물 또는 목적이 있음
- 독자적인 팀 또는 이해관계자가 있거나 생길 수 있음 (별도 소유권, 별도 온콜, 별도 로드맵)
- 독립 저장소로 분리해도 정체성이 유지될 만큼 자립적임
- 이 디렉토리에서만 일하는 개발자에게 전용 컨텍스트가 필요할 만큼 도메인 특화 내용이 충분함 (이웃 디렉토리에서 추론 불가한 코드·규칙·지식 포함)

**독립 서브 프로젝트가 아닌 경우:**
- 자체 동작 없이 항목을 묶어두기만 하는 순수 정리 폴더 (예: `apps/`, `src/`, `packages/`)
- 부모의 설정 변형일 뿐인 디렉토리 (예: `dev/`, `staging/`, `prod/`, `overlays/`) — 부모 범위에 포함시킨다
- 독립 범위나 결과물이 없는 공유 유틸리티 디렉토리

**비코드 프로젝트에도 동일하게 적용한다.** 독자 방법론·데이터셋·결과 보고서를 가진 연구 디렉토리 = 서브 프로젝트. 재사용 파일만 보관하는 `templates/` = 서브 프로젝트 아님. 자체 계약서·지표·연락처를 가진 `clients/acme/` = 서브 프로젝트. `drafts/` 폴더 = 서브 프로젝트 아님.

#### 힌트 통합: `.ai-agents/.classification.tsv`

`.ai-agents/.classification.tsv`가 존재하면, 디렉토리 분류 전에 읽는다. 각 줄은 탭으로 구분된 네 개의 필드로 구성된다:

```
directory	type	evidence	subproject_hint
```

- `directory`: 프로젝트 루트로부터의 상대 경로 (예: `services/order-api`)
- `type`: 분류 표에서 이전에 할당된 유형 (예: `backend-node`)
- `evidence`: 분류 근거가 된 파일 패턴 또는 신호 (예: `package.json, *.ts`)
- `subproject_hint`: `yes`, `no`, `maybe` — 서브 프로젝트 여부에 대한 이전 판단

**힌트 활용 방법:**
- `subproject_hint`가 `yes` 또는 `no`이고 자체 분석과 일치하면, 캐시된 판단을 그대로 사용한다.
- 자체 분석이 힌트와 **다르면**, 힌트를 무시하고 이유를 기록한다. TSV는 이전 실행이 기록한 캐시 — 최신 상태가 아닐 수 있다.
- 파일이 없으면 이 단계를 건너뛴다. 분류 부산물로 생성 또는 갱신된다.

### 3단계: 컨텍스트 계층 생성

AGENTS.md 생성 전에, 프로젝트의 지식/행동/역할 컨텍스트를 먼저 구성한다.

#### 3-1. `.ai-agents/context/` 지식 파일 생성

프로젝트 분석 결과에서 **추론 비용이 높은 정보**를 사전 정리한다:

| 파일 | 대상 | 내용 | 생성 방법 |
|---|---|---|---|
| `domain-overview.md` | 모든 프로젝트 | 비즈니스 도메인, 정책, 제약사항, 레거시 특이사항 | 사람 초안 → AI Q&A로 정교화 |
| `data-model.md` | 백엔드 서비스 | 엔티티 정의, 관계도, 상태 전이 | AI 코드 분석 → 사람 검증 |
| `api-spec.json` | API 서비스 | Inbound/Outbound API, 관여 도메인, 부수효과 (JSON DSL) | AI 코드 분석 → DSL 변환 |
| `event-spec.json` | 이벤트 기반 | Kafka/MQ 발행/수신 메시지 스펙 (JSON DSL) | AI 코드 분석 → DSL 변환 |
| `infra-spec.md` | 인프라/DevOps | Helm 차트 관계, 네트워크 토폴로지, 배포 순서 | 사람이 작성 |
| `external-integration.md` | 외부 연동 | 써드파티 API 호출, 인증, rate limit | 사람이 작성 |

**생성 위치:**

컨텍스트 파일 배치는 명확한 원칙을 따른다: **프로젝트 전체에 해당하는 파일은 루트에**, **서브 프로젝트 전용 파일은 해당 서브 프로젝트에**.

| 위치 | 저장 대상 | 대표 파일 |
|---|---|---|
| 루트 `.ai-agents/context/` | 프로젝트 전체에 적용되는 내용 — 어느 서브 프로젝트에서 작업하든 공통으로 필요한 것 | `domain-overview.md`, `stakeholder-map.md`, `planning-roadmap.md`, `business-metrics.md` |
| 서브 프로젝트 `.ai-agents/context/` | 해당 서브 프로젝트의 도메인에 한정된 기술 파일 | `api-spec.json`, `data-model.md`, `event-spec.json`, `infra-spec.md`, `external-integration.md`, `ops-runbook.md` |

**특수 케이스:**
- **단일 서비스/단일 범위 프로젝트 (서브 프로젝트 없음):** 모든 파일을 루트 `.ai-agents/context/`에 둔다. 서브 프로젝트 디렉토리 불필요.
- **도메인 그룹핑 (`domain-grouping` 유형):** 집계된 컨텍스트를 도메인 디렉토리의 `.ai-agents/context/`에 둔다. 도메인 내 모든 하위 서비스의 교차 관심사를 커버한다 (예: 서비스 전체를 아우르는 도메인 수준 `api-spec.json`, 서비스 간 관계를 포함하는 `data-model.md`). 도메인 수준 컨텍스트가 이미 커버하는 경우 하위 서비스별 `.ai-agents/context/`를 중복 생성하지 않는다.
- **공유 지식:** 루트 `.ai-agents/context/`에 두고, 서브 프로젝트 AGENTS.md에서 참조만 한다. 중복 생성 금지.

**해당 사항 없는 파일은 생성하지 않는다.** 예: Kafka를 안 쓰면 event-spec.json 불필요.

**초기 생성 시 코드베이스를 분석하여 실제 내용을 채워넣는다.** 빈 파일에 TODO 마커만 넣고 끝내지 않는다. AI가 소스 코드, 설정 파일, 문서를 직접 읽고 분석하여 각 파일에 실제 내용을 채운다. 코드에서 추론이 진정으로 불가능한 항목(비즈니스 정책, 외부 API 인증 정보, SLA 세부사항 등)만 `<!-- HUMAN INPUT NEEDED: {이유} -->`로 표시한다.

**유형별 자동 생성 파일:**

| 디렉토리 유형 | 생성할 .ai-agents/context/ 파일 | 위치 |
|---|---|---|
| `backend-*`, `frontend` | `domain-overview.md`, `data-model.md`, `api-spec.json` | 서브 프로젝트 |
| `backend-*` + 이벤트 사용 | 위 + `event-spec.json` | 서브 프로젝트 |
| `frontend` | 위 + 백엔드 `api-spec.json` 참조 경로 | 서브 프로젝트 |
| `infra-component`, `k8s-workload` | `infra-spec.md` | 서브 프로젝트 |
| `business` | `domain-overview.md`, `business-metrics.md`, `stakeholder-map.md` | 서브 프로젝트 (서브 프로젝트 없으면 루트) |
| `customer-support` | `domain-overview.md`, `ops-runbook.md`, `stakeholder-map.md` | 서브 프로젝트 (서브 프로젝트 없으면 루트) |
| `docs-planning` | `domain-overview.md`, `planning-roadmap.md`, `stakeholder-map.md` | 서브 프로젝트 (서브 프로젝트 없으면 루트) |
| `domain-grouping` | `domain-overview.md`, `api-spec.json` (하위 서비스 집계), `data-model.md` (서비스 간 관계). 하위 서비스가 이벤트 사용 시 `event-spec.json` 추가. | 도메인 디렉토리 |
| 외부 API 연동 존재 | `external-integration.md` | 서브 프로젝트 |
| 루트 (PM) | `domain-overview.md`, `infra-spec.md`, `stakeholder-map.md` | 루트 |

**파일 생성 지침:**

`domain-overview.md` 생성 방법:
- README 파일, 코드 주석, 모듈 구조를 분석하여 비즈니스 목적 추론
- 유효성 검증 로직, 에러 메시지, 도메인 모델에서 비즈니스 규칙 식별
- 사람의 확인이 필요한 섹션만 `<!-- HUMAN INPUT NEEDED -->` 표시
- 출력 구조 예시:
```markdown
# {service_name} 도메인 개요

## 비즈니스 목적
{README, package.json description, 코드 구조에서 분석한 내용}

## 핵심 정책/제약사항
{유효성 검증 규칙, 에러 처리, 비즈니스 로직에서 추출}
<!-- HUMAN INPUT NEEDED: 코드에서 보이지 않는 비즈니스 규칙 확인 필요 -->

## 레거시 특이사항
<!-- HUMAN INPUT NEEDED: 코드에서 추론 불가능한 역사적 맥락 -->
```

`api-spec.json` 생성 방법:
- 모든 라우트/컨트롤러/핸들러 파일을 스캔하여 API 엔드포인트 발견
- 각 엔드포인트의 method, path, request/response 타입, 관여 도메인 추출
- 핸들러 코드에서 부수효과(DB 쓰기, 이벤트 발행, 외부 호출) 식별
- 출력은 플레이스홀더 예시가 아닌, 실제 분석된 완전한 내용이어야 함

`data-model.md` 생성 방법:
- 엔티티/모델/스키마 파일을 스캔하여 모든 엔티티 발견
- 필드명, 타입, 관계(외래키, 조인 테이블) 추출
- enum 필드와 상태 업데이트 로직에서 상태 전이 패턴 식별
- 관계도와 함께 완전한 엔티티 카탈로그 출력

`event-spec.json` 생성 방법:
- Kafka/MQ 프로듀서 및 컨슈머 설정 스캔
- 토픽명, 이벤트 타입, 페이로드 구조 추출
- 발행/수신 관계 매핑
- 코드에서 발견된 실제 이벤트 스펙 반영

`infra-spec.md` 생성 방법:
- Helm 차트, 배포 매니페스트, 인프라 설정 분석
- 컴포넌트 의존성과 배포 순서 매핑
- 서비스/인그레스 정의에서 네트워크 토폴로지 문서화
- 운영 세부사항 중 확인 필요한 것은 `<!-- HUMAN INPUT NEEDED -->` 표시

`external-integration.md` 생성 방법:
- HTTP 클라이언트 호출, SDK 연동, 외부 API 참조 스캔
- 코드에서 서비스명, 엔드포인트, 인증 방식 추출
- rate limit, SLA 세부사항은 `<!-- HUMAN INPUT NEEDED: Rate limit/SLA 세부사항 -->` 표시

#### 3-2. `.ai-agents/skills/` 행동 워크플로 생성

반복되는 작업 패턴을 표준화한다. **디렉토리를 생성하고 프로젝트에 맞는 실제 내용으로 스킬 파일을 채운다.**

**생성 규칙:** 실제 프로젝트 구조를 분석하여 각 SKILL.md를 커스터마이징한다. 1-2단계에서 발견한 실제 경로로 일반적인 경로를 교체한다. 예: 프로젝트가 `npm test` 대신 `pnpm test`를 쓰면 develop 스킬에 `pnpm test`를 기재한다.

```
.ai-agents/skills/
├── develop/SKILL.md       # 개발: 분석 → 설계 → 구현 → 테스트 → PR
├── deploy/SKILL.md        # 배포: 태그 → 배포 요청 → 검증
├── review/SKILL.md        # 리뷰: 체크리스트 기반 코드 리뷰
├── hotfix/SKILL.md        # 긴급 수정 워크플로
└── context-update/SKILL.md # .ai-agents/context/ 최신화 절차
```

**develop/SKILL.md** 생성 예시:
```markdown
# Skill: 개발 워크플로

## Trigger
새 기능 구현, 버그 수정 요청 시

## Steps
1. 요구사항 분석 — .ai-agents/context/domain-overview.md 참조
2. 영향 범위 파악 — .ai-agents/context/api-spec.json, data-model.md 참조
3. 설계 (필요 시)
4. 구현
5. 테스트 작성 및 실행
6. PR 생성 — 루트 AGENTS.md의 Global Conventions 준수

## Done Criteria
- 테스트 통과
- lint 통과
- PR 생성 완료

## Context Dependencies
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/api-spec.json`
```

**context-update/SKILL.md** 생성 예시:
```markdown
# Skill: 컨텍스트 최신화

## Trigger
코드 변경으로 .ai-agents/context/ 파일이 outdated 될 때

## Steps
1. 변경된 코드 영역 파악
2. 영향받는 .ai-agents/context/ 파일 식별
3. 해당 파일 업데이트
4. 검증: "새 세션에서 이 파일만 읽었을 때 정확한가?"

## Done Criteria
- .ai-agents/context/ 파일이 현재 코드와 일치
- JSON DSL 파일은 파싱 가능한 유효한 JSON
```

나머지 스킬(deploy, review, hotfix)도 동일 형식으로 프로젝트 분석 기반 생성.

각 SKILL.md에 포함할 것:
- **Trigger:** 언제 이 스킬을 사용하는가
- **Steps:** 수행 순서
- **Done Criteria:** 완료 조건
- **Context Deps:** 참조할 .ai-agents/context/ 파일

**주의 — 지식 vs 행동 분리 이유:**
- 지식(.ai-agents/context/): 세션 시작 시 명시적 로드 → 토큰 사용량 예측 가능
- 행동(.ai-agents/skills/): 필요 시 동적 로드 → 유연성
- 섞으면 토큰 예측 불가, 불필요한 정보가 컨텍스트 오염

#### 3-3. `.ai-agents/roles/` 역할 정의 생성

역할마다 필요한 컨텍스트 깊이가 다르다. **프로젝트에 존재하는 유형에 대해서만 역할 파일을 생성한다.** 3-1단계에서 발견한 실제 컨텍스트 파일 경로로 각 역할 파일을 채운다. 플레이스홀더 경로를 사용하지 않는다.

| 역할 | 로딩 전략 | 로드 대상 | 생성 조건 |
|---|---|---|---|
| PM | 선택적 지연 | 루트 AGENTS.md + 모든 하위 AGENTS.md (인덱스만) | 항상 |
| Domain Coordinator | 선택적 지연 | 도메인 AGENTS.md + 도메인 `.ai-agents/context/` + 하위 sub-AGENTS.md (인덱스만) | domain-grouping 유형 존재 시 |
| Backend | 완전 로딩 | 해당 서비스의 .ai-agents/context/ 전체 (domain-grouping 하위인 경우 도메인 컨텍스트 참조) | backend-* 유형 존재 시 |
| Frontend | 완전 로딩 | 프론트 .ai-agents/context/ + 백엔드 api-spec.json | frontend 유형 존재 시 |
| SRE/Infra | 선택적 지연 | infra-spec.md + 필요 시 서비스별 deployment 확인 | infra-component 유형 존재 시 |
| Business Analyst | 선택적 지연 | domain-overview.md + 사업 디렉토리 문서 | business 유형 존재 시 |
| Planner | 선택적 지연 | domain-overview.md + 기획 디렉토리 문서 | docs-planning 유형 존재 시 |
| CS Specialist | 선택적 지연 | domain-overview.md + 고객지원 디렉토리 문서 | customer-support 유형 존재 시 |
| Reviewer | 선택적 지연 | 리뷰 대상 서비스의 .ai-agents/context/ | 항상 |

**pm.md** 생성 예시:
```markdown
# Role: Project Manager

## Context Loading
세션 시작 시:
- 루트 `AGENTS.md` (Agent Tree 파악)
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/infra-spec.md` (있으면)

## Responsibilities
- 전체 아키텍처 파악, 작업 분배, 영향도 분석
- 하위 에이전트 간 cross-cutting 이슈 조율

## Constraints
- 하위 에이전트 도메인의 코드를 직접 수정하지 않음
- 설계 검증이 코드 검증보다 우선
```

**domain-coordinator.md** 생성 예시:
```markdown
# Role: Domain Coordinator

## Context Loading
세션 시작 시:
- 도메인 `AGENTS.md` (도메인 Agent Tree 파악)
- 도메인 `.ai-agents/context/domain-overview.md`
- 도메인 `.ai-agents/context/api-spec.json` (서비스 간 API 맵)
- 도메인 `.ai-agents/context/data-model.md` (서비스 간 관계)

필요 시 추가:
- 루트 `AGENTS.md` (도메인 간 에스컬레이션용)
- 하위 서비스 AGENTS.md (위임용)

## Responsibilities
- 도메인 내 서비스 간 변경 사항 조율
- 도메인 수준 API 계약 및 데이터 모델 일관성 관리
- 서비스 수준 작업을 하위 에이전트에게 위임
- 도메인 간 이슈는 루트 PM에게 에스컬레이션

## Constraints
- 하위 서비스 도메인의 코드를 직접 수정하지 않음
- 이 도메인 외부의 서비스를 수정하지 않음 (루트 PM에게 에스컬레이션)
- 서비스 간 계약 변경 시 영향받는 모든 하위 에이전트 검토 필요
```

**backend.md** 생성 예시:
```markdown
# Role: Backend Developer

## Context Loading
세션 시작 시 반드시:
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/data-model.md`
- `.ai-agents/context/api-spec.json`

필요 시 추가:
- `.ai-agents/context/event-spec.json`
- `.ai-agents/context/external-integration.md`

## Constraints
- 프론트엔드 코드 수정 금지
- 인프라 설정 변경 금지 (SRE에게 요청)
```

**sre.md** 생성 예시:
```markdown
# Role: SRE / Infrastructure

## Context Loading
세션 시작 시:
- `.ai-agents/context/infra-spec.md`
- 루트 `AGENTS.md` (전체 서비스 목록)

필요 시 추가:
- 각 서비스의 deployment.yaml, values.yaml

## Constraints
- 서비스 비즈니스 로직 수정 금지
- 프로덕션 설정 변경 시 반드시 Ask First
```

**reviewer.md** 생성 예시:
```markdown
# Role: Code Reviewer

## Context Loading
리뷰 대상 서비스의:
- `AGENTS.md` (컨벤션, 권한 확인)
- `.ai-agents/context/` 전체 (도메인 이해)

## Review Checklist
- 루트 Global Conventions 준수 여부
- 보안: 시크릿 노출, 인젝션
- 성능: N+1 쿼리, 불필요한 순회
- 테스트: 커버리지, 엣지 케이스
```

**business-analyst.md** 생성 예시:
```markdown
# Role: Business Analyst

## Context Loading
세션 시작 시:
- 루트 `AGENTS.md` (Agent Tree 파악)
- `.ai-agents/context/domain-overview.md`
- 사업 디렉토리 문서 (계약서, 제안서, 매출 데이터 등)

필요 시 추가:
- `.ai-agents/context/api-spec.json` (기술 역량 파악용)
- `.ai-agents/context/data-model.md` (데이터 구조 파악용)

## Responsibilities
- 사업/기획 문서 분석 및 요구사항 정리
- 개발 에이전트에게 전달할 스펙 작성
- 기술적 변경이 비즈니스에 미치는 영향 분석
- PM과 협력하여 cross-functional 의사결정 지원

## Constraints
- 코드 직접 수정 금지 (개발 에이전트에게 위임)
- 기술 아키텍처 결정 금지 (SRE/Backend에게 위임)
- 사업 문서 변경 시 이해관계자 확인 필요
```

**planner.md** 생성 예시:
```markdown
# Role: Planner / Technical Writer

## Context Loading
세션 시작 시:
- 루트 `AGENTS.md` (Agent Tree 파악)
- `.ai-agents/context/domain-overview.md`
- 기획 디렉토리 문서 (스펙, 로드맵, 아키텍처 문서)

필요 시 추가:
- `.ai-agents/context/api-spec.json` (기술적 실현 가능성 검증용)
- `.ai-agents/context/infra-spec.md` (인프라 제약 조건 파악용)

## Responsibilities
- 프로젝트 스펙, 로드맵, 아키텍처 문서 작성 및 유지
- 비즈니스 요구사항을 기술 스펙으로 변환
- 기능 진행 상황 추적 및 기획 문서 업데이트
- 사업 에이전트와 개발 에이전트 간 커뮤니케이션 중재

## Constraints
- 코드 직접 수정 금지 (개발 에이전트에게 위임)
- 승인된 스펙 임의 변경 금지 (이해관계자 서명 필요)
- 기술적 결정은 해당 개발 에이전트의 검증 필요
```

**cs-specialist.md** 생성 예시:
```markdown
# Role: CS Operations Specialist

## Context Loading
세션 시작 시:
- 루트 `AGENTS.md` (Agent Tree 파악)
- `.ai-agents/context/domain-overview.md`
- 고객지원 문서 (FAQ, 이슈 로그, SLA 문서)

필요 시 추가:
- `.ai-agents/context/api-spec.json` (이슈 진단을 위한 서비스 동작 파악용)
- `.ai-agents/context/external-integration.md` (서드파티 의존성 파악용)

## Responsibilities
- 고객 이슈 분석 및 패턴 파악
- 개발 에이전트에게 버그 리포트 및 기능 요청 전달
- CS 문서 유지 (FAQ, 런북, 에스컬레이션 절차)
- 기술적 변경이 고객에게 미치는 영향 평가

## Constraints
- 코드 직접 수정 금지 (개발 에이전트에게 이슈 보고)
- 개인정보 외부 전송 금지
- SLA 조건 및 계약사항 임의 변경 금지
```

### 4단계: AGENTS.md 생성

판별된 각 디렉토리에 대해 Part B 템플릿을 사용한다.

**Placeholder 규칙:** 모든 placeholder는 `{snake_case_english}`. `<!-- 추출 지침 -->` 주석 참고.

**생성 규칙:**
1. 모든 `{placeholder}`를 실제 값으로 치환. 주석은 최종 출력에서 제거.
2. 파일 분석으로 컨텍스트를 채운다.
3. **추론 가능한 내용은 쓰지 않는다** — 기재 금지:
   - 디렉토리 구조 설명, 일반 언어 문법, README 내용, 패키지 공식 문서
4. **추론 불가능한 것만 기재한다:**
   - 팀 컨벤션, 금지 사항, 보호 규칙, 커스텀 명령, 숨겨진 의존 관계, PR/커밋 포맷
5. **3단계에서 생성한 컨텍스트 파일 경로를 `Context Files` 섹션에 기재한다.**
6. 해당 사항 없는 섹션은 생략.

**글로벌 규칙 상속:** 루트 AGENTS.md의 `Global Conventions`는 모든 하위 에이전트에 자동 적용된다. 하위 AGENTS.md는 상속받은 규칙을 반복 기재하지 않고, 오버라이드가 필요한 것만 기재한다.

```
상속 흐름:
루트 AGENTS.md (Global Conventions)
  → 커밋: Conventional Commits
  → PR: 템플릿 필수
  → 리뷰: 최소 1명 approve
  → 언어: TypeScript strict
       │
       ▼ 자동 상속 (하위는 반복 기재 안 함)
  apps/api/AGENTS.md
    → 오버라이드만: "이 서비스는 Python 사용" (언어 규칙만 덮어쓰기)
```

### 5단계: 루트 PM Agent 생성

모든 하위 AGENTS.md를 생성한 후 최상위 `AGENTS.md`를 마지막에 생성한다.

**루트 AGENTS.md 필수 포함 요소:**
1. 프로젝트 Identity (PM 오케스트레이터)
2. 하위 에이전트 트리
3. 위임 규칙
4. **Global Conventions** (커밋, PR, 리뷰, 브랜치, 코딩 스타일 등)
5. **Global Permissions** (전역 금지 사항)
6. **Context Files** (루트 `.ai-agents/context/` 경로 인덱스)
7. cross-cutting 변경 시 프로토콜

### 6단계: 컨텍스트 최신화 규칙 설정

각 AGENTS.md에 `Context Maintenance` 섹션을 포함하여, 코드 변경 시 `.ai-agents/context/` 파일이 자동으로 최신화되도록 한다.

```
최신화 트리거:
─────────────
API 추가/변경/삭제 → api-spec.json 업데이트
DB 스키마 변경     → data-model.md 업데이트
이벤트 스펙 변경    → event-spec.json 업데이트
비즈니스 정책 변경  → domain-overview.md 업데이트
외부 연동 변경     → external-integration.md 업데이트
인프라 구성 변경    → infra-spec.md 업데이트
KPI/OKR 목표 변경  → business-metrics.md 업데이트
팀 구조 변경       → stakeholder-map.md 업데이트
운영 절차 변경     → ops-runbook.md 업데이트
마일스톤/로드맵 변경 → planning-roadmap.md 업데이트
```

### 7단계: 벤더 파일을 부트스트랩 인덱스로 변환

1.5단계에서 기존 벤더 파일의 내용을 흡수했다면, 해당 파일에는 이미 AGENTS.md + `.ai-agents/context/`에 병합된 지식이 들어 있다. 흡수된 내용을 AGENTS.md를 가리키는 경량 부트스트랩 인덱스로 교체한다.

**흡수된 각 벤더 파일에 대해:**

1. 원본 내용을 `.pre-agents.bak` 파일로 **백업** (내용 유실 방지)
2. 파일 내용을 부트스트랩 지시문으로만 **교체**
3. 이식 불가능한 도구 전용 설정은 벤더 파일에 **보존**

**예시 — CLAUDE.md 변환:**

변환 전 (흡수됨):
```markdown
# 프로젝트 가이드라인
## 컨벤션
- Conventional Commits 사용 (feat:, fix:, chore:)
- main 직접 푸시 금지
## 도메인
- 이 서비스는 주문 관리를 담당...
```

변환 후 (부트스트랩 인덱스):
```markdown
## Session Start
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.

<!-- 원본 내용은 AGENTS.md + .ai-agents/context/에 흡수됨 -->
<!-- 백업: CLAUDE.md.pre-agents.bak -->
```

**규칙:**
- 1.5단계에서 실제로 흡수한 파일만 변환한다
- 흡수할 내용이 없는 벤더 파일(도구 전용 설정만 있는 경우)은 그대로 두고 부트스트랩 지시문만 추가한다
- `.pre-agents.bak` 파일은 프로젝트 루트에 `{파일명}.pre-agents.bak` 패턴으로 생성한다
- `.gitignore`가 있으면 `.pre-agents.bak` 항목을 추가한다 (백업은 로컬 전용)

**1.5단계를 건너뛰었다면 (벤더 파일 없음):** 이 단계도 건너뛴다. 벤더 부트스트랩은 Part D의 부트스트랩 생성기로 신규 생성된다.

---

## Part B: 템플릿 라이브러리

### B-1. 루트 PM Agent

```markdown
# {project_name} <!-- README 또는 디렉토리명 -->

## Role
이 프로젝트의 PM 에이전트. 전체 구조를 파악하고 작업을 하위 에이전트에게 위임한다.

## Agent Tree
{agent_tree} <!-- 생성된 하위 AGENTS.md 트리 -->

## Context Files
- Domain: `.ai-agents/context/domain-overview.md`
- Infra: `.ai-agents/context/infra-spec.md`
{additional_context_files} <!-- 루트 레벨 컨텍스트 파일 경로 -->

## Session Start
세션 시작 시 위 Context Files와 Agent Tree를 읽어 전체 프로젝트를 파악하라.

## Delegation
- 단일 디렉토리 범위 → 해당 AGENTS.md 참조
- 복수 디렉토리 → 영향 범위 파악 후 각 에이전트에 분배
- 인프라 변경 → `infra/` 하위 에이전트
- 서비스 변경 → `apps/` 또는 `services/` 하위 에이전트

## Global Conventions
{global_conventions}
<!-- 여기에 프로젝트 전역 규칙 기재. 모든 하위 에이전트가 자동 상속. 예: -->
<!-- - Commits: Conventional Commits (feat:, fix:, chore:) -->
<!-- - PR: 템플릿 사용 필수, 최소 1명 리뷰 -->
<!-- - Branch: feature/{ticket}-{desc}, hotfix/{desc} -->
<!-- - Language: TypeScript strict, single quotes -->

## Global Permissions
- Never: {global_never}
- Ask First: {global_ask_first}

## Context Maintenance
이 AGENTS.md 또는 참조된 `.ai-agents/` 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경이 발생하면, 해당 파일을 즉시 업데이트하라. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
코드, 설정, 인프라, 문서, 비즈니스 규칙, 의존성 등 모든 유형의 변경에 적용된다.
최신화하지 않으면 다음 세션에서 잘못된 컨텍스트로 작업하게 된다.
```

### B-2. K8s 워크로드

```markdown
# {service_name} <!-- 디렉토리명 -->

## Role
{service_name} 서비스의 K8s 매니페스트 관리 전문가.

## Context Files
{context_file_paths} <!-- 해당 서비스의 .ai-agents/context/ 파일 경로. 없으면 섹션 생략 -->

## Session Start
위 Context Files를 읽고, 루트 AGENTS.md의 Global Conventions를 따르라.

## Context
- Image: {container_image} <!-- deployment.yaml → spec.containers[].image -->
- Port: {service_port} <!-- service.yaml → spec.ports[].port -->
- Host: {ingress_host} <!-- ingress.yaml → spec.rules[].host -->

## Conventions
- 이미지 태그 포맷: {image_tag_pattern}

## Permissions
- Always: 매니페스트 읽기, 설정 분석
- Ask First: 이미지 태그 변경, 리소스 limit/request 수정
- Never: 다른 서비스 디렉토리 수정, 시크릿 값 하드코딩

## Context Maintenance
이 AGENTS.md 또는 참조된 `.ai-agents/` 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경 시, 해당 파일을 즉시 업데이트하라. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
이미지 태그, 환경변수, 리소스 설정, 포트/호스트 변경 및 관련 설정 포함.
```

### B-3. 인프라 컴포넌트 (Helm)

```markdown
# {component_name} <!-- 디렉토리명 -->

## Role
{component_name} 인프라 컴포넌트의 SRE 전문가.
Helm 차트 기반 {component_purpose} 관리.

## Context Files
{context_file_paths} <!-- .ai-agents/context/infra-spec.md 등 -->

## Session Start
위 Context Files를 읽고, 루트 AGENTS.md의 Global Conventions를 따르라.

## Context
- Chart: {chart_info} <!-- values.yaml 또는 상위 appset에서 추출 -->
- Namespace: {namespace}
- Key Config: {custom_config} <!-- 추론 불가능한 커스텀 설정만 -->

## Dependencies
{infra_dependencies}

## Permissions
- Always: values.yaml 읽기, 설정 분석
- Ask First: values.yaml 수정, 새 리소스 추가
- Never: CRD 직접 수정, 네임스페이스 삭제, 프로덕션 설정 직접 변경

## Context Maintenance
이 AGENTS.md 또는 참조된 `.ai-agents/` 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경 시, 해당 파일을 즉시 업데이트하라. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
values.yaml, 차트 버전, 네임스페이스 설정, 의존성 및 관련 인프라 설정 포함.
```

### B-4. GitOps ApplicationSet

```markdown
# {appset_name} <!-- 파일명 -->

## Role
ArgoCD ApplicationSet 관리 전문가. 멀티클러스터/멀티환경 배포 조합 관리.

## Context
- Generator: {generator_type} <!-- generators 분석 -->
- Template: {template_summary}
- Sync Policy: {sync_policy}

## Permissions
- Always: AppSet YAML 읽기
- Ask First: generator 매트릭스 변경, sync policy 변경
- Never: 프로덕션 AppSet 삭제
```

### B-5. 부트스트랩

```markdown
# Bootstrap

## Role
클러스터 초기 설정 전문가. ArgoCD 자체관리 및 최초 Application 등록.

## Context
- Bootstrap Apps: {bootstrap_apps}
- 실행 순서: {boot_order}

## Permissions
- Always: 부트스트랩 YAML 읽기
- Ask First: 새 앱 추가, 기존 앱 수정
- Never: 부트스트랩 앱 삭제 (클러스터 전체 영향)
```

### B-6. 프론트엔드 서비스

```markdown
# {service_name} <!-- 디렉토리명 또는 package.json name -->

## Role
{service_name} 프론트엔드 엔지니어.

## Context Files
{context_file_paths}
<!-- 프론트엔드 .ai-agents/context/ + 백엔드 api-spec.json (API 연동 이해용) -->

## Session Start
위 Context Files를 읽고, 루트 AGENTS.md의 Global Conventions를 따르라.

## Commands
- Install: `{install_command}`
- Dev: `{dev_command}`
- Build: `{build_command}`
- Test: `{test_command}`

## Conventions
{frontend_conventions} <!-- 컴포넌트 네이밍, 상태 관리, 스타일링 방식 등 -->

## Permissions
- Always: 프론트엔드 코드 읽기/수정
- Ask First: 의존성 추가/삭제, 빌드 설정 변경
- Never: 백엔드 코드 수정, .env 커밋

## Context Maintenance
이 AGENTS.md 또는 참조된 `.ai-agents/` 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경 시, 해당 파일을 즉시 업데이트하라. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
API 연동, 컴포넌트 구조, 의존성, 라우팅, 상태 관리 및 관련 프론트엔드 설정 포함.
```

### B-7. 백엔드 서비스

```markdown
# {service_name} <!-- 디렉토리명 또는 모듈명 -->

## Role
{service_name} 백엔드 엔지니어. ({language})

## Context Files
- Domain: `.ai-agents/context/domain-overview.md`
- Data Model: `.ai-agents/context/data-model.md`
- API Spec: `.ai-agents/context/api-spec.json`
{additional_context} <!-- event-spec.json, external-integration.md 등 해당 시 -->

## Session Start
위 Context Files를 모두 읽고, 루트 AGENTS.md의 Global Conventions를 따르라.

## Commands
- Build: `{build_command}`
- Test: `{test_command}`
- Run: `{run_command}`

## Conventions
{coding_conventions}

## Permissions
- Always: 이 서비스 코드 읽기/수정, 테스트 실행
- Ask First: DB 스키마 변경, 외부 API 연동 추가
- Never: 다른 서비스 코드 수정, 프로덕션 DB 직접 접근, 시크릿 하드코딩

## Context Maintenance
이 AGENTS.md 또는 참조된 `.ai-agents/` 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경 시, 해당 파일을 즉시 업데이트하라. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
- API 추가/변경/삭제 → `api-spec.json` 업데이트
- DB 스키마 변경 → `data-model.md` 업데이트
- 이벤트 스펙 변경 → `event-spec.json` 업데이트
- 도메인 정책 변경 → `domain-overview.md` 업데이트
- 의존성/설정 변경 → 관련 컨텍스트 파일 업데이트
```

### B-8 ~ B-14. (간결 버전)

나머지 템플릿은 B-1~B-7과 동일한 패턴으로 작성한다. 핵심 차이점만 기재:

**B-8. 환경 설정** — Role: 환경별 설정 관리자. Context: env 목록, config 포맷. Never: prod 직접 변경.

**B-9. 문서/기획** — Role: 기획자/테크니컬 라이터. Context: 문서 유형, 포맷. Never: 승인된 스펙 임의 변경.

**B-10. 사업/CS** — Role: 비즈니스 애널리스트/CS 전문가. Never: 계약 임의 변경, 개인정보 외부 전송.

**B-11. CI/CD** — Role: CI/CD 엔지니어. Context: CI 도구, 파이프라인 목록. Never: 프로덕션 파이프라인 삭제.

**B-12. 보안/시크릿** — Role: 보안 전문가. Never: 시크릿 평문 기재, Git 커밋, 로그 출력.

**B-13a. 도메인 그룹핑 디렉토리**

```markdown
# {domain_name} <!-- 디렉토리명 -->

## Role
{domain_name}의 도메인 코디네이터. 도메인 내 서비스 간 연계를 관리하고 서비스 수준 작업을 하위 에이전트에게 위임한다.

## Agent Tree
{domain_agent_tree} <!-- 도메인 내 sub-AGENTS.md 트리 -->

## Context Files
- Domain: `.ai-agents/context/domain-overview.md`
{additional_domain_context_files} <!-- 도메인 수준으로 집계된 api-spec.json, data-model.md 등 -->

## Session Start
위 Context Files와 Agent Tree를 읽는다. 루트 AGENTS.md의 Global Conventions를 따른다.

## Delegation
- 단일 서비스 범위 → 해당 서비스의 AGENTS.md 참조
- 도메인 내 서비스 간 연계 → 하위 에이전트 간 조율
- 도메인 외부 → 루트 PM에게 에스컬레이션

## Domain Conventions
{domain_conventions} <!-- 루트 Global Conventions 대비 오버라이드만. 없으면 생략 -->

## Permissions
- Always: 도메인 내 모든 서비스 코드 읽기, 서비스 간 변경 조율
- Ask First: 서비스 간 계약 변경 (API, 이벤트, 공유 데이터 모델)
- Never: 하위 에이전트 도메인의 코드 직접 수정, 도메인 외부 서비스 수정

## Context Maintenance
이 AGENTS.md 또는 참조된 `.ai-agents/` 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경 시, 해당 파일을 즉시 업데이트하라. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
코드, 설정, 서비스 간 계약, 공유 데이터 모델 등 도메인 내 모든 관련 변경 포함.
도메인 간 API 변경 → 루트 PM에게 조율 요청.
```

**B-13b. 그룹핑 디렉토리** — Role: 영역 관리자. 하위 에이전트 목록 + 위임 규칙만. 자체 컨텍스트 파일 없음. Never: 하위 도메인 직접 수정.

**B-14. 범용** — Role: 파일 샘플링 기반 추론. 최소한 Permissions만이라도 기재.

**공통 패턴:** 모든 템플릿에 `Context Files`, `Session Start`, `Context Maintenance` 섹션을 포함한다. 해당 사항 없으면 생략.

---

## Part C: 컨텍스트 설계 가이드

### C-1. `.ai-agents/context/` 지식 파일 설계

**원칙:** 매 세션마다 전체 코드를 읽는 대신, 사전 정리된 지식으로 즉시 작업한다.

**기재 여부 판단 기준:**

| 구분 | 기재 위치 | 예시 |
|---|---|---|
| 추론 불가능 | AGENTS.md | 컨벤션, 금지사항, 숨겨진 의존관계 |
| 추론 가능 + 비용 높음 | `.ai-agents/context/` | 전체 API 맵, 데이터 모델 관계도, 이벤트 스펙 |
| 추론 가능 + 비용 낮음 | 기재 금지 | 디렉토리 구조, 단일 파일 내용, 프레임워크 사용법 |

**AI 활용 생성 프로토콜**

```
1단계: AI에게 코드 분석 요청
   "현재 {service_name}의 API를 전부 분석해"

2단계: DSL 구조 제안 요청
   "분석한 API를 새 세션에서도 기억할 DSL 구조를 제안해"

3단계: 반복 피드백
   - 틀리면: "힌트 — {관련_도메인}을 다시 살펴봐"
   - 맞으면: "이 내용을 .ai-agents/context/에 기록해"

4단계: 검증
   "새 세션이라고 가정하고, 이 .ai-agents/context/ 파일만 읽었을 때
    {service_name}을 정확히 설명할 수 있는지 테스트해봐"
```

### C-2. `.ai-agents/skills/` 행동 워크플로 설계

**SKILL.md 표준 형식:**

```markdown
# Skill: {skill_name}

## Trigger
{언제 이 스킬을 사용하는가}

## Steps
1. {단계 1}
2. {단계 2}
...

## Done Criteria
- {완료 조건 1}
- {완료 조건 2}

## Context Dependencies
- `.ai-agents/context/{file}` — {왜 필요한지}
```

**권장 스킬 목록:**

| 스킬 | 트리거 | 핵심 단계 |
|---|---|---|
| develop | "이 기능 구현해" | 분석 → 설계 → 구현 → 테스트 → PR |
| deploy | "배포해" | 태그 생성 → 배포 요청서 → 검증 |
| review | "리뷰해" | 체크리스트 기반 코드 리뷰 |
| hotfix | "긴급 수정" | 원인 분석 → 최소 수정 → 테스트 → 긴급 배포 |
| context-update | "컨텍스트 업데이트" | 변경 사항 분석 → .ai-agents/context/ 파일 갱신 |

### C-3. 글로벌 규칙 상속 패턴

**원칙:** 글로벌 규칙은 루트 AGENTS.md 한 곳에만 기재. 하위는 자동 상속. 오버라이드만 기재.

**루트 AGENTS.md `Global Conventions`에 기재할 것:**

```markdown
## Global Conventions

### Commit
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- 본문에 Why 포함, 제목 50자 이내

### Branch
- feature/{ticket-id}-{description}
- hotfix/{description}
- main 직접 push 금지

### PR
- 템플릿 사용 필수
- 최소 1명 approve 후 merge
- squash merge 사용

### Code Style
- {language}: {linter/formatter 설정}
- 프레임워크: {선택한 프레임워크}

### Review
- 보안, 성능, 테스트 커버리지 확인
- AI 코드는 신입 개발자의 제안으로 취급하여 검토
```

**하위 AGENTS.md에서의 오버라이드:**

```markdown
## Conventions (Override)
<!-- 루트의 Global Conventions를 상속하되, 아래 항목만 다르게 적용 -->
- Language: Python 3.12 (루트의 TypeScript 대신)
- Formatter: black + isort
```

**오버라이드가 필요 없는 하위 AGENTS.md:**
```markdown
## Session Start
루트 AGENTS.md의 Global Conventions를 따르라.
```

### C-4. JSON DSL 설계 가이드

**api-spec.json 표준:**

```json
{
  "service": "{service_name}",
  "apis": [
    {
      "method": "POST",
      "path": "/api/v1/orders",
      "request": "CreateOrderRequest",
      "response": "CreateOrderResponse",
      "domains": ["Order", "Payment"],
      "sideEffects": ["kafka:order-created", "db:orders.insert"],
      "externalCalls": [
        {"service": "payment-api", "endpoint": "POST /api/v1/payments"}
      ]
    }
  ]
}
```

**event-spec.json 표준:**

```json
{
  "service": "{service_name}",
  "publish": [
    {"topic": "order-events", "event": "OrderCreated", "payload": "OrderCreatedEvent"}
  ],
  "subscribe": [
    {"topic": "payment-events", "event": "PaymentCompleted", "handler": "PaymentCompletedHandler"}
  ]
}
```

**토큰 효율:** 자연어 ~200토큰 → JSON DSL ~70토큰 (3배 절약).

### C-5. 세션 복원 프로토콜

```
세션 시작 시:
1. AGENTS.md 읽기 (대부분 AI 도구가 자동)
2. Context Files 경로를 따라 .ai-agents/context/ 로드
3. .ai-agents/context/current-work.md 확인 (진행 중 작업 있으면)
4. git log --oneline -10으로 최근 변경 파악

세션 종료 시:
1. 진행 중 작업 → .ai-agents/context/current-work.md에 기록
2. 새로 알게 된 도메인 지식 → 해당 .ai-agents/context/ 파일 업데이트
3. 미완료 TODO → 명시적 기록
```

### C-6. 컨텍스트 최신화 규칙

AGENTS.md에 `Context Maintenance` 섹션으로 기재한다:

```markdown
## Context Maintenance
이 AGENTS.md 또는 참조된 `.ai-agents/` 파일(context, roles, skills)에 기술된 내용에 영향을 주는 변경이 발생하면, 해당 파일을 즉시 업데이트하라. 상위/하위 AGENTS.md 간 일관성을 유지할 것.
코드, 설정, 인프라, 문서, 비즈니스 규칙, 의존성 등 모든 유형의 변경에 적용된다.
- API 변경 → `.ai-agents/context/api-spec.json` 업데이트
- 스키마 변경 → `.ai-agents/context/data-model.md` 업데이트
- domain-overview.md와 충돌 시 해당 문서도 수정
- 최신화하지 않으면 다음 세션에서 오래된 컨텍스트로 작업하게 됨
```

---

## Part D: 참고 사항

### D-1. 기재 기준 요약

| 기재 O (추론 불가) | .ai-agents/context/ (추론 비용 높음) | 기재 X (추론 비용 낮음) |
|---|---|---|
| 커스텀 빌드/테스트 명령 | 전체 API 맵 | 디렉토리 구조 |
| 팀 컨벤션, 네이밍 규칙 | 데이터 모델 관계도 | 단일 파일 내용 |
| 금지 사항 (Never) | 이벤트 발행/수신 스펙 | README 내용 |
| PR/커밋 포맷 | 서비스 간 호출 관계 | 패키지 공식 문서 |
| 보호 규칙 | 인프라 토폴로지 | import 관계 |
| .ai-agents/context/ 경로 | 비즈니스 도메인 정책 | 표준 문법 |

### D-2. 토큰 최적화

- AGENTS.md 1개당 **300토큰 이내** (치환 후 기준)
- .ai-agents/context/ JSON DSL은 자연어 대비 3배 절약
- 해당 없는 섹션은 생략

### D-3. 도구별 호환

| 도구 | AGENTS.md 인식 | 자체 파일 |
|---|---|---|
| Claude Code | O (fallback) | `CLAUDE.md` |
| OpenAI Codex | O (primary) | - |
| GitHub Copilot | △ | `copilot-instructions.md` |
| Cursor | △ | `.cursor/rules/*.mdc` |
| Aider | O | `.aider.conf.yml` |

동기화:

```bash
# scripts/sync-ai-rules.sh
AGENTS="AGENTS.md"
mkdir -p .cursor/rules .github
cp "$AGENTS" .github/copilot-instructions.md
printf -- '---\ndescription: Project guidelines\nglobs: "**/*"\n---\n' > .cursor/rules/project.mdc
cat "$AGENTS" >> .cursor/rules/project.mdc
```

### D-4. AGENTS.md 탐색 우선순위

```
~/.codex/AGENTS.md            ← 글로벌
  └── project-root/AGENTS.md  ← 프로젝트 루트 (Global Conventions 포함)
       └── src/api/AGENTS.md  ← 하위 (가까울수록 우선, 상위 상속)
            └── AGENTS.override.md ← 같은 레벨 최우선
```

### D-5. 계층적 에이전트 운용 패턴

```
┌──────────────────────────────────────────┐
│  루트 PM Agent (AGENTS.md)                │
│  Global Conventions + 위임 규칙            │
│  설계 검증이 코드 검증보다 중요!                │
└────────┬─────────┬─────────┬─────────────┘
         │         │         │  작업 위임
    ┌────▼────┐ ┌───▼───┐ ┌──▼─────┐
    │서비스 A   │ │인프라  │ │문서     │  각 디렉토리 Agent
    │전문가     │ │SRE    │ │기획자   │  (Global Conventions 상속)
    └─────────┘ └───────┘ └────────┘
```

**위임 프로토콜:**
- 상위 → 하위: "이 디렉토리의 AGENTS.md를 읽고, 해당 범위 내에서 작업하라"
- 하위 → 상위: 작업 완료 후 변경 사항 요약 보고
- 동일 레벨: 상위 에이전트를 통해 간접 조율

### D-6. 실전 적용 체크리스트

```
Phase 1 (기본)              Phase 2 (컨텍스트)           Phase 3 (운용)
──────────────             ──────────────────         ──────────────
☐ AGENTS.md 생성           ☐ .ai-agents/context/ 생성     ☐ .ai-agents/roles/ 정의
☐ 빌드/테스트 명령            ☐ domain-overview.md          ☐ ai-agency.sh
☐ 컨벤션, 금지사항            ☐ api-spec.json (DSL)         ☐ 멀티에이전트 세션
☐ Global Conventions       ☐ data-model.md               ☐ .ai-agents/skills/ 워크플로
☐ 도구별 포워더              ☐ 최신화 규칙 설정                 ☐ 반복 피드백 루프
```
