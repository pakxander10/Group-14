# Feature — InvestInMe Rebrand + Thread Upvoting

> Two related changes bundled on one branch: (1) visual/brand refresh to match the
> `investinme_full_ui.html` mock, and (2) a behavioral feature — upvoting thread
> posts and replies — which is the only new flow added by this branch.

**Status:** ✅ Done
**Branch:** `feature/investinme-rebrand`
**Base:** `main` (post-merge of `feature/profile-editing` → commit `31a8cdb`).
**Source mock:** `/Users/xanderpak/Downloads/investinme_full_ui.html`
**ATDD:** acceptance tests for upvoting live in
`Group-14Tests/Features/MentorThread/`. Visual restyle is verified manually
via `#Preview` + simulator (no acceptance tests — behavior unchanged).

---

## Scope (locked with user)

1. **Rename brand "Ascend" → "InvestInMe"** across UI strings and color tokens
   (`ascendBackground` etc. → InvestInMe-named tokens).
2. **Theme flip:** dark mode → light mode. Remove `.preferredColorScheme(.dark)`.
3. **Pink palette** from mock replaces purple/teal:
   - Primary `#D4537E`
   - Hero band light pink `#FBEAF0`
   - Border `#F4C0D1`
   - Dark wine title `#4B1528`
   - Secondary wine `#993556`
   - Scroll background `#f9f9f9`, cards white
   - Accent green `#0F6E56` on bg `#E1F5EE` (used by mentor track badge)
   - Accent purple `#534AB7` on bg `#EEEDFE` (used by tech track badge)
4. **Do NOT add** mentor Requests tab or Schedule tab — keep current
   `MainTabView` structure (learner: Profile/Confidence/Match/Q Thread/Inbox,
   mentor: Profile/Q Thread).
5. **Do NOT add** anonymous Q&A posting — keep author-named behavior.
6. **Add upvoting** on thread posts AND replies. Tap thumbs-up → count
   increments → persisted via backend.

---

## Part A — Thread upvoting (NEW feature, ATDD)

### A — Step 1 (ATDD) — [x] Done

Add `Group-14Tests/Features/MentorThread/ThreadUpvoteAcceptanceTests.swift`
covering:

- **A1.** `upvotePost(id:)` calls service `upvotePost(id:)` and updates the
  matching `ThreadPost.upvotes` in `posts` with the response value.
- **A2.** `upvotePost(id:)` is idempotent from the VM perspective — calling
  it for a non-existent id is a no-op and does not crash.
- **A3.** When `upvotePost` service throws, `errorMessage` is set and
  existing `posts` are preserved.
- **A4.** `upvoteReply(postId:, replyId:)` calls service and updates the
  matching reply's upvote count inside `posts[i].replies[j]`.
- **A5.** When `upvoteReply` service throws, `errorMessage` is set and
  posts/replies are preserved.

### A — Step 2 (Models) — [x] Done

`ThreadPost` and `ThreadReply` already carry `upvotes: Int`. No model change
needed for the feature itself, but we must be able to *mutate* upvotes locally
on success. Confirm whether to change `upvotes: let` → `upvotes: var` or
rebuild new structs on response. Decision: **rebuild** — keep models as
immutable value types and replace the element in the array, consistent with
how `ProfileViewModel.saveLearnerEdit` returns a fresh struct.

### A — Step 3 (Service + Network) — [x] Done

- Extend `ThreadServiceProtocol`:
  - `upvotePost(id: String) async throws -> ThreadPost`
  - `upvoteReply(postId: String, replyId: String) async throws -> ThreadReply`
- Implement on `ThreadService` using `network.post("/posts/\(id)/upvote", body: EmptyBody())`
  (or similar) and `/replies/\(replyId)/upvote`.
- Confirm `NetworkManager` supports an empty-body POST; if not, define
  `struct EmptyBody: Encodable {}`.

### A — Step 4 (ViewModel) — [x] Done

- Add `func upvotePost(id: String)` on `ThreadViewModel` — wraps service call,
  replaces matching `ThreadPost` in `posts`.
- Add `func upvoteReply(postId:, replyId:)` — same pattern, replaces reply.

### A — Step 5 (View) — [x] Done

- `ThreadFeedView` — add an upvote button to each post card with count.
- `ThreadDetailView` — add upvote on the post header AND on each reply row.
- Tapping does not navigate — just fires the intent.

### A — Step 6 (Backend) — [x] Done

- `POST /posts/{post_id}/upvote` → increments `upvotes`, returns updated `ThreadPost`.
- `POST /replies/{reply_id}/upvote` → increments `upvotes`, returns updated `ThreadReply`.
- No auth — single-user mock, matches existing endpoints.

---

## Part B — Brand rename + visual restyle (no acceptance tests)

### B — Step 1 (Color tokens) — [x] Done

Replace `Color+Ascend.swift` with `Color+InvestInMe.swift`:
- `.investBackground` (#f9f9f9 / system background light)
- `.investSurface` (white)
- `.investPrimary` (#D4537E)
- `.investPrimaryDark` (#993556)
- `.investHeroBand` (#FBEAF0)
- `.investBorder` (#F4C0D1)
- `.investTitle` (#4B1528)
- `.investTextPrimary` (#1a1a1a)
- `.investTextSecondary` (#999)
- `.investAccentGreen` (#0F6E56) + bg variant
- `.investAccentPurple` (#534AB7) + bg variant

Find/replace `ascend*` references project-wide.

### B — Step 2 (App theme + tab bar) — [x] Done

- Remove `.preferredColorScheme(.dark)`. App follows system default.
- Tab bar: pink selected tint via `UITabBar.appearance().tintColor`.
- Status bar: light background under wine title.

### B — Step 3 (Welcome / Login / Mentor signup) — [x] Done

- Title text "InvestInMe" — wine color, bold serif-ish weight.
- Background: white with a top hero band `.investHeroBand`.
- Primary buttons: filled pink `.investPrimary`.
- Tagline: under-title, secondary wine.

### B — Step 4 (Profile screens) — [x] Done

- Header card: white surface, role pill in pink, name in wine title color.
- Edit pencil: pink filled circle.
- Cards: white on `#f9f9f9` with `RoundedRectangle(cornerRadius: 16)`.
- Track badges: green for Financial, purple for Tech (mentor profile).

### B — Step 5 (Q Thread + Inbox) — [x] Done

- Feed cards: white card, category chip (green/purple), author row with
  name + role pill, body preview, upvote + reply count footer.
- Detail view: same card aesthetic, mentor replies highlighted.
- Inbox: white rows with pink notification dot.

### B — Step 6 (Confidence / Match) — [x] Done

- Confidence dashboard: pink progress accents, white cards, wine headings.
- Match flows (Financial + Career): wine question titles, pink chip
  selection, pink Continue button.
- Match result mentor cards: white cards with role pill + match score
  badge in pink.

---

## Manual test plan

### Part A (upvoting)
- Open Q Thread feed → tap upvote on a card → count increments, persists
  on app reload (backend dict mutated until process restart).
- Open thread detail → tap upvote on post → count updates.
- Tap upvote on a reply → reply count updates.
- Force backend error (kill backend) → toast/error message shown, counts
  unchanged.

### Part B (visual)
- All screens: light background, no remaining purple/teal accents.
- "InvestInMe" appears as the brand on Welcome + Login.
- Pink primary button on every CTA.
- Profile pencil works → edit sheet styled to match.
