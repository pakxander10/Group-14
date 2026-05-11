# Ascend — Master Plan

> High-level roadmap for the Group-14 iOS app. Each entry links to a detailed feature plan.

**Last updated:** 2026-05-11
**Active feature:** `feature_learner_profile_creation.md`

---

## Vision

A SwiftUI iOS app that pairs first-gen learners with Fidelity mentors in either a **Financial** or **Tech** track. Four tabs:

1. **Profile** — learner's own profile + matched mentor
2. **Confidence Tracker** — score (1–1000) updated as the learner completes actions
3. **Match Questionnaire** — short form that picks a mentor
4. **Mentor Q&A Thread** — feed of community questions + mentor replies

Backend is a small FastAPI service with in-memory mock data ([backend/main.py](../backend/main.py)).

---

## Architecture (locked)

- **MVVM**, strict. Models = Foundation only. ViewModels = no SwiftUI. Views = no business logic.
- **ATDD**: every feature step starts with an acceptance test in `Group-14Tests/`, then minimal implementation.
- **DI pattern** (matches existing ViewModels):
  ```swift
  init(service: SomeServiceProtocol? = nil) {
      self.service = service ?? SomeService()
  }
  ```
  This avoids `@MainActor` isolation warnings under `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.
- **Combine import**: ViewModels use `internal import Combine` (Swift 6 upcoming-feature `MemberImportVisibility` is on).

---

## Status by Feature

| Feature | Plan | Status |
|---|---|---|
| Network layer (`NetworkManager`, `NetworkError`) | — | ✅ Done |
| Profile (view-model + service) | — | ✅ ViewModel done; View not yet wired into a tab |
| Confidence (view-model + service) | — | ✅ ViewModel done; View not yet wired into a tab |
| Questionnaire (view-model + service) | — | ✅ ViewModel done; View not yet wired into a tab |
| Mentor Thread (view-model + service) | — | ✅ ViewModel done; View not yet wired into a tab |
| Mentor Profile (read-only + edit sheet) | — | ✅ Done on `main` (commit `a999b58`) — hardcoded data, not yet wired to a real mentor source |
| **Learner Profile Creation (onboarding)** | [feature_learner_profile_creation.md](feature_learner_profile_creation.md) | 🟡 **Active** |
| MainTabView wiring (4-tab shell) | TBD | ⬜ Not started |
| `Group-14Tests/` XCTest target | — | ⬜ **Must be created in Xcode UI before ATDD begins** |

---

## Known Gaps

- **No XCTest target exists yet.** `Group-14Tests/` is referenced by CLAUDE.md but the Xcode project has no test target. The next contributor must add it via Xcode → File → New → Target → Unit Testing Bundle (named `Group-14Tests`) before any ATDD work can run.
- **No `MainTabView`.** The four feature ViewModels exist but no `TabView` glues them together. `Group_14App.swift` still launches `ContentView`.
- **Backend `/learners` POST endpoint not implemented.** See [feature_learner_profile_creation.md](feature_learner_profile_creation.md).

---

## Branching reminder

Every feature: branch off `main`, name `feature/<name>`. Never work directly on `main`.
