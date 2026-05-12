# Ascend — Master Plan

> High-level roadmap for the Group-14 iOS app. Each entry links to a detailed feature plan.

**Last updated:** 2026-05-11
**Active feature:** `feature_thread_inbox.md`

---

## Vision

A SwiftUI iOS app that pairs first-gen learners with Fidelity mentors in either a **Financial** or **Tech** track. The app supports two flows:

- **Learner flow:** Profile · Confidence Tracker · Match Questionnaire · Q Thread + Inbox
- **Mentor flow:** Profile · Q Thread (reply to learners)

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
| Profile (role-aware, learner + mentor) | — | ✅ Done |
| Confidence (view-model + view) | — | ✅ Done |
| Questionnaire (view-model + view) | — | ✅ Done |
| Mentor Q Thread (read-only feed) | — | ✅ Done — replaces hardcoded MentorProfile |
| Learner Profile Creation (onboarding) | [feature_learner_profile_creation.md](feature_learner_profile_creation.md) | ✅ Done |
| Welcome / Login / Mentor signup | — | ✅ Done (PR #4) |
| **Q Thread posting + replies + Inbox + score trigger** | [feature_thread_inbox.md](feature_thread_inbox.md) | 🟡 **Active** |

---

## Known Gaps

- **No XCTest target wired in Xcode project yet.** `Group-14Tests/` source exists on disk but isn't a real target — tests must be added as a Unit Testing Bundle via Xcode UI before they can be run by `xcodebuild test`.

---

## Branching reminder

Every feature: branch off `main`, name `feature/<name>`. Never work directly on `main`.
