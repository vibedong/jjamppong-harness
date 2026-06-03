# Gate Response Scenario Matrix

| Scenario | Gate question | User response | Expected gate result | Expected ledger result |
| --- | --- | --- | --- | --- |
| Narrow yes | Approve module structure only? | 좋아 | Opens module structure only | `Gate id: module_structure`, `Status: approved`; PRD drafting unlocked only; PRD approval, issues, writing plan, implementation remain locked |
| Adjacent technical question | Approve this module structure? | Selenium은 어떻게 해? | Gate stays locked | No approval entry; agent answers adjacent question then asks a narrower gate question |
| Deferred unknown requires named approval | Approve module structure only? | 좋아 | Module structure may open; unrelated unknown remains unresolved | No deferred unknown entry without an explicit user quote naming that unknown |
| PRD approval unlocks only issues | Approve PRD for issue decomposition? | ㅇㅇ | Opens issue decomposition only | `Gate id: prd`, `Status: approved`; issue approval, writing plan, implementation remain locked |
| Issue approval unlocks only writing plan | Approve issue breakdown? | 그렇게 하자 | Opens task brief and writing-plan only | `Gate id: issues`, `Status: approved`; implementation remains locked until `Gate id: plan_review`, `Status: completed` |
| Ambiguous gate question | 이 방향으로 갈까요? | 좋아 | Gate stays locked | No approval entry; agent asks a narrower question with explicit approval scope |
| Writing plan direction approval | 이 writing plan 방향 괜찮나요? | 좋아 | Plan direction may be recorded as feedback | Implementation remains locked; agent must ask the mandatory plan review choice before implementation |

This matrix is not a phrase list. It verifies whether the answer clearly responds to the immediately preceding gate question.
