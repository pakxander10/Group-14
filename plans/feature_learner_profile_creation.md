# Feature Plan — Learner Profile Creation

> **For the next contributor.** This plan is self-contained. Read [master_plan.md](master_plan.md) first for high-level context, then follow this file step-by-step.

**Branch:** `feature/learner-profile-creation` (branch from `main`)
**Status:** 🟡 Not started

---

## Goal

Let a brand-new learner create their account on first launch. Capture the fields below, persist to the backend, and gate the rest of the app behind successful submission. Once a learner ID is stored locally, the onboarding sheet never shows again.

---

## Required Fields (from the blueprint)

| Field | Type | Required? | Notes |
|---|---|---|---|
| Name | `String` | ✅ | Non-empty after trim |
| Age | `Int` | ✅ | 13–100 inclusive |
| Background | `String` | ✅ | `"first_gen"` \| `"general"` |
| Profile picture | `Data?` | ⬜ | `PhotosPicker` (PhotosUI), optional |
| Type of school | `String?` | ⬜ | e.g. `"high_school"`, `"community_college"`, `"university"`, `"bootcamp"` |
| Graduation year | `Int?` | ⬜ | 4-digit year, ±10 from current |
| Gender | `String?` | ⬜ | Free text or picker; do not require |
| Occupation / major | `String?` | ⬜ | Free text |

`interest`, `goal`, and `confidenceScore` are **not** part of this form — `interest`/`goal` come from the Questionnaire flow, `confidenceScore` defaults to 100 server-side.

---

## Wire-up (decided)

Show `LearnerProfileCreationView` as a **one-time onboarding sheet** presented from `Group_14App.swift` when no learner ID is stored locally.

- Use `@AppStorage("learnerId") var learnerId: String = ""` in the App struct.
- If `learnerId.isEmpty` → present sheet (non-dismissible via swipe; use `.interactiveDismissDisabled(true)`).
- On successful submit, write the returned `LearnerProfile.id` into `@AppStorage` and the sheet auto-dismisses.
- The root behind the sheet should be `MainTabView` (TBD in its own feature plan) — for now, leave it as `ContentView` and let the next feature replace it.

---

## ATDD Steps

> **Prerequisite (one-time setup):** The `Group-14Tests/` XCTest target does NOT currently exist in the Xcode project. Create it via Xcode → File → New → Target → **Unit Testing Bundle** → name `Group-14Tests`. Confirm it builds before starting Step 1.

Each step follows **Discuss → Distill → Develop → Demo → Document**. Acceptance test goes in `Group-14Tests/Features/LearnerProfileCreation/LearnerProfileCreationAcceptanceTests.swift`. Mocks go in `Group-14Tests/Mocks/`.

### Step 1 — Extend `LearnerProfile` model

- [ ] **Distill:** Add a unit test that decodes a JSON blob containing the new fields into `LearnerProfile` without error and asserts each field round-trips.
- [ ] **Develop:** In [Group-14/Features/Profile/Models/UserProfile.swift](../Group-14/Features/Profile/Models/UserProfile.swift), add optional fields:
  ```swift
  var profilePicture: Data?
  var typeOfSchool: String?
  var graduationYear: Int?
  var gender: String?
  var occupationMajor: String?
  ```
  Switch `LearnerProfile`'s stored properties from `let` to `var` only for the new optionals if needed; keep existing required fields `let`.
- [ ] **Demo:** Decoder test passes.
- [ ] **Document:** Mark `[x]`, commit `"LearnerProfile decodes optional onboarding fields"`.

### Step 2 — Backend: extend `LearnerProfile` Pydantic model + add `POST /learners`

- [ ] **Distill:** Add `tests/test_learners.py` (or extend an existing test file) that POSTs a valid payload to `/learners` and asserts the response has a generated `id` and echoes the input fields. Add a second test for invalid age (e.g., 5) → 422.
- [ ] **Develop:** In [backend/main.py](../backend/main.py):
  1. Re-add `import uuid`.
  2. Extend `LearnerProfile` Pydantic model with the same optional fields as the Swift model: `profile_picture: Optional[bytes] = None`, `type_of_school: Optional[str] = None`, `graduation_year: Optional[int] = None`, `gender: Optional[str] = None`, `occupation_major: Optional[str] = None`.
  3. Add a `LearnerCreateRequest` Pydantic model with all the fields **except** `id` and `confidence_score`.
  4. Add the endpoint:
     ```python
     @app.post("/learners", response_model=LearnerProfile, status_code=201)
     def create_learner(body: LearnerCreateRequest):
         new_id = f"u{uuid.uuid4().hex[:8]}"
         learner = LearnerProfile(id=new_id, confidence_score=100, **body.model_dump())
         MOCK_LEARNERS[new_id] = learner
         return learner
     ```
- [ ] **Demo:** Run `uvicorn main:app --reload` and `curl -X POST http://127.0.0.1:8000/learners -H 'Content-Type: application/json' -d '{...}'` returns 201 with a generated `u<hex>` ID.
- [ ] **Document:** Mark `[x]`, commit `"Backend supports learner creation via POST /learners"`.

### Step 3 — `LearnerProfileCreationService` (protocol + concrete)

