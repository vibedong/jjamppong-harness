# Compound 자동분류와 산출물 라우팅 설계

## 목적

짬뽕하네스를 쓰는 사용자가 매번 "하네스 규칙을 지켜라", "grill me부터 해라", "필요한 문서를 읽어라"라고 다시 잡아주지 않아도 되게 만든다.

이 설계는 두 문제를 같이 해결한다.

1. 작업 중 생긴 하네스 이탈, 설치 오판, 승인 범위 오해 같은 반복 실수를 자동으로 후보 기록한다.
2. 각 게이트와 스킬이 어떤 산출물을 읽고 써야 하는지 계약으로 고정해서, AI가 필요한 파일을 추측하지 않게 한다.

## 범위

이번 설계의 대상은 하네스 템플릿 자체다. 제품 코드, 사용자 프로젝트의 실제 기능 코드, 크롤러, 웹앱, 업무 모듈은 대상이 아니다.

포함한다.

- compound learning 후보 자동분류
- active task 안의 `learning-capture.md` 후보 기록
- 장기 지식 승격 전 `compound_review` 게이트
- 산출물 목록을 정의하는 `artifact-registry`
- 게이트/스킬별 필수 읽기/쓰기 관계를 정의하는 `skill-artifact-map`
- read receipt 기반 verify/doctor 검증
- 사람이 읽는 문서는 사용자 언어로 작성하는 규칙 유지

포함하지 않는다.

- raw 대화 전문 저장
- 사용자 승인 없는 장기 규칙 반영
- 사용자 승인 없는 하네스 코어 자동 수정
- 제품 코드 자동 생성
- 외부 사이트 라이브 접근
- 패키지 설치, 커밋, 푸시 자동 실행

## 핵심 원칙

자동분류는 "사용자가 한 특정 문장"을 하드코딩하지 않는다. 대신 사건의 구조를 본다.

예를 들어 "왜 grill me 안 했지?"라는 문장 자체를 규칙으로 넣지 않는다. 그 대신 다음처럼 분류한다.

- 현재 게이트가 `grill` 이전인데 프로젝트 파일을 먼저 읽음
- `grill` 없이 `research`나 `prd`로 넘어감
- 사용자의 짧은 긍정을 과도한 승인으로 해석함
- 설치만 요청했는데 planning task를 만들기 시작함
- handoff가 필요한데 다음 채팅용 문구를 내지 않음

장기 지식은 자동으로 승격하지 않는다. 자동분류는 후보를 만들고, `compound_review`가 장기 반영 여부를 결정한다.

## 자동분류 카테고리

초기 카테고리는 넓게 시작한다. 세부 분류는 반복 사례가 쌓인 뒤 compound review에서 늘린다.

| 카테고리 | 의미 | 예시 |
| --- | --- | --- |
| `harness-drift` | 하네스 기본 흐름 이탈 | vowline, grill, writing plan, approval gate 누락 |
| `gate-order` | 게이트 순서 오류 | grill-with-docs를 grill me 전에 실행 |
| `artifact-routing` | 필요한 산출물 미열람 또는 과열람 | writing_plan이 PRD/issues/module_structure를 안 읽음 |
| `installer-flow` | 설치 흐름 오판 | 중첩 폴더 생성, origin 오판, npm 패키지 설치 오해 |
| `permission-boundary` | 승인 범위 해석 오류 | "좋아"를 commit/push 승인으로 확대 |
| `handoff-continuity` | 새 채팅 인계 흐름 누락 | handoff만 만들고 붙여넣을 프롬프트를 안 줌 |
| `human-doc-language` | 사람용 문서 언어 문제 | gate-ledger, handoff, planning 문서가 사용자 언어가 아님 |
| `verification-gap` | 검증 부족 | 완료라고 했지만 실제 설치 경로나 fresh-client 경로 검증 없음 |

## 산출물 레지스트리

새 계약 파일을 둔다.

```text
harness/contracts/artifact-registry.yaml
```

이 파일은 산출물의 역할을 정의한다.

필드 예시는 다음과 같다.

