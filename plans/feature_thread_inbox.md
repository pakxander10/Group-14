# Feature — Q Thread Posting + Replies + Inbox + Confidence Trigger

**Branch:** `feature/thread-q-and-inbox`
**ATDD:** every step starts with a failing acceptance test in `Group-14Tests/Features/Thread/`.

---

## User-facing behavior (Discuss)

1. A **learner** can post a question to the feed. They must tag it with a category — **Financial** or **Tech** — chosen via a segmented control on the post form. The category mirrors `MentorTrack` so mentors can later filter by their own track.
2. A **mentor** can open any post and reply to it.
3. When a mentor replies to a learner's post:
   - A **notification** is appended to that learner's **inbox**.
   - The learner's **confidence score** is incremented by **+10** (clamped to 1–1000).
4. The **learner's Inbox tab** lists those notifications (most recent first). Tapping a notification opens the thread detail (out of scope for v1 — purely informational badge for now).
5. **Conditional UI by role:**
   - Learners see an **Ask a Question** button on the feed; they do not see a Reply composer on a post.
   - Mentors see a **Reply** composer on each post; they do not see Ask a Question.

---

## Design decisions

- **`User` model**: thin Foundation-only struct (`id`, `name`, `role`) used in the threading system. The richer `LearnerProfile` and `MentorProfile` types remain for the profile/onboarding flows.
- **`author_id` on posts/replies**: required so the backend can route a notification to the original poster on reply.
- **Notification recipient routing**: when a reply comes in, the backend looks up the post's `author_id`; if `author_role == "learner"` it appends a `Notification` to that learner's inbox and bumps their score.
- **Score increment**: `+10` per mentor reply, clamped to `1...1000` (same clamp as the existing `/confidence/{user_id}` endpoint uses).
- **Seed mock data**: 2 learners (`u1` Sofia, `u2` new), 3 mentors (existing `m1`/`m2`/`m3` — keeps `/questionnaire` matching working).
- **Categories live as `String` over the wire** with values `"Financial"` / `"Tech"` to match the existing `MentorTrack.rawValue` — easy snake_case-free encoding.

---

## Plan (ATDD order)

### Backend (Part 1)

- [ ] **B1.** Extend `backend/main.py`:
  - Add `User` model and `Notification` model.
  - Add `category` + `author_id` to `ThreadPost`; add `author_id` + `post_id` to `ThreadReply`.
  - Seed: add learner `u2`, keep existing mentors and existing 2 posts (give them `author_id`s + categories).
  - Add `POST /posts` → returns the created `ThreadPost` (201).
  - Add `POST /replies` → returns the created `ThreadReply` (201). Side-effects:
    - If `MOCK_POSTS[post_id].author_role == "learner"` append a `Notification` to that learner's inbox and `+10` (clamped) to their `confidence_score`.
  - Add `GET /inbox/{learner_id}` → returns list of `Notification` (most recent first).

### iOS — ATDD slice (Steps 1 + 2)

- [ ] **S1.** Create `Group-14/Features/Thread/Models/ThreadModels.swift` (replaces the old `MentorThread/Models/ThreadModels.swift`):
  - `User`, `Category` (alias of String constants — Financial/Tech), `ThreadPost`, `ThreadReply`, `Notification`, `CreatePostRequest`, `CreateReplyRequest`.
- [ ] **S2.** Create `ThreadServiceProtocol` + concrete `ThreadService` + `MockThreadService`:
  - `fetchFeed()` / `createPost(_)` / `createReply(_)` / `fetchInbox(learnerId:)`
  - `MockThreadService` keeps in-memory state and **mirrors backend side-effects** in `createReply` (appends notification + bumps score) so tests don't need a running server.
- [ ] **S3.** Write `Group-14Tests/Features/Thread/ThreadAcceptanceTests.swift`:
  - **T1.** Given a learner posted a question, When a mentor replies, Then `fetchInbox(learnerId:)` returns a notification with the mentor's name + post title.
  - **T2.** Given a learner has a confidence score of 100, When a mentor replies to their post, Then the mock's tracked score for that learner is 110.

**⏸ Stop here for user approval to run the tests.**

### iOS — Steps 3 + 4 (after green tests)

- [ ] **S4.** `ThreadViewModel` (feed + post + reply intents).
- [ ] **S5.** `InboxViewModel` (fetch inbox for current learner).
- [ ] **S6.** `ThreadFeedView` (list + Ask a Question button for learners).
- [ ] **S7.** `ThreadDetailView` (single post + reply composer for mentors only).
- [ ] **S8.** `InboxView` (notification list for learners).
- [ ] **S9.** Wire into `MainTabView`: replace `MentorThreadView` with `ThreadFeedView`; add `InboxView` tab for learners.

---

## Risks / open questions

- The Xcode project does not yet have a `Group-14Tests` target wired up. Test files will exist on disk but will not be runnable via `xcodebuild test` until the target is added in Xcode UI. We will write the tests anyway (per ATDD); running them is gated on the target.
- The existing `MentorThread/` files (`ThreadModels.swift`, `MentorThreadViewModel.swift`, `MentorThreadView.swift`) will be superseded by the new `Thread/` feature folder. Old files will be removed once new wiring lands.
