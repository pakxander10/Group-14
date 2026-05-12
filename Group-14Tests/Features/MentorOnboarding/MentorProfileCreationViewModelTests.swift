//
//  MentorProfileCreationViewModelTests.swift
//  Group-14Tests — Features/MentorOnboarding
//
//  ATDD for the searchable multi-select expertise picker on the mentor
//  onboarding form. Black-box against the ViewModel surface.
//
//  Async tests for the same reason `MentorMatchAcceptanceTests` are async —
//  Swift 6 + Combine + XCTest interaction crashes on sync teardown.
//

import XCTest
@testable import Group_14

final class MentorProfileCreationViewModelTests: XCTestCase {

    // MARK: - Helpers

    private final class MockMentorOnboardingService: MentorOnboardingServiceProtocol {
        var capturedRequests: [CreateMentorRequest] = []
        var result: Result<MentorProfile, Error>

        init(result: Result<MentorProfile, Error> = .success(.testMentor)) {
            self.result = result
        }

        func createMentor(_ request: CreateMentorRequest) async throws -> MentorProfile {
            capturedRequests.append(request)
            switch result {
            case .success(let mentor): return mentor
            case .failure(let error): throw error
            }
        }
    }

    @MainActor
    private func makeViewModel(
        result: Result<MentorProfile, Error> = .success(.testMentor)
    ) -> (MentorProfileCreationViewModel, MockMentorOnboardingService) {
        let mock = MockMentorOnboardingService(result: result)
        let sut = MentorProfileCreationViewModel(service: mock)
        return (sut, mock)
    }

    @MainActor
    private func fillRequiredNonExpertiseFields(on sut: MentorProfileCreationViewModel) {
        sut.name = "Sarah Chen"
        sut.title = "Senior Software Engineer"
        sut.company = "Fidelity"
        sut.track = MentorTrack.tech.rawValue
        sut.bio = "First-gen engineer mentoring early-career devs."
        sut.yearsExperience = 8
    }

