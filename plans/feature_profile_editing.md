# Feature — Profile Editing + Searchable Expertise

> Two related capabilities bundled on one branch because they share a model surface (mentor `expertise` field) and a UX surface (mentor profile form).

**Status:** 🟢 Ready for review
**Branch:** `feature/profile-editing`
**Base:** `main` (post-merge of `feature/mentor-match`).
**ATDD:** acceptance tests live in `Group-14Tests/Features/Profile/` and
`Group-14Tests/Features/MentorOnboarding/`.

---

## Discuss — User-facing behavior

### Part A — Searchable expertise picker (mentor onboarding)

1. The "Areas of Expertise" field in `MentorProfileCreationView` is no longer a
   free-text comma-separated TextField. It becomes a **searchable multi-select
   chip picker** over a curated, track-aware term pool.
2. The user types a query (e.g. "roth"); a list of matching predetermined
   terms appears beneath the search box. Tapping a term **adds it as a chip**.
3. Selected terms render as chips above the search box. Each chip has a small
   "×" that **removes it** when tapped.
4. **No duplicates** — already-selected terms are excluded from suggestions.
5. **Track-aware:**
   - `track == "Financial"` → financial term pool.
   - `track == "Tech"` → tech term pool.
   - `track == ""` (not yet picked) → both pools merged.
6. `canSubmit` still requires ≥ 1 expertise tag. Custom (non-predetermined)
   entries are NOT allowed in this iteration — strict whitelist keeps the
   matching algorithm simple and predictable.

### Part B — Profile editing (learner + mentor)

1. A pencil **Edit** button appears on `ProfileView` for both roles.
2. Tapping it presents a sheet with a form pre-populated from the current profile.
3. **Mentor-editable fields:** name, title, company, track, bio, expertise
   (same searchable picker as Part A), years experience, email, LinkedIn,
   education history.
4. **Learner-editable fields:** name, interest, goal, occupation/major.
   Background, age, confidence score, and ID stay immutable (background/age
   are onboarding-only; confidence is awarded by app activity).
5. On Save: persist via new backend `PUT` endpoints, then refresh the
   ProfileView with the returned profile.
6. Cancel dismisses the sheet without saving.

---

## Plan

### Part A — Step 1 (ATDD) — [ ] Done

- [x] `Group-14Tests/Features/MentorOnboarding/MentorProfileCreationViewModelTests.swift`
      (new file) — black-box tests against `MentorProfileCreationViewModel`:
  - **A1.** Initial `selectedExpertise` is empty; `canSubmit` is false.
  - **A2.** Given track = "Financial", `expertiseSuggestions` filters by `searchQuery`
        and returns only Financial-pool terms.
  - **A3.** Given track = "Tech", `expertiseSuggestions` returns Tech-pool terms.
  - **A4.** Given no track, `expertiseSuggestions` returns the merged pool.
  - **A5.** `addExpertise(term)` appends to `selectedExpertise` and excludes it
        from `expertiseSuggestions`.
  - **A6.** `addExpertise(term)` rejects duplicates (no double-add).
  - **A7.** `addExpertise(term)` rejects terms not in the predetermined pool.
  - **A8.** `removeExpertise(term)` removes it and clears the search query
        so the user can immediately continue browsing.
  - **A9.** `canSubmit` flips true only after expertise has ≥ 1 entry
        (alongside the other required fields).
  - **A10.** Submitting passes `selectedExpertise` to the request `expertise: [String]`.

### Part A — Step 2 (Models + ViewModel) — [ ] Done

- [x] `Group-14/Features/MentorOnboarding/Models/ExpertiseCatalog.swift` (new):
  - Lists `financialExpertiseTerms` and `techExpertiseTerms` (curated strings).
  - Exposes `ExpertiseCatalog.terms(for: String) -> [String]` that returns the
    track-specific list or the merged list when track is empty.
