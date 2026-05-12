//
//  LearnerProfileCreationViewModelTests.swift
//  Group-14Tests — Features/LearnerProfileCreation
//
//  Lower-level: verifies the `CreateLearnerRequest` payload built from VM state.
//

import XCTest
@testable import Group_14

@MainActor
final class LearnerProfileCreationViewModelTests: XCTestCase {

    private func waitForSubmissionToFinish(
        on sut: LearnerProfileCreationViewModel,
        timeout: TimeInterval = 2.0
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while sut.state == .submitting && Date() < deadline {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }

    func test_submit_buildsRequestMatchingViewModelState() async {
        let mock = MockLearnerProfileService()
        let sut = LearnerProfileCreationViewModel(service: mock)

        sut.name = "  Sofia Rodriguez  "        // leading/trailing whitespace
        sut.typeOfSchool = SchoolType.communityCollege.rawValue
        sut.graduationYear = 2028
        sut.gender = Gender.nonBinary.rawValue
        sut.occupationMajor = " Data Science "
        sut.currentConfidenceScore = 420
        sut.profilePicture = Data([0x01, 0x02])

        sut.submit()
        await waitForSubmissionToFinish(on: sut)

        XCTAssertEqual(mock.capturedRequests.count, 1)
        let req = mock.capturedRequests[0]
        XCTAssertEqual(req.name, "Sofia Rodriguez")              // trimmed
        XCTAssertEqual(req.typeOfSchool, "Community College")
        XCTAssertEqual(req.graduationYear, 2028)
        XCTAssertEqual(req.gender, "Non-Binary")
        XCTAssertEqual(req.occupationMajor, "Data Science")      // trimmed
        XCTAssertEqual(req.currentConfidenceScore, 420)
        XCTAssertEqual(req.profilePicture, Data([0x01, 0x02]))
    }

    func test_submit_isNoOp_whenCanSubmitFalse() async {
        let mock = MockLearnerProfileService()
        let sut = LearnerProfileCreationViewModel(service: mock)
        // Leave all fields blank — canSubmit is false.

        sut.submit()
        await waitForSubmissionToFinish(on: sut)

        XCTAssertTrue(mock.capturedRequests.isEmpty)
        XCTAssertEqual(sut.state, .editing)
    }
}