```yaml
artifacts:
  planning_prd:
    path: "planning/03-prd.md"
    audience: human
    language: user
    lifecycle: active_task
    purpose: "기획 확정"
    machine_canonical: false

  events_log:
    path: "events.jsonl"
    audience: machine
    language: stable_schema
    lifecycle: active_task
    purpose: "승인과 게이트 이벤트의 canonical log"
    machine_canonical: true
```

중요한 구분은 다음과 같다.

- `human`: 사용자가 읽는 문서. 사용자 언어를 따른다.
- `machine`: schema key가 안정적이어야 하는 문서. 임의 한글화하지 않는다.
- `canonical`: 충돌 시 진실로 보는 원천.
- `projection`: 사람이 보기 좋게 만든 요약. canonical과 충돌하면 canonical이 이긴다.
- `active_task`: 현재 작업 안에서만 뜨거운 컨텍스트.
- `long_term`: 다음 작업에서도 lookup 대상이 되는 지식.

## 스킬/게이트 산출물 맵

새 계약 파일을 둔다.

```text
harness/contracts/skill-artifact-map.yaml
```

이 파일은 각 게이트나 스킬이 무엇을 읽고 써야 하는지 정의한다.

예시는 다음과 같다.

```yaml
gates:
  grill:
    must_read:
      - user_prompt
      - prior_user_answers
    must_write:
      - planning_grill_summary
      - events_log
    must_not_read:
      - project_source_before_approval

  writing_plan:
    must_read:
      - planning_current_context
      - planning_prd
      - planning_issues
      - planning_module_structure
    must_write:
      - planning_writing_plan

  compound_lookup:
    must_read:
      - compound_state
      - solutions_index
      - selected_relevant_solutions
    must_write:
      - planning_compound_lookup

  compound_capture:
    must_read:
      - verification
      - acceptance
      - active_task_events
    must_write:
      - learning_capture
```

이 맵은 `gate-contract-matrix.yaml`을 대체하지 않는다. 더 세밀한 산출물 의존성 레이어로 추가한다. 충돌하면 canonical 계약 파일의 우선순위를 명확히 둔다.

## Read Receipt

AI가 "읽었다고 생각함"이 아니라, 실제로 어떤 산출물을 읽었는지 남긴다.

read receipt는 사람이 보기 좋은 projection과 검증 가능한 machine event를 함께 둔다.

기계용 canonical event 예시:

```json
{"type":"artifact_read","gate":"writing_plan","artifact":"planning_prd","path":"planning/03-prd.md","hash":"sha256:..."}
```

사람용 projection 예시:

```markdown
## 읽은 산출물

- PRD: `planning/03-prd.md`
- 이슈: `planning/04-issues.md`
- 모듈 구조: `planning/05-module-structure.md`
```

원칙:

- `events.jsonl`은 기계용 canonical이다.
- `gate-ledger.md`나 planning 문서의 read receipt는 사람이 읽는 projection이다.
- projection이 canonical과 충돌하면 검증은 실패한다.

## Compound 흐름

작업 중 문제 후보가 보이면 active task에만 기록한다.

```text
harness/docs/tasks/active/<task-id>/learning-capture.md
```

기록 내용:

- 분류 카테고리
- 짧은 사건 요약
- 왜 문제가 됐는지
- 재발방지 후보 규칙
- 관련 산출물이나 게이트
- 장기 승격 추천 여부

작업 말미에는 `compound_capture`가 후보를 정리한다.

그 다음 `compound_review`가 판단한다.

- 장기 지식으로 승격
- active task에만 보관
- 중복이라 기존 solution에 병합
- 오탐이라 폐기

승격된 지식만 다음 위치로 간다.

```text
harness/docs/solutions/index.md
harness/docs/solutions/harness-drift-patterns.md
harness/docs/solutions/installer-flow-patterns.md
harness/docs/solutions/planning-gate-patterns.md
harness/docs/solutions/permission-boundary-patterns.md
```

`harness/state/compound.md`는 짧은 인덱스만 가진다. 긴 본문은 `harness/docs/solutions/`에 둔다.

## 검증 방식

`verify`와 `doctor`는 다음을 확인해야 한다.

