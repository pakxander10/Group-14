//
//  ThreadUpvoteAcceptanceTests.swift
//  Group-14Tests — Features/Thread
//
//  ATDD for upvoting a thread post or a mentor reply. Black-box against
//  ThreadViewModel — view-layer concerns (taps, animations) are not tested
//  here.
//

import XCTest
@testable import Group_14

final class ThreadUpvoteAcceptanceTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeLoadedViewModel(
        seed: @MainActor (MockThreadService) -> Void = { _ in }
    ) async -> (ThreadViewModel, MockThreadService, InMemoryUpvoteTracker) {
        let mock = MockThreadService()
        mock.seedLearner(id: "u1", name: "Sofia", interest: "financial", score: 100)
        mock.seedMentor(id: "m1", name: "Priya")
        seed(mock)

        let tracker = InMemoryUpvoteTracker()
        let vm = ThreadViewModel(service: mock, tracker: tracker)
        vm.loadFeed()
        await waitUntil { !vm.posts.isEmpty || vm.errorMessage != nil }
        return (vm, mock, tracker)
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

    // MARK: - A1: upvoting a post updates the local post

    @MainActor
    func test_givenLoadedFeed_whenUpvotingPost_thenLocalPostUpvoteCountIncrements() async {
        let (vm, _, _) = await makeLoadedViewModel { mock in
            mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        }
        XCTAssertEqual(vm.posts.first(where: { $0.id == "p1" })?.upvotes, 0)

        vm.upvotePost(id: "p1", by: "u1")
        await waitUntil { vm.posts.first(where: { $0.id == "p1" })?.upvotes == 1 }

        XCTAssertEqual(vm.posts.first(where: { $0.id == "p1" })?.upvotes, 1)
    }

    // MARK: - A2: upvoting a non-existent id is a no-op

    @MainActor
    func test_givenLoadedFeed_whenUpvotingUnknownPostId_thenNoCrashAndNoServiceCall() async {
        let (vm, mock, _) = await makeLoadedViewModel { mock in
            mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        }

        vm.upvotePost(id: "p_does_not_exist", by: "u1")
        // Give the (skipped) task a moment in case the VM did schedule one.
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(mock.upvotedPostIds, [])
        XCTAssertEqual(vm.posts.first(where: { $0.id == "p1" })?.upvotes, 0)
    }

    // MARK: - A3: service failure on post upvote preserves state

    @MainActor
    func test_givenLoadedFeed_whenUpvotePostFails_thenPostsPreservedAndErrorSet() async {
        let (vm, mock, tracker) = await makeLoadedViewModel { mock in
            mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        }
        mock.throwOnNext = TestError.generic("upvote unavailable")

        vm.upvotePost(id: "p1", by: "u1")
        await waitUntil { vm.errorMessage != nil }

        XCTAssertEqual(vm.posts.first(where: { $0.id == "p1" })?.upvotes, 0)
        XCTAssertEqual(vm.errorMessage, "upvote unavailable")
        // Failure must not lock the user out of retrying — the tracker should
        // still consider this user unvoted.
        XCTAssertFalse(tracker.hasUpvotedPost("p1", by: "u1"))
    }

    // MARK: - A4: upvoting a reply updates that reply nested inside the post

    @MainActor
    func test_givenPostWithReply_whenUpvotingReply_thenReplyUpvoteCountIncrements() async {
        let mock = MockThreadService()
        mock.seedLearner(id: "u1", name: "Sofia", interest: "financial", score: 100)
        mock.seedMentor(id: "m1", name: "Priya")
        mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        _ = try? await mock.createReply(
            CreateReplyRequest(postId: "p1", authorId: "m1", body: "Start with a Roth IRA.")
        )

        let vm = ThreadViewModel(service: mock, tracker: InMemoryUpvoteTracker())
        vm.loadFeed()
        await waitUntil { vm.posts.first?.replies.isEmpty == false }

        let replyId = try! XCTUnwrap(vm.posts.first(where: { $0.id == "p1" })?.replies.first?.id)
        XCTAssertEqual(vm.posts.first?.replies.first?.upvotes, 0)

        vm.upvoteReply(postId: "p1", replyId: replyId, by: "u1")
        await waitUntil {
            vm.posts.first(where: { $0.id == "p1" })?.replies.first?.upvotes == 1
        }

        XCTAssertEqual(vm.posts.first?.replies.first?.upvotes, 1)
    }

    // MARK: - A5: reply upvote failure preserves state

    @MainActor
    func test_givenPostWithReply_whenUpvoteReplyFails_thenRepliesPreservedAndErrorSet() async {
        let mock = MockThreadService()
        mock.seedLearner(id: "u1", name: "Sofia", interest: "financial", score: 100)
        mock.seedMentor(id: "m1", name: "Priya")
        mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        _ = try? await mock.createReply(
            CreateReplyRequest(postId: "p1", authorId: "m1", body: "Start with a Roth IRA.")
        )

        let vm = ThreadViewModel(service: mock, tracker: InMemoryUpvoteTracker())
        vm.loadFeed()
        await waitUntil { vm.posts.first?.replies.isEmpty == false }

        let replyId = try! XCTUnwrap(vm.posts.first?.replies.first?.id)
        mock.throwOnNext = TestError.generic("reply upvote failed")

        vm.upvoteReply(postId: "p1", replyId: replyId, by: "u1")
        await waitUntil { vm.errorMessage != nil }

        XCTAssertEqual(vm.posts.first?.replies.first?.upvotes, 0)
        XCTAssertEqual(vm.errorMessage, "reply upvote failed")
    }

    // MARK: - A6: a learner can only upvote a given post once

    @MainActor
    func test_givenLearnerAlreadyUpvotedPost_whenUpvotingAgain_thenServiceNotCalledTwice() async {
        let (vm, mock, tracker) = await makeLoadedViewModel { mock in
            mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        }

        vm.upvotePost(id: "p1", by: "u1")
        await waitUntil { vm.posts.first(where: { $0.id == "p1" })?.upvotes == 1 }

        XCTAssertTrue(tracker.hasUpvotedPost("p1", by: "u1"))
        XCTAssertTrue(vm.hasUpvotedPost("p1", by: "u1"))
        XCTAssertEqual(mock.upvotedPostIds, ["p1"])

        // Second tap by the same learner should be ignored.
        vm.upvotePost(id: "p1", by: "u1")
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(mock.upvotedPostIds, ["p1"], "service must not be called a second time")
        XCTAssertEqual(vm.posts.first(where: { $0.id == "p1" })?.upvotes, 1)
    }

    // MARK: - A7: a learner can only upvote a given reply once

    @MainActor
    func test_givenLearnerAlreadyUpvotedReply_whenUpvotingAgain_thenServiceNotCalledTwice() async {
        let mock = MockThreadService()
        mock.seedLearner(id: "u1", name: "Sofia", interest: "financial", score: 100)
        mock.seedMentor(id: "m1", name: "Priya")
        mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        _ = try? await mock.createReply(
            CreateReplyRequest(postId: "p1", authorId: "m1", body: "Start with a Roth IRA.")
        )

        let tracker = InMemoryUpvoteTracker()
        let vm = ThreadViewModel(service: mock, tracker: tracker)
        vm.loadFeed()
        await waitUntil { vm.posts.first?.replies.isEmpty == false }

        let replyId = try! XCTUnwrap(vm.posts.first?.replies.first?.id)

        vm.upvoteReply(postId: "p1", replyId: replyId, by: "u1")
        await waitUntil { vm.posts.first?.replies.first?.upvotes == 1 }

        XCTAssertTrue(tracker.hasUpvotedReply(replyId, by: "u1"))
        XCTAssertTrue(vm.hasUpvotedReply(replyId, by: "u1"))
        XCTAssertEqual(mock.upvotedReplyIds.map(\.replyId), [replyId])

        vm.upvoteReply(postId: "p1", replyId: replyId, by: "u1")
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(
            mock.upvotedReplyIds.map(\.replyId), [replyId],
            "service must not be called a second time for the same (user, reply)"
        )
        XCTAssertEqual(vm.posts.first?.replies.first?.upvotes, 1)
    }

    // MARK: - A8: different learners can each upvote the same post once

    @MainActor
    func test_givenDifferentLearners_whenEachUpvotesSamePost_thenBothCountsRegister() async {
        let (vm, mock, tracker) = await makeLoadedViewModel { mock in
            mock.seedPost(id: "p1", authorId: "u1", category: "Financial")
        }

        vm.upvotePost(id: "p1", by: "u1")
        await waitUntil { vm.posts.first(where: { $0.id == "p1" })?.upvotes == 1 }

        vm.upvotePost(id: "p1", by: "u2")
        await waitUntil { vm.posts.first(where: { $0.id == "p1" })?.upvotes == 2 }

        XCTAssertEqual(mock.upvotedPostIds, ["p1", "p1"])
        XCTAssertTrue(tracker.hasUpvotedPost("p1", by: "u1"))
        XCTAssertTrue(tracker.hasUpvotedPost("p1", by: "u2"))
    }
}
