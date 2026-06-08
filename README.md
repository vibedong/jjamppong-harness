# 짬뽕하네스

AI가 바로 코드를 만들지 않고, **질문 -> 기획 -> 승인 -> 실행 -> 검증** 순서로 움직이게 하는 안전 하네스입니다.

프로젝트 폴더에 하네스를 설치하면 Codex가 `AGENTS.md`와 `harness/` 규칙을 읽고, 사용자가 승인하지 않은 코드 작성, 테스트 생성, 패키지 설치, live access, commit, push를 하지 못하게 막습니다.

## Codex에게 설치시키기

npm에 공개된 패키지로 설치할 수 있습니다. Codex에게 아래처럼 말하면 됩니다.

```text
jjamppong-harness@latest를 설치해줘.
설치할 위치는 내가 말한 프로젝트 폴더를 사용해줘.
설치 후 verify까지만 하고 멈춰.
기존 .git과 origin은 보존해줘.
```

직접 명령으로 실행할 때는 이렇게 씁니다.

```powershell
npx jjamppong-harness@latest install --target 원하는-프로젝트-폴더
```

GitHub 저장소 방식도 계속 사용할 수 있습니다.

```text
vibedong/jjamppong-harness.git 설치해줘.
설치할 위치는 내가 말한 프로젝트 폴더를 사용해줘.
설치 후 verify까지만 하고 멈춰.
기존 .git과 origin은 보존해줘.
```

설치할 폴더는 Codex에게 말할 때 같이 지정하면 됩니다.

## 설치 결과

정상 설치되면 대상 폴더 바로 아래에 하네스 파일이 생깁니다.

```text
프로젝트 폴더/
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
프로젝트 폴더/jjamppong-harness/AGENTS.md
프로젝트 폴더/ourosuper-harness/AGENTS.md
```

하네스는 하위 폴더에 들어가는 앱이 아니라, 프로젝트 루트에 펼쳐지는 작업 규칙입니다.

## 자주 보이는 문구와 파일

Gate id는 지금 어느 단계의 허락을 받는지 보여주는 이름표입니다.

예를 들어 `Gate id: implementation`이 보이면 "이제 구현을 시작해도 되는지 묻는 단계"라는 뜻입니다.

자주 보이는 예시는 `Gate id: planning`, `Gate id: implementation`, `Gate id: handoff`입니다.

events.jsonl은 실제 승인 기록 원본입니다. 작업이 진행되면 events.jsonl에 새 줄이 추가될 수 있습니다. 이 파일이 바뀌는 것은 정상입니다. 다만 기존 기록을 마음대로 고쳐 쓰면 안 됩니다.

gate-ledger.md는 사람이 읽기 쉽게 정리한 승인 기록입니다. AI가 상황 파악용으로 읽을 수는 있지만, 권한 판단의 원본은 `events.jsonl`입니다.

task.yaml은 현재 상태를 빠르게 읽는 요약 파일입니다. 이것도 권한 원본은 아닙니다.

handoff.md는 새 채팅으로 넘길 상태 요약입니다. handoff.md를 만든 뒤에는 다음 채팅에 붙여넣을 프롬프트를 채팅 응답으로 출력합니다.

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