- 현재 게이트의 `must_read` 산출물에 대한 read receipt가 있는가
- 현재 게이트의 `must_write` 산출물이 존재하는가
- 금지된 산출물을 읽거나 쓴 흔적이 있는가
- 사람이 읽는 문서가 사용자 언어로 작성됐는가
- 기계용 파일의 schema key가 안정적으로 유지되는가
- `compound_capture` 후보가 장기 지식으로 바로 승격되지 않았는가
- `compound_review` 없이 `harness/docs/solutions/*.md`가 바뀌지 않았는가

초기 버전에서는 모든 누락을 실패로 만들지 않는다. 게이트 흐름을 깨는 항목은 실패, 품질 개선 항목은 경고로 시작한다.

실패로 둔다.

- `writing_plan`이 PRD, issues, module structure를 읽지 않음
- `compound_lookup`이 compound index를 읽지 않음
- `grill` 전에 프로젝트 소스나 과거 구현물을 사용자 의도처럼 읽음
- `compound_review` 없이 long-term solution이 수정됨

경고로 둔다.

- learning 후보가 하나도 없지만 작업 중 사용자 correction이 있었음
- 사람이 보는 projection의 설명이 너무 짧음
- solution index가 오래됐지만 직접 실패 증거는 없음

## 기대 시나리오

사용자가 새 프로젝트에서 말한다.

```text
나라장터에서 실시설계들을 크롤링해서 원하는 값만 추출하는 도구를 만들고 싶어.
기존 dailynara 폴더에 만든 게 있어.
```

하네스는 바로 코드를 읽지 않는다.

1. `intake`로 요청을 기록한다.
2. `grill`에서 목적, 사용 방식, 결과물 기준을 먼저 묻는다.
3. `research`에서 승인된 범위의 기존 폴더와 일반 근거를 확인한다.
4. `compound_lookup`에서 과거 하네스 이탈, 설치 오판, planning gate 누락 사례를 읽는다.
5. `module_structure`에서 폴더 구조를 먼저 제안한다.
6. `writing_plan`에서 PRD, 이슈, 모듈 구조를 읽은 receipt를 남긴다.
7. 작업 중 사용자가 "왜 grill me 안 했지?" 같은 correction을 하면 `learning-capture.md`에 `harness-drift` 후보를 남긴다.
8. 작업 끝에는 `compound_review`가 이 후보를 장기 지식으로 승격할지 결정한다.

## 성공 기준

이 설계가 잘 작동한다고 말하려면 다음이 통과해야 한다.

- 새 작업에서 게이트별 필수 산출물이 명확히 드러난다.
- AI가 필요한 산출물을 추측하지 않고 계약에서 찾는다.
- read receipt가 없으면 verify/doctor가 잡는다.
- 사용자 correction은 raw 대화 저장 없이 learning 후보로 요약된다.
- 장기 지식은 `compound_review` 없이 반영되지 않는다.
- 다음 작업의 `compound_lookup`이 관련 solution을 실제로 읽는다.
- 사용자가 반복해서 "그거 먼저 해야지"라고 잡아주는 빈도가 줄어든다.

## 구현 순서 제안

구현계획에서는 다음 순서가 적절하다.

1. `artifact-registry.yaml` 스키마와 초기 레지스트리 작성
2. `skill-artifact-map.yaml` 스키마와 핵심 게이트 맵 작성
3. `learning-capture.md`, `compound-review.md` 템플릿 추가
4. `harness/docs/solutions/index.md`와 초기 카테고리 파일 추가
5. workflow/rules에 자동분류와 산출물 라우팅 설명 반영
6. verify/doctor에 read receipt와 compound 승격 검증 추가
7. regression tests 추가
8. README에 초보자용 설명 추가

## 열린 결정

초기 구현에서는 automatic long-term promotion을 하지 않는다. 후보 기록은 자동이고, 장기 승격은 review gate를 거친다.

초기 구현에서는 카테고리를 넓게 유지한다. 세부 카테고리는 compound review에서 실제 반복 사례가 확인될 때 추가한다.

초기 구현에서는 read receipt를 `events.jsonl` canonical event로 둔다. 사람이 보는 projection은 gate-ledger나 각 planning artifact 안에 둔다.