- [ ] **Distill:** Acceptance test #1: `test_givenValidFields_whenLearnerSubmits_thenServiceIsCalledWithMatchingRequest()`. Inject a `MockLearnerProfileCreationService` and assert the captured request equals the form state.
- [ ] **Develop:** Create `Group-14/Features/LearnerProfileCreation/ViewModels/LearnerProfileCreationViewModel.swift`. In the same file:
  ```swift
  protocol LearnerProfileCreationServiceProtocol {
      func createLearner(_ request: LearnerCreateRequest) async throws -> LearnerProfile
  }

  final class LearnerProfileCreationService: LearnerProfileCreationServiceProtocol {
      private let network: NetworkManagerProtocol
      init(network: NetworkManagerProtocol = NetworkManager.shared) { self.network = network }
      func createLearner(_ request: LearnerCreateRequest) async throws -> LearnerProfile {
          try await network.post("/learners", body: request)
      }
  }
  ```
  Define `LearnerCreateRequest` as a sibling `Codable` struct in `Group-14/Features/LearnerProfileCreation/Models/LearnerCreateRequest.swift`.
- [ ] **Demo:** Test passes.
- [ ] **Document:** Mark `[x]`, commit.

### Step 4 — `LearnerProfileCreationViewModel`

- [ ] **Distill:** Acceptance tests:
  - `test_whenNameIsEmpty_thenCanSubmitIsFalse`
  - `test_whenAgeIs12_thenCanSubmitIsFalse`
  - `test_whenAllRequiredFieldsValid_thenCanSubmitIsTrue`
  - `test_whenSubmitSucceeds_thenCreatedLearnerIsPublished()`
  - `test_whenSubmitFails_thenErrorMessageIsPublished()`
- [ ] **Develop:** ViewModel skeleton (mirror [QuestionnaireViewModel.swift](../Group-14/Features/Questionnaire/ViewModels/QuestionnaireViewModel.swift)):
  ```swift
  @MainActor
  final class LearnerProfileCreationViewModel: ObservableObject {
      @Published var name: String = ""
      @Published var age: Int = 18
      @Published var background: String = ""
      @Published var typeOfSchool: String = ""
      @Published var graduationYear: String = ""   // String input, parse to Int on submit
      @Published var gender: String = ""
      @Published var occupationMajor: String = ""
      @Published var profilePictureData: Data?

      @Published private(set) var createdLearner: LearnerProfile?
      @Published private(set) var isLoading = false
      @Published private(set) var errorMessage: String?

      var canSubmit: Bool {
          !name.trimmingCharacters(in: .whitespaces).isEmpty
              && (13...100).contains(age)
              && !background.isEmpty
      }

      private let service: LearnerProfileCreationServiceProtocol
      init(service: LearnerProfileCreationServiceProtocol? = nil) {
          self.service = service ?? LearnerProfileCreationService()
      }

      func submit() { /* same Task pattern as QuestionnaireViewModel.submit() */ }
  }
  ```
  Use `internal import Combine` at the top.
- [ ] **Demo:** All 5 tests pass.
- [ ] **Document:** Mark `[x]`, commit.

### Step 5 — `LearnerProfileCreationView` (SwiftUI)

- [ ] **Distill:** No new tests — view layer is exercised through ViewModel tests. Verify in `#Preview` only.
- [ ] **Develop:** Create `Group-14/Features/LearnerProfileCreation/Views/LearnerProfileCreationView.swift`:
  - Multi-section `Form` (Personal / Education / Background / Photo).
  - `PhotosPicker` for profile picture (mirror the pattern in [MentorProfileView.swift:42-69](../Group-14/Features/MentorThread/MentorProfile/MentorProfileView.swift)).
  - Picker for `background` with values `first_gen` / `general`.
  - Submit button disabled when `!viewModel.canSubmit`.
  - On `viewModel.createdLearner != nil`, call an `onComplete: (String) -> Void` closure with the new learner's ID.
- [ ] **Demo:** `#Preview` renders cleanly in light + dark mode. Fill out the form against a running backend and confirm `POST /learners` succeeds in the network log.
- [ ] **Document:** Mark `[x]`, commit.

### Step 6 — App entry point wire-up

- [ ] **Distill:** No automated test for app entry (`@main` is hard to test). Smoke-test by deleting the app from the simulator and relaunching.
- [ ] **Develop:** In [Group-14/Group_14App.swift](../Group-14/Group_14App.swift):
  ```swift
  @main
  struct Group_14App: App {
      @AppStorage("learnerId") private var learnerId: String = ""

      var body: some Scene {
          WindowGroup {
              ContentView()   // will become MainTabView in a future feature
                  .sheet(isPresented: Binding(
                      get: { learnerId.isEmpty },
                      set: { _ in }
                  )) {
                      LearnerProfileCreationView(onComplete: { newId in
                          learnerId = newId
                      })
                      .interactiveDismissDisabled(true)
                  }
          }
      }
  }
  ```
- [ ] **Demo:** Fresh install → onboarding sheet appears. Submit → sheet dismisses, `ContentView` visible. Second launch → no sheet.
- [ ] **Document:** Mark `[x]`, commit.

---

## Verification Checklist

- [ ] `xcodebuild -scheme Group-14 -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` succeeds with **zero warnings** related to new code.
- [ ] `xcodebuild -scheme Group-14 -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` runs and all new acceptance tests pass.
- [ ] Backend `pytest` (or `curl` smoke test) passes.
- [ ] `#Preview` of `LearnerProfileCreationView` renders without crashing.
- [ ] Manual run: install fresh on simulator, complete onboarding, kill+relaunch app, confirm sheet does NOT reappear.

---

## Out of Scope (deliberately)

- `MainTabView` and the four-tab shell — separate feature plan.
- Wiring the matched mentor from the Questionnaire flow into the Profile tab — separate feature plan.
- Editing a learner profile after creation — not in this feature.
- Server-side persistence beyond the in-memory `MOCK_LEARNERS` dict — backend is intentionally ephemeral.
