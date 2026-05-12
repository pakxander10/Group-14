//
//  ProfileEditingAcceptanceTests.swift
//  Group-14Tests — Features/Profile
//
//  ATDD for the "edit your profile" flow available to both learners and
//  mentors after onboarding. Black-box against the ViewModel surface.
//

import XCTest
@testable import Group_14

final class ProfileEditingAcceptanceTests: XCTestCase {

    // MARK: - Fixtures

    private static let baselineLearner = LearnerProfile(
        id: "u_test",
        name: "Sofia Rodriguez",
        age: 19,
        background: "first_gen",
        interest: "tech",
        goal: "career",
        confidenceScore: 250,
        profilePicture: nil,
        typeOfSchool: "4-Year University",
        graduationYear: 2027,
        gender: "Woman",
        occupationMajor: "Computer Science"
    )

    private static let baselineMentor = MentorProfile(
        id: "m_test",
        name: "Sarah Chen",
        title: "Senior Software Engineer",
        company: "Fidelity",
        track: "Tech",
        bio: "Original bio",
        expertise: ["System Design", "iOS"],
        yearsExperience: 12,
        avatarInitials: "SC",
        email: "sarah@fidelity.com",
        linkedInUrl: nil,
        educationHistory: nil,
        profilePicture: nil
    )

    // MARK: - Mock service

    private final class MockProfileService: ProfileServiceProtocol {
        var learnerFetchResult: Result<LearnerProfile, Error>
        var mentorFetchResult: Result<MentorProfile, Error>
        var learnerUpdateResult: Result<LearnerProfile, Error>
        var mentorUpdateResult: Result<MentorProfile, Error>

        private(set) var capturedLearnerUpdates: [(id: String, request: UpdateLearnerRequest)] = []
        private(set) var capturedMentorUpdates: [(id: String, request: UpdateMentorRequest)] = []

        init(
            learnerFetch: Result<LearnerProfile, Error> = .success(baselineLearner),
            mentorFetch: Result<MentorProfile, Error> = .success(baselineMentor),
            learnerUpdate: Result<LearnerProfile, Error> = .success(baselineLearner),
            mentorUpdate: Result<MentorProfile, Error> = .success(baselineMentor)
        ) {
            self.learnerFetchResult = learnerFetch
            self.mentorFetchResult = mentorFetch
            self.learnerUpdateResult = learnerUpdate
            self.mentorUpdateResult = mentorUpdate
        }

        func fetchLearner(id: String) async throws -> LearnerProfile {
            try learnerFetchResult.get()
        }
        func fetchMentor(id: String) async throws -> MentorProfile {
            try mentorFetchResult.get()
        }
        func updateLearner(id: String, _ request: UpdateLearnerRequest) async throws -> LearnerProfile {
            capturedLearnerUpdates.append((id, request))
            return try learnerUpdateResult.get()
        }
        func updateMentor(id: String, _ request: UpdateMentorRequest) async throws -> MentorProfile {
            capturedMentorUpdates.append((id, request))
            return try mentorUpdateResult.get()
        }
    }

    // MARK: - Helpers

    @MainActor
    private func makeViewModel(
        service: MockProfileService = MockProfileService()
    ) -> (ProfileViewModel, MockProfileService) {
        let vm = ProfileViewModel(service: service)
        return (vm, service)
    }

    @MainActor
    private func loadMentor(_ vm: ProfileViewModel) async {
        vm.loadMentor(userId: Self.baselineMentor.id)
        await waitUntil { vm.mentor != nil }
    }

    @MainActor
    private func loadLearner(_ vm: ProfileViewModel) async {
        vm.loadLearner(userId: Self.baselineLearner.id)
        await waitUntil { vm.learner != nil }
    }

    @MainActor
    private func waitUntil(
        timeout: TimeInterval = 2.0,
        _ condition: () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }

    // MARK: - B1

    @MainActor
    func test_givenLoadedMentor_whenBeginEditing_thenEditingDraftMatchesMentor() async {
        let (vm, _) = makeViewModel()
        await loadMentor(vm)

        vm.beginEditMentor()

        XCTAssertNotNil(vm.editingMentor)
        XCTAssertEqual(vm.editingMentor?.bio, Self.baselineMentor.bio)
        XCTAssertEqual(vm.editingMentor?.expertise, Self.baselineMentor.expertise)
    }

    // MARK: - B2

