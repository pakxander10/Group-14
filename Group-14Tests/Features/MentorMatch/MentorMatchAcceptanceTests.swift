//
//  MentorMatchAcceptanceTests.swift
//  Group-14Tests — Features/MentorMatch
//
//  ATDD for the two mentor-matching wizards (Financial + Career).
//  Each test reads as a Given-When-Then sentence describing a user behavior.
//
//  Note: every test method is `async`. We tried synchronous `@MainActor`
//  tests first and they crashed at process teardown with a malloc
//  double-free at a stable address — an interaction between Swift 6 strict
//  concurrency, Combine's `ObservableObject` machinery, and the XCTest
//  runner's per-test deinit path. Marking the test `async` (even with no
//  awaits) routes the test through the Swift Concurrency runtime, which
//  tears down cleanly.
//

import XCTest
@testable import Group_14

final class MentorMatchAcceptanceTests: XCTestCase {

    // MARK: - Financial wizard

    @MainActor
    func test_givenNewFinancialWizard_whenNothingSelected_thenUserCannotAdvance() async {
        // Given a fresh financial-match wizard
        let vm = FinancialMatchViewModel()

        // Then the user is on the first step and cannot move forward.
        XCTAssertEqual(vm.currentStep, 0, "New wizard always starts at step 0.")
        XCTAssertFalse(vm.canAdvance, "Step 0 requires an intent before advancing.")
    }

    @MainActor
    func test_givenFinancialWizardOnSituationStep_whenUserPicksASituation_thenTheyCanAdvanceAndMoveNext() async {
        // Given a fresh financial-match wizard
        let vm = FinancialMatchViewModel()

        // When the user selects a situation on screen 1
        vm.selectedSituation = "first_full_time"

        // Then advancing is unlocked and nextStep moves to step 1.
        XCTAssertTrue(vm.canAdvance, "Selecting a situation unlocks advancing.")
        vm.nextStep()
        XCTAssertEqual(vm.currentStep, 1, "nextStep advances to the next step.")
    }

    @MainActor
    func test_givenFinancialWizardOnAccountsStep_whenUserTogglesAccounts_thenSelectionIsTracked() async {
        // Given a financial-match wizard on the accounts step (step 2)
        let vm = FinancialMatchViewModel()
        vm.currentStep = 2

        // When the user toggles two accounts
        vm.toggleAccount("checking")
        vm.toggleAccount("savings")

        // Then both are selected and canAdvance is true.
        XCTAssertTrue(vm.selectedAccounts.contains("checking"))
        XCTAssertTrue(vm.selectedAccounts.contains("savings"))
        XCTAssertTrue(vm.canAdvance, "At least one account selected allows advancing.")

        // When the user toggles checking off
        vm.toggleAccount("checking")

        // Then it is removed.
        XCTAssertFalse(vm.selectedAccounts.contains("checking"))
    }

    @MainActor
    func test_givenCompletedFinancialWizard_whenUserSubmits_thenMatchedMentorIsRevealed() async {
        // Given a completed financial-match wizard
        let vm = FinancialMatchViewModel()

        // When the user submits
        vm.submit()

        // Then after the loading window the wizard reports completion with a mentor.
        await waitUntil(timeout: 3) { vm.isComplete }
        XCTAssertTrue(vm.isComplete, "Submission flips isComplete once matching finishes.")
        XCTAssertFalse(vm.isLoading, "isLoading clears once submission completes.")
        XCTAssertNotNil(vm.matchedMentor, "A mentor is surfaced from the financial pool on submit.")
        XCTAssertEqual(vm.matchedMentor?.track, "Financial", "Financial wizard surfaces a Financial-track mentor.")
    }

    // MARK: - Career wizard

    @MainActor
    func test_givenNewCareerWizard_whenNothingSelected_thenUserCannotAdvance() async {
        // Given a fresh career-match wizard
        let vm = CareerMatchViewModel()

        // Then the user is on the first step and cannot move forward.
        XCTAssertEqual(vm.currentStep, 0, "New wizard always starts at step 0.")
        XCTAssertFalse(vm.canAdvance, "Step 0 requires a career stage selection before advancing.")
    }

    @MainActor
    func test_givenCareerWizardOnCareerStageStep_whenUserPicksAStage_thenTheyCanAdvanceAndMoveNext() async {
        // Given a fresh career-match wizard
        let vm = CareerMatchViewModel()

        // When the user selects a career stage
        vm.selectedCareerStage = "first_role_growing"

        // Then advancing is unlocked and nextStep moves to step 1.
        XCTAssertTrue(vm.canAdvance, "Selecting a career stage unlocks advancing.")
        vm.nextStep()
        XCTAssertEqual(vm.currentStep, 1, "nextStep advances to the next step.")
    }

    @MainActor
    func test_givenCompletedCareerWizard_whenUserSubmits_thenMatchedMentorIsRevealed() async {
        // Given a completed career-match wizard
        let vm = CareerMatchViewModel()

        // When the user submits
        vm.submit()

        // Then after the loading window the wizard reports completion with a Tech mentor.
        await waitUntil(timeout: 3) { vm.isComplete }
        XCTAssertTrue(vm.isComplete, "Submission flips isComplete once matching finishes.")
        XCTAssertNotNil(vm.matchedMentor, "A mentor is surfaced from the career pool on submit.")
        XCTAssertEqual(vm.matchedMentor?.track, "Tech", "Career wizard surfaces a Tech-track mentor.")
    }

    // MARK: - Helpers

    /// Polls until `condition` is true or the timeout elapses. Keeps tests deterministic
    /// without coupling to the wizard's internal 1.5s sleep.
    @MainActor
    private func waitUntil(
        timeout: TimeInterval,
        condition: () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
    }
}
