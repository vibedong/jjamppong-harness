# 짬뽕하네스

AI가 바로 코드를 만들지 않고, **질문 -> 기획 -> 승인 -> 실행 -> 검증** 순서로 움직이게 하는 안전 하네스입니다.

프로젝트 폴더에 하네스를 설치하면 Codex가 `AGENTS.md`와 `harness/` 규칙을 읽고, 사용자가 승인하지 않은 코드 작성, 테스트 생성, 패키지 설치, live access, commit, push를 하지 못하게 막습니다.

## Codex에게 설치시키기

Codex에게 아래처럼 말하면 됩니다.

```text
vibedong/jjamppong-harness.git <설치할_프로젝트_폴더>에 설치해줘.
설치 후 verify까지만 하고 멈춰.
기존 .git과 origin은 보존해줘.
```

`<설치할_프로젝트_폴더>`에는 실제 프로젝트 폴더 경로를 넣으면 됩니다.

## 설치 결과

정상 설치되면 대상 폴더 바로 아래에 하네스 파일이 생깁니다.

```text
<설치할_프로젝트_폴더>/
  AGENTS.md
  README.md
  CONTEXT.md
  handoff.md
  harness/
  modules/
  module-template/
  proposals/
  harness.lock.yaml
```

잘못된 설치입니다.

```text
<설치할_프로젝트_폴더>/jjamppong-harness/AGENTS.md
<설치할_프로젝트_폴더>/ourosuper-harness/AGENTS.md
```

하네스는 하위 폴더에 들어가는 앱이 아니라, 프로젝트 루트에 펼쳐지는 작업 규칙입니다.

## 하네스가 막는 것

- 설치만 했는데 PRD, issue, module, code를 바로 만드는 것
- 사용자 의도 질문 전에 기존 폴더부터 읽는 것
- plan review가 끝났다는 이유로 구현을 시작하는 것
- 폴더 구조 승인만 받고 코드, 테스트, fixture까지 만드는 것
- "좋아"를 넓은 승인으로 해석하는 것
- live target access, package install, commit, push를 묵시적으로 실행하는 것

## 실제 작업 흐름

설치 후 새 작업을 시작하면 Codex는 보통 이렇게 움직여야 합니다.

```text
1. 사용자 의도 질문
2. 필요한 자료조사
3. PRD / issue / module structure / writing plan 작성
4. plan review
5. 실제 작업 범위와 권한을 다시 질문
6. 승인된 범위만 구현
7. verify 후 사용자 확인
```

좋은 문서가 아니라, AI가 통과해야 하는 문을 만든다.
