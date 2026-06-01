# OuroSuper Harness

OuroSuper Harness는 Codex가 새 프로젝트를 시작할 때 바로 코딩부터 하지 않도록 잡아주는 private template입니다.

이 저장소는 제품 코드가 들어가는 곳이 아닙니다. ERP, CRM, 업무 도구 같은 실제 프로젝트는 이 template에서 새 private 저장소를 만든 뒤 그 저장소에서 시작합니다.

## 언제 쓰나요?

새 프로젝트를 시작할 때 씁니다.

예를 들어 사용자가 이렇게 말해도:

```text
ERP 프로젝트 만들고 싶어
```

Codex는 바로 파일을 만들지 않고, 먼저 요청을 정리하고, 기획하고, 계획을 만들고, 리뷰하고, 검증한 뒤 구현하도록 안내됩니다.

## 가장 중요한 원칙

1. `ourosuper-harness`에는 제품 코드를 만들지 않습니다.
2. 실제 프로젝트는 이 template에서 새 private 저장소로 만듭니다.
3. `modules/` 아래에는 승인된 module structure가 생긴 뒤에만 제품 코드를 만듭니다.

## 실제 프로젝트 시작하기

Codex에게 새 프로젝트를 시작하라고 말할 때는 이렇게 말하면 됩니다:

```text
private 프로젝트로 <project-name> 만들어줘.
템플릿은 ourosuper-harness를 쓰고,
F:/Folder/projects/<project-name> 아래에서 시작해줘.
```

예:

```text
private 프로젝트로 erp-system 만들어줘.
템플릿은 ourosuper-harness를 쓰고,
F:/Folder/projects/erp-system 아래에서 시작해줘.
```

그 다음 흐름은 이렇습니다.

1. GitHub에서 `ourosuper-harness` template을 사용해 새 private 저장소를 만듭니다.
2. 새 저장소를 `F:/Folder/projects/<project-name>` 아래에 clone합니다.
3. 이후 작업은 생성된 프로젝트 저장소 안에서 진행합니다.
4. `harness/state/intake.md`에 요청을 정리합니다.
5. OuroSuper 기획부터 Full Workflow를 시작합니다.

## Codex 작업 흐름

```text
요청 정리
-> OuroSuper 기획
-> Superpowers writing-plans
-> 필수 계획 리뷰 질문
-> 구현
-> 검증
-> Compound Engineering ce-compound
-> 학습 반영 질문
-> 선택적 handoff
```

계획 리뷰를 생략할 수도 있지만, Codex는 먼저 위험을 설명하고 사용자 확인을 받아야 합니다.

## 폴더 구조

```text
harness/rules/
  Codex가 반드시 따라야 하는 workflow와 운영 규칙.

harness/state/
  현재 작업의 요청 정리, 기획 결과, 검증 결과, 실행 상태.

docs/solutions/
  ce-compound가 만든 재사용 가능한 학습 문서.

module-template/
  새 module을 만들 때 복사하는 최소 템플릿.

proposals/
  아직 승인되지 않은 harness/workflow 규칙 변경 제안.

modules/
  실제 프로젝트에서만 제품 코드가 들어가는 위치.
```

## 이 저장소에서 하지 않는 일

- 제품 코드 작성
- 임의 module 폴더 생성
- `handoff.md` 자동 갱신
- 승인 없는 live rule 변경
- `progress.md` 같은 별도 진행 파일 생성

## Handoff

`handoff.md`는 채팅 로그가 아닙니다. 새 채팅에서 이어가기 위한 짧은 인수인계 파일입니다.

사용자가 아래처럼 명시적으로 요청할 때만 갱신합니다.

```text
새 채팅에서 이어가게 만들어줘
인수인계 정리해줘
handoff 갱신해줘
다음 채팅용으로 정리해줘
여기까지 새 채팅용으로 저장해줘
```

## 한 줄 요약

`ourosuper-harness`는 실제 제품을 담는 저장소가 아니라, 실제 제품 저장소를 안전하게 시작하기 위한 private template입니다.
