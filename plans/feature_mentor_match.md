# Feature — Mentor Match (replaces single Questionnaire flow)

> Replaces the legacy `QuestionnaireView` in the **Match** tab with a track-aware
> two-wizard flow: learners pick **Financial Guidance** or **Career Mentorship**,
> then walk through a tailored set of questions and land on a matched mentor card.

**Status:** 🟢 Ready for PR
**Branch:** `feature/mentor-match`
**Base:** `feature/finance-readiness-ladder` (treated as merged).
**Source commit:** integrated from `questionnaire-updated@b656105`.
**ATDD:** acceptance tests live in `Group-14Tests/Features/MentorMatch/MentorMatchAcceptanceTests.swift`.

---

## Discuss — User-facing behavior

1. The **Match** tab now shows two TrackCards: *Financial Guidance* and *Career Mentorship*. Each pushes onto a dedicated wizard via `NavigationStack`.
2. **FinancialMatchView** — 7 steps:
   1. Intent ("what's bringing you here today?")
   2. Who You Are (gender, year, school type, optional major)
   3. First-Gen Status
   4. Financial Standing
   5. Confidence (1–5)
   6. Financial Accounts (multi-select) + Concern
   7. Mentor Preferences (cap 2) + Support Style
3. **CareerMatchView** — 6 steps: Intent, Who You Are, First-Gen Status, Career Journey, Confidence, Mentor Preferences.
4. **Per-step gating:** the *Next* button is disabled until the required field(s) for the step are filled. The mentor-preference multi-select caps at 2 picks.
5. **Submit** transitions to a 1.5s loading screen, then a `MatchResultView` showing the first mentor from the relevant pool (`financialMentorPool` / `careerMentorPool`).
6. **No backend wiring yet** — `submit()` just sleeps and picks the first entry from a static mentor pool. The wire format (`FinancialMatchRequest` / `CareerMatchRequest` in [MentorMatchModels.swift](../Group-14/Features/MentorMatch/Models/MentorMatchModels.swift)) is Codable-ready for when a real `/match` endpoint is added.

---

## Integration notes

### Why this isn't a straight cherry-pick

`questionnaire-updated@b656105` ships an updated `MainTabView.swift` that predates:

- the role-aware tab structure (learner vs mentor),
- the Inbox tab, and
- the `MentorThreadView` → `ThreadFeedView` rename.

A direct cherry-pick would silently regress all of the above. Instead we cherry-applied the six new MentorMatch files verbatim and made a **one-line edit** in `MainTabView.swift` — swap `QuestionnaireView()` for `MentorMatchView()` inside the existing role-aware learner block.

### Orphaned legacy questionnaire (deferred)

`Group-14/Features/Questionnaire/{Models,ViewModels,Views}` is now unreachable from the running app. It is intentionally **not deleted** in this PR because:

- The backend `POST /questionnaire` endpoint still awards `+30` to first-time Financial submitters as part of the Finance Readiness Ladder. Deleting the only client caller silently drops that earning event.
- Resolving that gap (either wire MentorMatch.submit() to `/questionnaire` for Financial submissions, or move the +30 trigger elsewhere) is a separate, scoped change.

A follow-up issue should track removing the orphaned files once the +30 path is re-homed.

---

## Plan

### iOS — Step 1 (ATDD) — [x] Done

- [x] `Group-14Tests/Features/MentorMatch/MentorMatchAcceptanceTests.swift`:
  - **T1.** Given a new FinancialMatchViewModel, currentStep is 0 and canAdvance is false.
  - **T2.** Given a fresh wizard, When the user selects an intent, Then canAdvance flips true and nextStep moves to step 1.
  - **T3.** Given a wizard, When the user toggles three mentor preferences, Then only the first two are retained (cap = 2).
  - **T4.** Given a completed Financial wizard, When the user submits, Then isComplete is true and matchedMentor.track == "Financial".
  - **T5.** Mirror of T1 for `CareerMatchViewModel`.
  - **T6.** Mirror of T4 for the Career wizard — matchedMentor.track == "Tech".

### iOS — Step 2 (Models + ViewModels) — [x] Done

- [x] `Group-14/Features/MentorMatch/Models/MentorMatchModels.swift` — `MatchOption`, `FinancialMatchRequest`, `CareerMatchRequest`, hardcoded `financialMentorPool` and `careerMentorPool` arrays.
- [x] `Group-14/Features/MentorMatch/ViewModels/MentorMatchViewModel.swift`:
  - `FinancialMatchViewModel` (`@MainActor`, `ObservableObject`, `internal import Combine`) — 7-step state machine.
  - `CareerMatchViewModel` — 6-step state machine.
  - Both expose `currentStep`, `canAdvance`, `nextStep()`, `previousStep()`, `submit()`, `reset()`, `matchedMentor`, `isLoading`, `isComplete`.

### iOS — Step 3 (Views) — [x] Done

- [x] `MentorMatchView` — root chooser with two TrackCards inside a `NavigationStack`.
- [x] `FinancialMatchView` — 7-step wizard. Progress bar, step content, navigation buttons, loading screen, and result transition.
- [x] `CareerMatchView` — 6-step wizard (parallel structure to Financial).
- [x] `MatchResultView` — celebration screen with mentor avatar, bio, expertise tags, and a "Start Over" reset button. Includes a custom `MatchFlowLayout` for the expertise chips.

### iOS — Step 4 (Tab wiring) — [x] Done

- [x] `Group-14/Core/MainTabView.swift` — single-line swap of `QuestionnaireView()` → `MentorMatchView()` inside the learner branch. Role-aware structure, Inbox tab, and `ThreadFeedView` rename are preserved.

---

## Test plan (manual, after build)

- Open Match tab as a Financial learner → see two TrackCards.
- Tap "Financial Guidance" → step 0 shows intent options, Next disabled until selection.
- Pick intent → Next enables, advances to step 1.
- Complete all 7 steps → tap "Find My Mentor ✨" → loading screen for ~1.5s → mentor result card.
- Tap "Start Over" → returns to step 0 with cleared state.
- Repeat for Career Mentorship.
- Tab structure unchanged for mentors (Profile + Q Thread only).
