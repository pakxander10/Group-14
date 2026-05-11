//
//  LearnerProfileCreationAcceptanceTests.swift
//  Group-14Tests — Features/LearnerProfileCreation
//
//  ATDD acceptance tests. Black-box against the ViewModel surface.
//  No SwiftUI, no network.
//

import XCTest
@testable import Group_14

@MainActor
final class LearnerProfileCreationAcceptanceTests: XCTestCase {

    // MARK: - Helpers

    private func makeViewModel(
        result: MockLearnerProfileService.Result = .success(MockLearnerProfileService.defaultLearner)
    ) -> (LearnerProfileCreationViewModel, MockLearnerProfileService) {
        let mock = MockLearnerProfileService(result: result)
        let sut = LearnerProfileCreationViewModel(service: mock)
        return (sut, mock)
    }

    private func fillRequiredFields(on sut: LearnerProfileCreationViewModel) {
        sut.name = "Sofia Rodriguez"
        sut.typeOfSchool = SchoolType.fourYear.rawValue
        sut.graduationYear = 2027
        sut.gender = Gender.woman.rawValue
        sut.occupationMajor = "Computer Science"
        sut.currentConfidenceScore = 250
    }

    /// Spin the run loop until the VM exits `.submitting`.
    private func waitForSubmissionToFinish(
        on sut: LearnerProfileCreationViewModel,
        timeout: TimeInterval = 2.0
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while sut.state == .submitting && Date() < deadline {
            try? await Task.sleep(nanoseconds: 5_000_000) // 5ms
        }
    }

    // MARK: - 1

    func test_givenAllRequiredFieldsFilled_whenUserSubmits_thenStateTransitionsToCreated() async {
        let (sut, mock) = makeViewModel()
        fillRequiredFields(on: sut)

        XCTAssertTrue(sut.canSubmit)
        sut.submit()
        await waitForSubmissionToFinish(on: sut)

        guard case .created(let learner) = sut.state else {
            return XCTFail("Expected .created, got \(sut.state)")
        }
        XCTAssertEqual(learner.id, MockLearnerProfileService.defaultLearner.id)
        XCTAssertEqual(mock.capturedRequests.count, 1)
    }

    // MARK: - 2

    func test_givenNameIsEmpty_whenUserSubmits_thenStateStaysEditing_andCanSubmitIsFalse() async {
        let (sut, mock) = makeViewModel()
        fillRequiredFields(on: sut)
        sut.name = ""

        XCTAssertFalse(sut.canSubmit)
        sut.submit()
        await waitForSubmissionToFinish(on: sut)

        XCTAssertEqual(sut.state, .editing)
        XCTAssertTrue(mock.capturedRequests.isEmpty)
    }

    // MARK: - 3

    func test_givenOccupationMajorIsWhitespaceOnly_whenUserSubmits_thenCanSubmitIsFalse() async {
        let (sut, _) = makeViewModel()
        fillRequiredFields(on: sut)
        sut.occupationMajor = "    \n  "

        XCTAssertFalse(sut.canSubmit)
    }

    // MARK: - 4

    func test_givenServiceThrows_whenUserSubmits_thenStateTransitionsToFailed_withErrorMessage() async {
        let (sut, _) = makeViewModel(result: .failure(TestError.generic("boom")))
        fillRequiredFields(on: sut)

        sut.submit()
        await waitForSubmissionToFinish(on: sut)

        guard case .failed(let message) = sut.state else {
            return XCTFail("Expected .failed, got \(sut.state)")
        }
        XCTAssertEqual(message, "boom")
    }

    // MARK: - 5

    func test_givenScoreBelowOne_whenUserSubmits_thenCanSubmitIsFalse() async {
        let (sut, _) = makeViewModel()
        fillRequiredFields(on: sut)
        sut.currentConfidenceScore = 0

        XCTAssertFalse(sut.canSubmit)
    }

    // MARK: - 6

    func test_givenScoreAboveOneThousand_whenUserSubmits_thenCanSubmitIsFalse() async {
        let (sut, _) = makeViewModel()
        fillRequiredFields(on: sut)
        sut.currentConfidenceScore = 1001

        XCTAssertFalse(sut.canSubmit)
    }

    // MARK: - 7

    func test_givenProfilePictureIsNil_whenUserSubmits_thenStateTransitionsToCreated() async {
        let (sut, _) = makeViewModel()
        fillRequiredFields(on: sut)
        sut.profilePicture = nil

        XCTAssertTrue(sut.canSubmit)
        sut.submit()
        await waitForSubmissionToFinish(on: sut)

        guard case .created = sut.state else {
            return XCTFail("Expected .created, got \(sut.state)")
        }
    }

    // MARK: - 8

    func test_whenReset_thenAllFieldsClearedAndStateIsEditing() async {
        let (sut, _) = makeViewModel()
        fillRequiredFields(on: sut)
        sut.profilePicture = Data([0xFF, 0xD8, 0xFF])

        sut.reset()

        XCTAssertEqual(sut.name, "")
        XCTAssertNil(sut.profilePicture)
        XCTAssertEqual(sut.typeOfSchool, "")
        XCTAssertEqual(sut.gender, "")
        XCTAssertEqual(sut.occupationMajor, "")
        XCTAssertEqual(sut.currentConfidenceScore, 100)
        XCTAssertEqual(sut.state, .editing)
    }
}
