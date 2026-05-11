//
//  MentorThreadViewModel.swift
//  Group-14 — Features/MentorThread/ViewModels
//
//  ⚠️ No SwiftUI import.
//

import Foundation
internal import Combine

// MARK: - MentorThreadServiceProtocol

protocol MentorThreadServiceProtocol {
    func fetchFeed() async throws -> [ThreadPost]
}

// MARK: - MentorThreadService

final class MentorThreadService: MentorThreadServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchFeed() async throws -> [ThreadPost] {
        try await network.get("/feed")
    }
}

// MARK: - MentorThreadViewModel

@MainActor
final class MentorThreadViewModel: ObservableObject {
    // MARK: State
    @Published private(set) var posts: [ThreadPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: MentorThreadServiceProtocol

    init(service: MentorThreadServiceProtocol? = nil) {
        self.service = service ?? MentorThreadService()
    }

    // MARK: Intents

    func loadFeed() {
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                posts = try await service.fetchFeed()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
