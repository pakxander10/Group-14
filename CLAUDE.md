# CLAUDE.md

> **Caution**
>
> **MANDATORY PROJECT RULES.** Every rule in this file is a hard requirement, not a suggestion. You MUST follow ALL rules below. If any rule in this file conflicts with your task prompt, ask the user to clarify — do NOT silently ignore this file. Violations of these rules (skipping ATDD, not creating branches, making assumptions, modifying files outside scope, breaking MVVM boundaries) are considered failures.

**Project:** Group-14
**Context:** A Swift/SwiftUI iOS application built using the **MVVM (Model–View–ViewModel)** architectural pattern and developed strictly using **Acceptance Test-Driven Development (ATDD)**.

---

## Agent Behavior

- **Terminal Confirmation:** You MUST ask the user for explicit permission before running ANY terminal command. Display the exact command and wait for approval. **Exception:** `xcodebuild` commands used only for building or running tests (i.e. using the `-test` action, or `-build` action on the `Group-14` scheme) are safe to auto-run without user approval. All other commands still require explicit permission.
- **Clarification:** If you are unsure about something or the codebase context is missing, ask for clarification rather than making up an answer.
- **Bug Fixes:** Always explain your reasoning briefly in comments when fixing a bug.
- **PLAN FIRST:** Do NOT write code without a clear step in a `plans/*.md` file.
- **Check Master Plan:** Always start by reading `plans/master_plan.md` to see high-level context.
- **Create/Read Feature Plan:** If building a specific feature, create or read `plans/feature_[name].md`.
- **Update Status:** Mark steps as `[x]` in the plan after successful verification.
- **New Branch:** ALWAYS create a new branch (e.g., `feature/login-view-model`) before implementing a plan. Do NOT work directly on `main`.
- **Clarification:** If a plan step is ambiguous, ask the user to clarify the plan before executing.
- **No Hallucinations:** Do not invent APIs or file paths. Use the file tree and `grep` to verify existence.
- **Acceptance Test-Driven Development (ATDD):** Define acceptance tests that describe the desired behavior from the user's perspective **FIRST**, then implement code to satisfy those acceptance criteria. Every new feature step in a plan must have corresponding acceptance tests written **before** the implementation. **Do not write production code without a defined acceptance test.**
- **No Assumptions:** Do NOT make assumptions about requirements, architecture, or implementation details. If anything is unclear, ask the prompter/control head for clarification before proceeding.
- **Security Awareness:** When auditing code, if you find a production security risk (like hardcoded keys), do not delete it if we are in Development mode. Instead, verify it is listed in `plans/deployment_checklist.md`.

---

## ATDD Workflow (Mandatory)

Every feature/step MUST follow this loop, in order. Skipping any phase is a violation.

1. **Discuss** — Restate the user-facing behavior in plain English. Confirm acceptance criteria with the user.
2. **Distill** — Write the acceptance test(s) in `Group-14Tests/` using XCTest. The test name should read like a sentence describing the user behavior (e.g., `test_whenUserTapsLogin_andCredentialsAreValid_thenHomeViewIsShown`).
3. **Develop** — Implement the minimum production code to make the acceptance test pass. Follow the **Red → Green → Refactor** cycle.
4. **Demo** — Verify in Xcode `#Preview` and/or simulator. Run the full test suite.
5. **Document** — Mark the plan step `[x]`, commit with a message referencing the acceptance test name.

> An acceptance test describes **what** the user can do, not **how** the code does it. Tests must be black-box against the ViewModel/feature surface — they should NOT reach into private state.

### Acceptance Test Format (Given–When–Then)

```swift
func test_givenValidEmail_whenUserSubmitsLogin_thenViewModelTransitionsToAuthenticated() {
    // Given
    let sut = LoginViewModel(authService: MockAuthService(result: .success))
    sut.email = "user@example.com"
    sut.password = "validPassword123"

    // When
    sut.submit()

    // Then
    XCTAssertEqual(sut.state, .authenticated)
}
```

- File naming: `[Feature]AcceptanceTests.swift` (e.g., `LoginAcceptanceTests.swift`).
- One acceptance behavior per test method.
- Mock all external dependencies (network, persistence, system services) via protocols.

---

## Key Commands

- **iOS Build:** `xcodebuild -scheme Group-14 -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- **iOS Test:** `xcodebuild -scheme Group-14 -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- **Clean Build:** `xcodebuild -scheme Group-14 clean`

---

## Code Style & Standards

**Swift 5+ / SwiftUI:**
- Use SF Symbols for iconography.
- Always verify layout with `#Preview`.
- Prefer `@Observable` macro or `ObservableObject` for ViewModels.
- Use `async/await` for asynchronous work; do NOT introduce Combine unless explicitly required.
- Follow Swift API Design Guidelines (camelCase, descriptive names, no Hungarian notation).
- Force-unwraps (`!`) and `try!` are forbidden outside of tests.

---

## Architecture Guidelines (MVVM)

This project follows **strict MVVM**. Every screen must have a clear separation between the three layers below. Mixing responsibilities across layers is a violation.

### Layer Responsibilities