- [x] Refactor `MentorProfileCreationViewModel`:
  - Drop `expertiseInput: String`, replace with `selectedExpertise: [String]`
    and `searchQuery: String`.
  - Computed `expertiseSuggestions: [String]` — `ExpertiseCatalog.terms(for: track)`
    minus `selectedExpertise`, filtered by `searchQuery` (case-insensitive
    substring), capped at 8 entries for UI sanity.
  - Methods: `addExpertise(_:)`, `removeExpertise(_:)`.
  - `canSubmit` checks `!selectedExpertise.isEmpty` instead of `expertiseList`.
  - `submit()` sends `selectedExpertise` as the request's `expertise`.

### Part A — Step 3 (View) — [ ] Done

- [x] Replace `expertiseField` in `MentorProfileCreationView` with a chip
      picker section: selected chips row → search TextField → suggestion list.
- [x] `ExpertiseChipPickerSection` view extracted as a private sub-view that
      takes the relevant bindings & callbacks so the file stays readable.

### Part B — Step 4 (ATDD) — [ ] Done

- [x] `Group-14Tests/Features/Profile/ProfileEditingAcceptanceTests.swift` (new):
  - **B1.** Given a loaded mentor, when `beginEditMentor()` is called, then
        `editingMentor` is populated from `mentor`.
  - **B2.** When user changes the mentor's bio and calls `saveMentorEdit()`,
        service `updateMentor` is invoked with the edited profile and
        `mentor` is refreshed with the response.
  - **B3.** When service throws, `errorMessage` is populated and the original
        `mentor` is preserved.
  - **B4.** Mirror B1–B3 for learner via `beginEditLearner()` / `saveLearnerEdit()`.

### Part B — Step 5 (Models + Service + ViewModel) — [ ] Done

- [x] Convert mutable learner fields in `LearnerProfile` from `let` to `var`
      (name, interest, goal, occupationMajor only — keep id/age/background as `let`).
- [x] Add `UpdateLearnerRequest` (Encodable) and `UpdateMentorRequest` (Encodable)
      models to `Profile/Models/UserProfile.swift`.
- [x] Extend `ProfileServiceProtocol` with `updateLearner(id:, _:)` and
      `updateMentor(id:, _:)`. Implement on `ProfileService` (PUT calls).
- [x] Extend `NetworkManagerProtocol` with `put` if not already present —
      check first; if `post` is the only mutator, add `put`.
- [x] Extend `ProfileViewModel` with: `editingMentor` / `editingLearner`
      drafts, `beginEdit*`, `saveLearnerEdit`, `saveMentorEdit`,
      `cancelEdit`.

### Part B — Step 6 (Views) — [ ] Done

- [x] Add pencil **Edit** button overlaid on the header card in `ProfileView`
      that toggles a sheet binding.
- [x] `LearnerEditView` — sheet form for name / interest / goal / occupationMajor.
- [x] `MentorEditView` — sheet form mirroring the onboarding fields, reusing
      `ExpertiseChipPickerSection` from Part A.

### Part B — Step 7 (Backend) — [ ] Done

- [x] Add `PUT /profile/{user_id}` — accepts `UpdateLearnerRequest`, mutates
      the in-memory dict, returns updated `LearnerProfile`.
- [x] Add `PUT /mentors/{mentor_id}` — accepts `UpdateMentorRequest`,
      mutates the in-memory dict, returns updated `MentorProfile`.

---

## Test plan (manual, after build)

### Part A
- Open mentor onboarding → "Areas of Expertise" shows a search bar with no chips.
- Pick track = Financial → typing "roth" filters to "Roth IRA" only.
- Tap a suggestion → it appears as a chip, disappears from the suggestion list.
- Tap the chip's "×" → it's removed, returns to suggestions.
- Switch track to Tech → suggestions update to tech terms only.
- Submitting works only after ≥ 1 chip is selected.

### Part B
- Open Profile as a mentor → tap pencil → edit bio → Save → ProfileView
  reflects the new bio.
- Open Profile as a learner → tap pencil → change goal → Save → ProfileView
  reflects the new goal.
- Cancel discards changes.
