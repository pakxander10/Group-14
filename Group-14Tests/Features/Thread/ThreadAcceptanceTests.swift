//
//  ThreadAcceptanceTests.swift
//  Group-14Tests — Features/Thread
//
//  ATDD: each test describes user-facing behavior in Given–When–Then form.
//  Tests run against MockThreadService, which mirrors the backend's
//  side-effects (notification append + confidence bump) on mentor reply.
//

import XCTest
@testable import Group_14

final class ThreadAcceptanceTests: XCTestCase {

    // MARK: - T1: Notification reaches the learner's inbox

    func test_givenLearnerPostedQuestion_whenMentorReplies_thenLearnerInboxReceivesNotification() async throws {
        // Given a learner posted a question
        let mock = MockThreadService()
        mock.seedLearner(id: "u1", name: "Sofia Rodriguez", score: 100)
        mock.seedMentor(id: "m1", name: "Priya Sharma")

        let post = try await mock.createPost(
            CreatePostRequest(
                authorId: "u1",
                category: ThreadCategory.financial.rawValue,
                title: "How do I start investing?",
                body: "I can save $50/month — is it worth it?"
            )
        )

        // Sanity: learner inbox is empty before the reply.
        let before = try await mock.fetchInbox(learnerId: "u1")
        XCTAssertTrue(before.isEmpty, "Inbox should start empty")

        // When a mentor replies to that post
        _ = try await mock.createReply(
            CreateReplyRequest(
                postId: post.id,
                authorId: "m1",
                body: "Absolutely. Open a Roth IRA at Fidelity with $0 minimum and start with a broad index fund."
            )
        )

        // Then the learner's inbox contains a notification referencing the mentor and the post
        let inbox = try await mock.fetchInbox(learnerId: "u1")
        XCTAssertEqual(inbox.count, 1)

        let notification = try XCTUnwrap(inbox.first)
        XCTAssertEqual(notification.learnerId, "u1")
        XCTAssertEqual(notification.postId, post.id)
        XCTAssertEqual(notification.postTitle, "How do I start investing?")
        XCTAssertEqual(notification.mentorId, "m1")
        XCTAssertEqual(notification.mentorName, "Priya Sharma")
        XCTAssertFalse(notification.replyPreview.isEmpty)
    }

    // MARK: - T2: Mentor reply increments the learner's confidence score

    func test_givenLearnerScoreIs100_whenMentorRepliesToTheirPost_thenScoreIncrements() async throws {
        // Given a learner with score 100 and a posted question
        let mock = MockThreadService()
        mock.seedLearner(id: "u1", name: "Sofia Rodriguez", score: 100)
        mock.seedMentor(id: "m1", name: "Priya Sharma")
        XCTAssertEqual(mock.learnerScores["u1"], 100, "precondition")

        let post = try await mock.createPost(
            CreatePostRequest(
                authorId: "u1",
                category: ThreadCategory.financial.rawValue,
                title: "Roth IRA question",
                body: "Where should I begin?"
            )
        )

        // When a mentor replies
        _ = try await mock.createReply(
            CreateReplyRequest(
                postId: post.id,
                authorId: "m1",
                body: "Start small and stay consistent."
            )
        )

        // Then the learner's confidence score has incremented by the boost amount
        XCTAssertEqual(
            mock.learnerScores["u1"],
            100 + MockThreadService.mentorReplyConfidenceBoost,
            "Confidence score should increase by \(MockThreadService.mentorReplyConfidenceBoost) when a mentor replies."
        )
    }
}
