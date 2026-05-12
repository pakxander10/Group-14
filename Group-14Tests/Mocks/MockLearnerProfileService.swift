//
//  MockLearnerProfileService.swift
//  Group-14Tests — Mocks
//
//  Configurable success/failure mock for LearnerProfileServiceProtocol.
//

import Foundation
@testable import Group_14

final class MockLearnerProfileService: LearnerProfileServiceProtocol {

    enum Result {
        case success(LearnerProfile)
        case failure(Error)
    }

    var result: Result
    private(set) var capturedRequests: [CreateLearnerRequest] = []

    init(result: Result = .success(MockLearnerProfileService.defaultLearner)) {
        self.result = result
    }

    func create(_ request: CreateLearnerRequest) async throws -> LearnerProfile {
        capturedRequests.append(request)
        switch result {
        case .success(let learner): return learner
        case .failure(let error):   throw error
        }
    }

    // MARK: - Convenience fixtures

    static let defaultLearner = LearnerProfile(
        id: "u_test",
        name: "Test Learner",
        age: 0,
        background: "general",
        interest: "financial",
        goal: "career",
        confidenceScore: 100,
        profilePicture: nil,
        typeOfSchool: "4-Year University",
        graduationYear: 2027,
        gender: "Prefer Not to Say",
        occupationMajor: "Computer Science"
    )
}

// MARK: - Test errors

enum TestError: LocalizedError {
    case generic(String)
    var errorDescription: String? {
        switch self {
        case .generic(let msg): return msg
        }
    }
}