    @MainActor
    private func waitForSubmissionToFinish(
        on sut: MentorProfileCreationViewModel,
        timeout: TimeInterval = 2.0
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while sut.state == .submitting && Date() < deadline {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }

    // MARK: - A1

    @MainActor
    func test_givenFreshViewModel_thenSelectedExpertiseIsEmptyAndCanSubmitIsFalse() async {
        let (sut, _) = makeViewModel()
        XCTAssertTrue(sut.selectedExpertise.isEmpty)
        XCTAssertFalse(sut.canSubmit, "Empty expertise blocks submission.")
    }

    // MARK: - A2

    @MainActor
    func test_givenFinancialTrack_whenSearchingForRoth_thenOnlyFinancialPoolTermsMatch() async {
        let (sut, _) = makeViewModel()
        sut.track = MentorTrack.financial.rawValue
        sut.searchQuery = "roth"

        let suggestions = sut.expertiseSuggestions
        XCTAssertTrue(suggestions.contains("Roth IRA"), "Roth IRA must appear for the query 'roth'.")
        // No tech term should match "roth"
        XCTAssertFalse(suggestions.contains { $0 == "iOS" })
    }

    // MARK: - A3

    @MainActor
    func test_givenTechTrack_whenSearchingForInterview_thenOnlyTechPoolTermsMatch() async {
        let (sut, _) = makeViewModel()
        sut.track = MentorTrack.tech.rawValue
        sut.searchQuery = "interview"

        let suggestions = sut.expertiseSuggestions
        XCTAssertTrue(suggestions.contains("Interview Prep"))
        XCTAssertFalse(suggestions.contains("Roth IRA"))
    }

    // MARK: - A4

    @MainActor
    func test_givenNoTrackSelected_whenSearchingIsEmpty_thenSuggestionsCoverBothPools() async {
        let (sut, _) = makeViewModel()
        sut.track = ""
        sut.searchQuery = ""

        // The merged pool contains terms from BOTH lists.
        let merged = sut.expertiseSuggestions
        let mergedHasFinancial = merged.contains(where: { ExpertiseCatalog.financialTerms.contains($0) })
        let mergedHasTech      = merged.contains(where: { ExpertiseCatalog.techTerms.contains($0) })
        XCTAssertTrue(mergedHasFinancial, "Merged pool must include financial terms when no track is picked.")
        XCTAssertTrue(mergedHasTech,      "Merged pool must include tech terms when no track is picked.")
    }

    // MARK: - A5

    @MainActor
    func test_givenFinancialTrack_whenAddingRothIRA_thenItAppearsInSelectionAndDropsFromSuggestions() async {
        let (sut, _) = makeViewModel()
        sut.track = MentorTrack.financial.rawValue
        sut.searchQuery = "roth"

        sut.addExpertise("Roth IRA")

        XCTAssertEqual(sut.selectedExpertise, ["Roth IRA"])
        XCTAssertFalse(sut.expertiseSuggestions.contains("Roth IRA"),
                       "Once selected, a term must not reappear as a suggestion.")
    }

    // MARK: - A6

    @MainActor
    func test_givenAlreadySelectedTerm_whenAddedAgain_thenSelectionStaysSingleEntry() async {
        let (sut, _) = makeViewModel()
        sut.track = MentorTrack.financial.rawValue
        sut.addExpertise("Investing")
        sut.addExpertise("Investing")

        XCTAssertEqual(sut.selectedExpertise, ["Investing"])
    }

    // MARK: - A7

    @MainActor
    func test_givenUnknownTerm_whenAdded_thenSelectionIsUnchanged() async {
        let (sut, _) = makeViewModel()
        sut.track = MentorTrack.financial.rawValue
        sut.addExpertise("Banana Futures") // not in any pool

        XCTAssertTrue(sut.selectedExpertise.isEmpty, "Unknown terms must be rejected.")
    }

    // MARK: - A8

    @MainActor
    func test_givenSelectedTerm_whenRemoved_thenItLeavesSelectionAndSearchClears() async {
        let (sut, _) = makeViewModel()
        sut.track = MentorTrack.financial.rawValue
        sut.addExpertise("Budgeting")
        sut.searchQuery = "bud"

        sut.removeExpertise("Budgeting")

        XCTAssertTrue(sut.selectedExpertise.isEmpty)
        XCTAssertEqual(sut.searchQuery, "", "Removing clears the query so the user can browse again.")
    }

    // MARK: - A9

    @MainActor
    func test_givenAllRequiredFieldsAndOneExpertise_thenCanSubmitFlipsTrue() async {
        let (sut, _) = makeViewModel()
        fillRequiredNonExpertiseFields(on: sut)
        XCTAssertFalse(sut.canSubmit, "Without expertise the form is still incomplete.")

        sut.addExpertise("Interview Prep")
        XCTAssertTrue(sut.canSubmit)
    }

    // MARK: - A10

    @MainActor
    func test_whenUserSubmits_thenSelectedExpertiseFlowsIntoRequest() async {
        let (sut, mock) = makeViewModel()
        fillRequiredNonExpertiseFields(on: sut)
        sut.addExpertise("System Design")
        sut.addExpertise("iOS")

        sut.submit()
        await waitForSubmissionToFinish(on: sut)

        XCTAssertEqual(mock.capturedRequests.count, 1)
        XCTAssertEqual(mock.capturedRequests.first?.expertise, ["System Design", "iOS"])
    }
}

// MARK: - Test fixtures

private extension MentorProfile {
    static let testMentor = MentorProfile(
        id: "m_test",
        name: "Sarah Chen",
        title: "Senior Software Engineer",
        company: "Fidelity",
        track: "Tech",
        bio: "Mentor bio",
        expertise: ["System Design", "iOS"],
        yearsExperience: 8,
        avatarInitials: "SC",
        email: nil,
        linkedInUrl: nil,
        educationHistory: nil,
        profilePicture: nil
    )
}