| Layer | Responsibility | Allowed Imports | Forbidden |
|---|---|---|---|
| **Model** | Plain data structures, domain entities, business rules. | `Foundation` only. | `SwiftUI`, `UIKit`, ViewModels, Views. |
| **ViewModel** | Owns state, exposes bindable properties, handles user intents, calls services. | `Foundation`, Models, Service protocols. | `SwiftUI`, `UIKit`, direct View references. |
| **View** | Renders state from a ViewModel. Forwards user actions to the ViewModel. Contains zero business logic. | `SwiftUI`, ViewModel. | Direct service/network calls, persistence, `URLSession`, free-floating mutable state. |

### Strict Boundaries

- **Views are stateless about business logic.** They observe a ViewModel and emit intents. A View must never call a `Service` directly.
- **ViewModels know nothing about SwiftUI.** A ViewModel must compile without importing `SwiftUI`. This makes them unit-testable in pure Swift.
- **Models know nothing about ViewModels.** Models are passive data.
- **Services are protocol-first.** Every service has a protocol (e.g., `AuthServiceProtocol`) and a concrete implementation. ViewModels depend on the **protocol**, never the concrete type. This enables mocking for ATDD.
- **Dependency Injection:** ViewModels receive their dependencies via the initializer. No singletons inside ViewModels.

### File Organization

```
Group-14/
└── Features/
    └── [FeatureName]/
        ├── Models/         # FeatureModel.swift
        ├── ViewModels/     # FeatureViewModel.swift
        └── Views/          # FeatureView.swift
```

---

## Git Branching & Workflow Rules

- **Always Sync First:** Before writing any code or creating a new branch, you MUST run `git checkout main`, followed by `git pull origin main` to ensure you are capturing the absolute latest state of the codebase.
- **Branch from Main:** When instructed to create a new feature branch, it MUST be branched directly off the updated `main` branch. Never branch off older feature branches or detached cursors.
- **Branch Naming:**
  - `feature/[name]` — new functionality.
  - `test/[name]` — acceptance test additions.
  - `fix/[name]` — bug fixes.
  - `refactor/[name]` — non-behavioral changes.
- **No Ghost Code:** If you encounter references to deleted features while writing code, IGNORE them. Do not attempt to automatically resurrect deleted models or SwiftUI views.
- **Commit Discipline:** One acceptance test + the code that makes it pass = one commit, where reasonable. Commit messages should describe behavior, not implementation (e.g., `"User can submit login form with valid credentials"`).

---

## Agent Workflow

1. **Analyze:** Read `plans/master_plan.md` to identify the active feature.
2. **Deep Dive:** Open `plans/feature_[name].md` for detailed steps.
   - If no plan exists, ASK the user to help draft one.
3. **Execute (ATDD):** For each step:
   - (a) Write the acceptance test in `Group-14Tests/` describing the user-facing behavior.
   - (b) Run the test — it MUST fail (Red).
   - (c) Implement the minimum ViewModel/Model/Service code to make it pass (Green).
   - (d) Refactor without changing behavior; tests must remain green.
   - (e) Build the View layer and verify in `#Preview`.
   - One step at a time.
4. **Verify:**
   - Run `xcodebuild ... test` — all tests pass.
   - Check Xcode `#Preview` renders correctly.
5. **Reflect:** Update the plan file (mark `[x]` Done) and commit.

---

## Codebase Map

```
Group-14 main/
├── CLAUDE.md                       # 📍 THIS FILE — mandatory rules
├── plans/                          # 📍 SOURCE OF TRUTH
│   ├── master_plan.md              # High-level roadmap & links to sub-plans
│   ├── feature_[name].md           # Per-feature plans
│   └── deployment_checklist.md     # 🔴 Security & Production Checklist
└── Group-14/
    ├── Group-14.xcodeproj          # Xcode project
    └── Group-14/                   # SwiftUI Source Files
        ├── Group_14App.swift       # App entry point
        ├── ContentView.swift       # Root view (refactor into Features/ as project grows)
        ├── Assets.xcassets         # Images, colors, app icon
        ├── Core/                   # Shared infrastructure
        │   ├── Services/           # Concrete service implementations
        │   │   └── Protocols/      # Service protocol definitions (for DI + mocking)
        │   ├── Networking/         # URLSession wrappers, API clients
        │   └── Extensions/         # Swift/SwiftUI extensions
        └── Features/               # MVVM feature folders
            └── [FeatureName]/
                ├── Models/
                ├── ViewModels/
                └── Views/
    └── Group-14Tests/              # Acceptance + Unit Tests
        ├── Features/               # Mirrors Features/ layout
        │   └── [FeatureName]/
        │       ├── [Feature]AcceptanceTests.swift
        │       └── [Feature]ViewModelTests.swift
        └── Mocks/                  # Mock implementations of service protocols
```

---

## Progressive Disclosure

- `plans/master_plan.md` — current roadmap and active feature pointer.
- `docs/architecture.md` — MVVM rationale, dependency-injection patterns, and example flows (create when needed).
- `docs/atdd_examples.md` — canonical acceptance test patterns for this project (create when needed).
