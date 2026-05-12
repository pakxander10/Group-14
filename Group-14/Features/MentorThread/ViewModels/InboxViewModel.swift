//
//  InboxViewModel.swift
//  Group-14 — Features/MentorThread/ViewModels
//
//  Owns the learner's inbox of mentor-reply notifications.
//  ⚠️ Foundation only. No SwiftUI imports.
//

import Foundation
internal import Combine

@MainActor
final class InboxViewModel: ObservableObject {

    @Published private(set) var notifications: [InboxNotification] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: ThreadServiceProtocol

    init(service: ThreadServiceProtocol? = nil) {
        self.service = service ?? ThreadService()
    }

    func loadInbox(learnerId: String) {
        guard !learnerId.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                notifications = try await service.fetchInbox(learnerId: learnerId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
