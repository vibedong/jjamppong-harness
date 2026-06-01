# OuroSuper Harness

OuroSuper Harness는 Codex에서 새 프로젝트를 시작할 때 정해진 흐름을 강제하기 위한 재사용 템플릿입니다.

목표는 사용자가 "ERP 프로젝트 만들고 싶어"처럼 자연스럽게 말해도 Codex가 바로 구현으로 뛰어들지 않고, 기획, 계획, 구현, 검증, 학습 정리까지 같은 흐름으로 움직이게 하는 것입니다.

## 기본 흐름

```text
OuroSuper 기획
-> Superpowers writing-plans
-> 필수 계획 리뷰 질문
-> Superpowers 구현 흐름
-> 검증
-> Compound Engineering ce-compound
-> 학습 반영 질문
-> 선택적 handoff
```

## 저장소 역할

`ourosuper-harness`는 하네스 원본이자 GitHub template 저장소입니다. 여기에는 재사용 규칙, 상태 저장 위치, 모듈 템플릿만 둡니다.

실제 프로젝트는 이 GitHub template 저장소에서 새 private 저장소로 생성합니다. 제품 코드는 생성된 프로젝트 저장소의 `modules/` 아래에만 둡니다. 하네스 원본 저장소에는 제품 코드를 만들지 않습니다.

## 주요 폴더

```text
harness/rules/
  Codex가 따라야 하는 workflow와 운영 규칙.

harness/state/
  OuroSuper, Superpowers, 검증, Compound Engineering 실행 중 생기는 현재 산출물.

docs/solutions/
  ce-compound가 만든 장기 학습 문서.

module-template/
  모듈 구조가 승인된 뒤 새 모듈에 복사되는 최소 템플릿.

proposals/
  아직 승인되지 않은 하네스 변경 후보. 승인 후 실제 규칙/문서에 반영하고 proposal 파일은 삭제.

modules/
  이 템플릿으로 생성된 실제 프로젝트에서만 제품/프로젝트 모듈이 들어가는 위치.
```

## 실제 프로젝트 시작하기

1. 이 저장소를 GitHub private template repository로 올립니다.
2. 새 프로젝트 이름과 slug를 정합니다. 예: `erp-system`.
3. GitHub에서 이 template을 사용해 새 private 프로젝트 저장소를 만듭니다.
4. 새 프로젝트 저장소를 로컬 `F:/Folder/projects/<project-name>` 아래에 clone합니다.
5. 이후 작업은 생성된 프로젝트 저장소 안에서 진행합니다.
6. 사용자가 "ERP 프로젝트 만들고 싶어"처럼 말하면, 생성된 프로젝트 저장소에서 `harness/state/intake.md`부터 시작합니다.
7. `harness/state/module-structure.md`가 승인되기 전에는 `modules/` 아래에 제품 코드를 만들지 않습니다.

Codex에게 새 프로젝트를 시작하라고 말할 때는 이렇게 말하면 됩니다:

```text
private 프로젝트로 <project-name> 만들어줘.
템플릿은 ourosuper-harness를 쓰고,
F:/Folder/projects/<project-name> 아래에서 시작해줘.
```

## Handoff

`handoff.md`는 채팅 로그가 아닙니다. 새 채팅에서 이어가기 위한 짧은 인수인계 파일입니다.

사용자가 새 채팅용 인수인계를 명시적으로 요청할 때만 갱신합니다.
