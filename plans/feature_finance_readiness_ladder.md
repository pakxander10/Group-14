# Feature — Finance-Exclusive Readiness Ladder

> Confidence score (0–1000) and tiers are **exclusive to Financial-track learners**.
> Tech-track learners can still post, reply, and upvote — but no points move.

**Status:** 🟢 Ready for PR
**Branch:** `feature/finance-readiness-ladder`
**ATDD:** every step starts with a failing acceptance test in `Group-14Tests/Features/Confidence/`.

---

## Discuss — User-facing behavior

1. The Confidence Score and the 5-tier Readiness Ladder only mean something on the **Financial** track.
2. **Earning events (Financial only):**
   - Complete Questionnaire → **+30** (one-time)
   - First Financial post → **+25** (one-time)
   - Subsequent Financial posts → **+5** each
   - Upvote a reply → **+1**
   - Mentor reply on a Financial post → **+10** to the post's author (existing behavior, now gated)
3. **Tech-track events** complete normally (post saved, reply saved, upvote recorded) but **score delta = 0**.
4. **Tiers (Financial only):**

   | Tier | Range | Name | Readiness prompt |
   |---|---|---|---|
   | 1 | 0–249 | The Foundation | "Ready to set up a basic budget." |
   | 2 | 250–499 | The Safety Net | "Ready to open a High-Yield Savings Account (HYSA)." |
   | 3 | 500–749 | The Strategist | "Ready to review employer benefits like 401(k) matches." |
   | 4 | 750–999 | The Investor | "Ready to open a brokerage account." |
   | 5 | 1000 | Ascended | "Graduation! You have mastered the basics." |

5. The dashboard explains *what earns points* via an info (i) button that opens a sheet titled **"Earning Finance Points"**.

---

## Open question (deferred, not blocking)

The prompt references `/upvote` and `LearnerProfile.track`, neither of which exist yet:
- `LearnerProfile` has `interest` ("financial"/"tech"), not `track`. We'll key off `interest`.
- There is no `POST /upvote` endpoint. We'll add one in Step 4 (Backend) as part of this feature.

---

## Plan

### iOS — Step 1 (ATDD) — [x] Done

- [x] `Group-14Tests/Features/Confidence/ConfidenceAcceptanceTests.swift`:
  - **T1.** Given a Financial-track learner with no prior posts, When they post a Financial question, Then their score increases by 25.
  - **T2.** Given a Tech-track learner with no prior posts, When they post, Then their score is unchanged.
  - **T3.** Given a ConfidenceScore of 300, Then its tier is "The Safety Net" with prompt "Ready to open a High-Yield Savings Account (HYSA)."
- [x] `Group-14Tests/Mocks/MockThreadService.swift`:
  - Track `learnerInterests` alongside names + scores.
  - `seedLearner(id:name:interest:score:)` — `interest` becomes a required arg.
  - Re-introduce `seedPost(...)` so reply-only tests can skip the post-creation bonus.
  - `createPost` applies the +25/+5/0 logic.
  - `createReply` gates the +10 bump to Financial-category posts.
- [x] `Group-14Tests/Features/Thread/ThreadAcceptanceTests.swift`:
  - Update T1 & T2 calls to pass `interest: "financial"`.
  - T2 uses `seedPost` so the assertion isolates the reply bonus.

### iOS — Step 2 (ViewModels) — [x] Done

- [x] `ConfidenceScore.tier: String` → `ConfidenceTier` enum (`displayName`, `readinessPrompt`, `range`, `threshold`).
- [x] `ConfidenceViewModel`:
  - Added `interest: String` and `isEligibleForScoring: Bool` (computed from learner interest).
  - `tier: ConfidenceTier` computed, surfacing the readiness prompt for the dashboard.
  - `load(userId:)` method-arg pattern (matches `InboxViewModel`) so the view passes `@AppStorage("userId")`.
