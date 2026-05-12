//
//  ConfidenceAcceptanceTests.swift
//  Group-14Tests — Features/Confidence
//
//  ATDD for the Finance-Exclusive Readiness Ladder.
//  Each test reads as a Given-When-Then sentence describing a user behavior.
//

import XCTest
@testable import Group_14

final class ConfidenceAcceptanceTests: XCTestCase {

    // MARK: - T1: Financial learner earns +25 on their first Financial post

    func test_givenFinancialLearnerWithNoPosts_whenTheyPostFirstFinanceQuestion_thenScoreIncreasesBy25() async throws {
        // Given a Financial-track learner with no posts and a known starting score
        let mock = MockThreadService()
        mock.seedLearner(id: "u1", name: "Sofia Rodriguez", interest: "financial", score: 100)

        // When they create their first Financial question
        _ = try await mock.createPost(
            CreatePostRequest(
                authorId: "u1",
                category: ThreadCategory.financial.rawValue,
                title: "How do I start budgeting?",
                body: "I take home $2k/month — where do I begin?"
            )
        )

        // Then their confidence score has increased by the first-post bonus.
        XCTAssertEqual(
            mock.learnerScores["u1"],
            100 + MockThreadService.firstFinancePostBonus,
            "First Financial post by a Financial learner grants +\(MockThreadService.firstFinancePostBonus)."
        )
    }

    // MARK: - T2: Tech learner earns nothing — even though the post is saved

    func test_givenTechLearnerWithNoPosts_whenTheyPostFirstQuestion_thenScoreRemainsUnchanged() async throws {
        // Given a Tech-track learner with no posts and a known starting score
        let mock = MockThreadService()
        mock.seedLearner(id: "u2", name: "Kezia Mensah", interest: "tech", score: 100)

        // When they create a Tech question (note: action processes normally)
        let post = try await mock.createPost(
            CreatePostRequest(
                authorId: "u2",
                category: ThreadCategory.tech.rawValue,
                title: "Which JS framework should I learn first?",
                body: "Bootcamp grad — React vs. Vue?"
            )
        )
        XCTAssertNotNil(mock.posts[post.id], "The Tech post must still be saved.")

        // Then the confidence score is unchanged — Tech is outside the ladder.
        XCTAssertEqual(
            mock.learnerScores["u2"], 100,
            "Tech-track learners do not earn confidence points."
        )
    }

    // MARK: - T3: Score 300 maps to Tier 2 — "The Safety Net"

    func test_givenConfidenceScoreOf300_thenActiveTierIsTheSafetyNet() {
        // Given a Financial learner whose current score is 300
        let score = ConfidenceScore(userId: "u1", score: 300)

        // Then the active tier is Tier 2: "The Safety Net" with the HYSA prompt.
        XCTAssertEqual(
            score.tier.displayName,
            "The Safety Net",
            "Score 300 should map to Tier 2: The Safety Net."
        )
        XCTAssertEqual(
            score.tier.readinessPrompt,
            "Ready to open a High-Yield Savings Account (HYSA).",
            "Tier 2's prompt should describe the real-world next step."
        )
    }
}