    @MainActor
    func test_givenEditedMentor_whenSaving_thenServiceUpdateCalled_andMentorRefreshed() async {
        let updated = MentorProfile(
            id: Self.baselineMentor.id,
            name: Self.baselineMentor.name,
            title: Self.baselineMentor.title,
            company: Self.baselineMentor.company,
            track: Self.baselineMentor.track,
            bio: "Updated bio",
            expertise: ["System Design"],
            yearsExperience: 12,
            avatarInitials: "SC",
            email: Self.baselineMentor.email,
            linkedInUrl: nil,
            educationHistory: nil,
            profilePicture: nil
        )
        let service = MockProfileService(mentorUpdate: .success(updated))
        let (vm, _) = makeViewModel(service: service)
        await loadMentor(vm)

        vm.beginEditMentor()
        vm.editingMentor?.bio = "Updated bio"
        vm.editingMentor?.expertise = ["System Design"]
        vm.saveMentorEdit()
        await waitUntil { vm.mentor?.bio == "Updated bio" }

        XCTAssertEqual(service.capturedMentorUpdates.count, 1)
        XCTAssertEqual(service.capturedMentorUpdates.first?.id, Self.baselineMentor.id)
        XCTAssertEqual(service.capturedMentorUpdates.first?.request.bio, "Updated bio")
        XCTAssertEqual(vm.mentor?.bio, "Updated bio")
        XCTAssertNil(vm.editingMentor, "Successful save dismisses the draft.")
    }

    // MARK: - B3

    @MainActor
    func test_givenMentorUpdateFails_whenSaving_thenOriginalMentorPreserved_andErrorSet() async {
        let service = MockProfileService(mentorUpdate: .failure(TestError.generic("offline")))
        let (vm, _) = makeViewModel(service: service)
        await loadMentor(vm)

        vm.beginEditMentor()
        vm.editingMentor?.bio = "Doomed bio"
        vm.saveMentorEdit()
        await waitUntil { vm.errorMessage != nil }

        XCTAssertEqual(vm.mentor?.bio, Self.baselineMentor.bio,
                       "Original mentor stays in place when the update fails.")
        XCTAssertEqual(vm.errorMessage, "offline")
    }

    // MARK: - B4 (learner mirror of B1–B3)

    @MainActor
    func test_givenLoadedLearner_whenBeginEditing_thenEditingDraftMatchesLearner() async {
        let (vm, _) = makeViewModel()
        await loadLearner(vm)

        vm.beginEditLearner()

        XCTAssertNotNil(vm.editingLearner)
        XCTAssertEqual(vm.editingLearner?.goal, Self.baselineLearner.goal)
    }

    @MainActor
    func test_givenEditedLearner_whenSaving_thenServiceUpdateCalled_andLearnerRefreshed() async {
        let updated = LearnerProfile(
            id: Self.baselineLearner.id,
            name: "Sofia R.",
            age: Self.baselineLearner.age,
            background: Self.baselineLearner.background,
            interest: "financial",
            goal: "buying_a_house",
            confidenceScore: Self.baselineLearner.confidenceScore,
            profilePicture: nil,
            typeOfSchool: Self.baselineLearner.typeOfSchool,
            graduationYear: Self.baselineLearner.graduationYear,
            gender: Self.baselineLearner.gender,
            occupationMajor: "Mathematics"
        )
        let service = MockProfileService(learnerUpdate: .success(updated))
        let (vm, _) = makeViewModel(service: service)
        await loadLearner(vm)

        vm.beginEditLearner()
        vm.editingLearner?.name = "Sofia R."
        vm.editingLearner?.interest = "financial"
        vm.editingLearner?.goal = "buying_a_house"
        vm.editingLearner?.occupationMajor = "Mathematics"
        vm.saveLearnerEdit()
        await waitUntil { vm.learner?.name == "Sofia R." }

        XCTAssertEqual(service.capturedLearnerUpdates.count, 1)
        XCTAssertEqual(service.capturedLearnerUpdates.first?.request.interest, "financial")
        XCTAssertEqual(vm.learner?.goal, "buying_a_house")
        XCTAssertEqual(vm.learner?.occupationMajor, "Mathematics")
        XCTAssertNil(vm.editingLearner)
    }

    @MainActor
    func test_givenLearnerUpdateFails_whenSaving_thenOriginalLearnerPreserved_andErrorSet() async {
        let service = MockProfileService(learnerUpdate: .failure(TestError.generic("network down")))
        let (vm, _) = makeViewModel(service: service)
        await loadLearner(vm)

        vm.beginEditLearner()
        vm.editingLearner?.goal = "stocks"
        vm.saveLearnerEdit()
        await waitUntil { vm.errorMessage != nil }

        XCTAssertEqual(vm.learner?.goal, Self.baselineLearner.goal)
        XCTAssertEqual(vm.errorMessage, "network down")
    }

    @MainActor
    func test_whenCancellingEdit_thenDraftIsDiscarded() async {
        let (vm, _) = makeViewModel()
        await loadLearner(vm)

        vm.beginEditLearner()
        vm.editingLearner?.goal = "stocks"
        vm.cancelEdit()

        XCTAssertNil(vm.editingLearner)
        XCTAssertEqual(vm.learner?.goal, Self.baselineLearner.goal)
    }
}