- [x] `ThreadViewModel`: no code change — backend owns the scoring; VM just re-fetches feed/profile after a post or reply.

### iOS — Step 3 (Dashboard) — [x] Done

- [x] Replaced the emoji-themed milestone list with a vertical `ConfidenceTier.allCases` list — current tier carries a `CURRENT` capsule + accent border; unreached tiers are dimmed and locked.
- [x] Added an info (i) button in the header that opens a `.sheet` titled **"Earning Finance Points"** listing the full earning rules.
- [x] Tech-track ineligible state: when `viewModel.isEligibleForScoring == false`, the ring + tier list are replaced by an explanatory lock card.
- [x] Current tier card now shows the tier's `readinessPrompt` ("Ready to open a HYSA", etc.).

### Backend — Step 4 — [x] Done

- [x] `POST /posts`: when the author is a Financial learner AND `category == "Financial"`, apply +25 (first ever Financial post) or +5 (subsequent), clamped 0–1000. Tech-track and cross-category posts: 0 delta. Post is always saved.
- [x] `POST /replies`: +10 mentor-reply bump gated to `post.category == "Financial"` AND a Financial-track learner author. Notification still fires for all replies.
- [x] `POST /upvote` (new): body `{ post_id, reply_id, voter_id }`. Increments `reply.upvotes`. If voter is a Financial learner AND post is Financial, +1 to voter (clamped 0–1000).
- [x] `POST /questionnaire`: optional `learner_id` param. First-ever submission flips `questionnaire_completed`; Financial learners earn +30 on that first submission. Tech learners: 0.
- [x] Added `questionnaire_completed: bool = False` field on `LearnerProfile`.
- [x] Aligned all storage/runtime clamp ranges to 0–1000 (was 1–1000 on PUT /confidence and create_learner).

### Intentional clamp distinction (not drift)

- **Storage / runtime clamp = 0…1000.** Backend `_bump_score`, `PUT /confidence/{user_id}`, and `MockThreadService` all clamp to 0–1000 so a Financial learner who never engages can sit at 0 and Tech learners (who don't score) trivially round-trip through any code path.
- **Onboarding entry-form gate = 1…1000.** `LearnerProfileCreationViewModel.canSubmit` and the slider in `LearnerProfileCreationView` reject `currentConfidenceScore == 0`. This is an established, test-pinned UX rule (the user must self-rate at least 1 to complete onboarding — see `test_givenScoreBelowOne_whenUserSubmits_thenCanSubmitIsFalse`). The form gate is intentionally stricter than the storage clamp and is not part of this feature's scope.

### Test target wiring (closed)

This PR also wires up the XCTest target that had been missing project-wide. After the change, `xcodebuild test` runs all 15 acceptance tests (Confidence × 3, LearnerProfileCreation × 8, LearnerProfileCreationViewModel × 2, Thread × 2) green.

- New `PBXNativeTarget` `Group-14Tests` with product type `com.apple.product-type.bundle.unit-test`.
- New `PBXFileSystemSynchronizedRootGroup` pointing at `Group-14Tests/` so Swift files are picked up automatically.
- Test target depends on the app via `PBXTargetDependency` + `PBXContainerItemProxy`.
- Build configs set `TEST_HOST = $(BUILT_PRODUCTS_DIR)/Group-14.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Group-14` and `BUNDLE_LOADER = $(TEST_HOST)` so `@testable import Group_14` resolves.
- New shared scheme at `Group-14.xcodeproj/xcshareddata/xcschemes/Group-14.xcscheme` enables the Test action.

---

## Test plan (manual, after Step 3)

- Financial learner posts first Q → ring jumps +25, tier label updates if it crossed.
- Financial learner posts second Q → +5.
- Tech learner posts Q → ring unchanged.
- Mentor replies to Financial post → learner +10.
- Mentor replies to Tech post → no change.
- Score crosses 250 → tier label flips to "The Safety Net."
- Tap (i) → sheet lists the five earning rules.
