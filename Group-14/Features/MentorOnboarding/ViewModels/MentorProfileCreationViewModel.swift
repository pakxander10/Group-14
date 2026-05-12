//
//  MentorProfileCreationViewModel.swift
//  Group-14 — Features/MentorOnboarding/ViewModels
//
//  ⚠️ No SwiftUI import.
//

import Foundation
internal import Combine

// MARK: - MentorOnboardingServiceProtocol

protocol MentorOnboardingServiceProtocol {
    func createMentor(_ request: CreateMentorRequest) async throws -> MentorProfile
}

// MARK: - MentorOnboardingService

final class MentorOnboardingService: MentorOnboardingServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func createMentor(_ request: CreateMentorRequest) async throws -> MentorProfile {
        try await network.post("/mentors", body: request)
    }
}

// MARK: - MentorProfileCreationViewModel

@MainActor
final class MentorProfileCreationViewModel: ObservableObject {

    enum State: Equatable {
        case editing
        case submitting
        case created(MentorProfile)
        case failed(String)
    }

    // Form fields
    @Published var name: String = ""
    @Published var title: String = ""
    @Published var company: String = "Fidelity Investments"
    @Published var track: String = ""
    @Published var bio: String = ""
    @Published var yearsExperience: Int = 1
    @Published var email: String = ""
    @Published var linkedInUrl: String = ""
    @Published var educationHistoryInput: String = "" // one per line
    @Published var profilePicture: Data?

    // Searchable multi-select expertise
    @Published var selectedExpertise: [String] = []
    @Published var searchQuery: String = ""

    @Published private(set) var state: State = .editing

    /// Pool of selectable terms for the current track, minus already-selected
    /// terms, filtered by `searchQuery` (case-insensitive substring). The
    /// view caps the visible row count; this returns the full available list.
    var expertiseSuggestions: [String] {
        let pool = ExpertiseCatalog.terms(for: track)
        let selectedLowercased = Set(selectedExpertise.map { $0.lowercased() })
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let available = pool.filter { !selectedLowercased.contains($0.lowercased()) }
        return query.isEmpty
            ? available
            : available.filter { $0.lowercased().contains(query) }
    }

    var canSubmit: Bool {
        let trimmedName  = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio   = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
            && !trimmedTitle.isEmpty
            && !track.isEmpty
            && !trimmedBio.isEmpty
            && yearsExperience >= 0
            && !selectedExpertise.isEmpty
    }

    /// Adds a term to the selection only if it is part of the predetermined
    /// catalog and not already present. No-op otherwise.
    func addExpertise(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              ExpertiseCatalog.isKnown(trimmed),
              !selectedExpertise.contains(where: { $0.lowercased() == trimmed.lowercased() })
        else { return }
        selectedExpertise.append(trimmed)
        searchQuery = ""
    }

    /// Removes a term and clears the search query so the suggestion list
    /// shows the full pool again — matches the mental model of "I changed my
    /// mind, let me browse from scratch."
    func removeExpertise(_ term: String) {
        selectedExpertise.removeAll { $0.lowercased() == term.lowercased() }
        searchQuery = ""
    }

    private var educationList: [String] {
        educationHistoryInput
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let first = parts.compactMap { $0.first.map(String.init) }
        return first.joined().uppercased()
    }

    private let service: MentorOnboardingServiceProtocol

    init(service: MentorOnboardingServiceProtocol? = nil) {
        self.service = service ?? MentorOnboardingService()
    }

    func submit() {
        guard canSubmit else { return }
        state = .submitting

        let request = CreateMentorRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            track: track,
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
            expertise: selectedExpertise,
            yearsExperience: yearsExperience,
            avatarInitials: initials.isEmpty ? "??" : initials,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            linkedInUrl: linkedInUrl.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            educationHistory: educationList.isEmpty ? nil : educationList,
            profilePicture: profilePicture
        )

        Task {
            do {
                let created = try await service.createMentor(request)
                state = .created(created)
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func reset() {
        name = ""
        title = ""
        company = "Fidelity Investments"
        track = ""
        bio = ""
        selectedExpertise = []
        searchQuery = ""
        yearsExperience = 1
        email = ""
        linkedInUrl = ""
        educationHistoryInput = ""
        profilePicture = nil
        state = .editing
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
