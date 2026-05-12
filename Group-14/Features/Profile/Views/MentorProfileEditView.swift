//
//  MentorProfileEditView.swift
//  Group-14 — Features/Profile/Views
//
//  Sheet form for editing a mentor's profile. Reuses the searchable
//  ExpertiseChipPickerSection from mentor onboarding so adds/removes match
//  the rest of the app.
//

import SwiftUI

struct MentorProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var expertiseSearchQuery: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.investBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.editingMentor != nil {
                            basicCard
                            trackCard
                            bioCard
                            expertiseCard
                            experienceCard
                            contactCard
                            educationCard
                        }

                        if let message = viewModel.errorMessage {
                            errorCard(message: message)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Edit Mentor Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelEdit()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveMentorEdit()
                    }
                    .bold()
                    .disabled(viewModel.isSaving)
                }
            }
            .onChange(of: viewModel.editingMentor == nil) { _, dismissed in
                if dismissed { dismiss() }
            }
        }
        .tint(Color.investPrimary)
    }

    // MARK: - Section cards

    private var basicCard: some View {
        sectionCard(title: "Basics") {
            VStack(spacing: 10) {
                TextField("Full Name", text: bindingForKeyPath(\.name))
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(InvestTextFieldStyle())
                TextField("Title", text: bindingForKeyPath(\.title))
                    .textFieldStyle(InvestTextFieldStyle())
                TextField("Company", text: bindingForKeyPath(\.company))
                    .textFieldStyle(InvestTextFieldStyle())
            }
        }
    }

    private var trackCard: some View {
        sectionCard(title: "Track") {
            Picker("Track", selection: bindingForKeyPath(\.track)) {
                ForEach(MentorTrack.allCases, id: \.rawValue) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var bioCard: some View {
        sectionCard(title: "Bio") {
            TextEditor(text: bindingForKeyPath(\.bio))
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.investBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.investBorder, lineWidth: 1)
                        )
                )
                .foregroundStyle(Color.investTextPrimary)
        }
    }

    private var expertiseCard: some View {
        sectionCard(title: "Areas of Expertise") {
            ExpertiseChipPickerSection(
                selected: viewModel.editingMentor?.expertise ?? [],
                suggestions: expertiseSuggestions,
                searchQuery: $expertiseSearchQuery,
                onAdd: addExpertise,
                onRemove: removeExpertise
            )
        }
    }

    private var experienceCard: some View {
        sectionCard(title: "Years of Experience") {
            Stepper(
                value: bindingForKeyPath(\.yearsExperience),
                in: 0...50
            ) {
                Text("\(viewModel.editingMentor?.yearsExperience ?? 0) years")
                    .foregroundStyle(Color.investTextPrimary)
            }
        }
    }

    private var contactCard: some View {
        sectionCard(title: "Contact (optional)") {
            VStack(spacing: 10) {
                TextField("Email", text: bindingForOptional(\.email))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(InvestTextFieldStyle())

                TextField("LinkedIn URL", text: bindingForOptional(\.linkedInUrl))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(InvestTextFieldStyle())
            }
        }
    }

    private var educationCard: some View {
        sectionCard(title: "Education (one per line, optional)") {
            TextEditor(text: bindingForEducation())
                .frame(minHeight: 80)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.investBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.investBorder, lineWidth: 1)
                        )
                )
                .foregroundStyle(Color.investTextPrimary)
        }
    }

    private func errorCard(message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.red)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.investSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.red.opacity(0.4), lineWidth: 1)
                    )
            )
    }

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.investAccent)
                .tracking(0.5)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }

    // MARK: - Expertise helpers

    private var expertiseSuggestions: [String] {
        guard let mentor = viewModel.editingMentor else { return [] }
        let pool = ExpertiseCatalog.terms(for: mentor.track)
        let selected = Set(mentor.expertise.map { $0.lowercased() })
        let query = expertiseSearchQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let available = pool.filter { !selected.contains($0.lowercased()) }
        return query.isEmpty
            ? available
            : available.filter { $0.lowercased().contains(query) }
    }

    private func addExpertise(_ term: String) {
        guard var mentor = viewModel.editingMentor,
              ExpertiseCatalog.isKnown(term),
              !mentor.expertise.contains(where: { $0.lowercased() == term.lowercased() })
        else { return }
        mentor.expertise.append(term)
        viewModel.editingMentor = mentor
        expertiseSearchQuery = ""
    }

    private func removeExpertise(_ term: String) {
        guard var mentor = viewModel.editingMentor else { return }
        mentor.expertise.removeAll { $0.lowercased() == term.lowercased() }
        viewModel.editingMentor = mentor
        expertiseSearchQuery = ""
    }

    // MARK: - Binding helpers

    private func bindingForKeyPath<Value>(
        _ keyPath: WritableKeyPath<MentorProfile, Value>
    ) -> Binding<Value> {
        Binding(
            get: { viewModel.editingMentor![keyPath: keyPath] },
            set: { viewModel.editingMentor?[keyPath: keyPath] = $0 }
        )
    }

    private func bindingForOptional(
        _ keyPath: WritableKeyPath<MentorProfile, String?>
    ) -> Binding<String> {
        Binding(
            get: { viewModel.editingMentor?[keyPath: keyPath] ?? "" },
            set: { viewModel.editingMentor?[keyPath: keyPath] = $0.isEmpty ? nil : $0 }
        )
    }

    private func bindingForEducation() -> Binding<String> {
        Binding(
            get: {
                viewModel.editingMentor?.educationHistory?.joined(separator: "\n") ?? ""
            },
            set: { newValue in
                let lines = newValue
                    .split(separator: "\n", omittingEmptySubsequences: false)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                viewModel.editingMentor?.educationHistory = lines.isEmpty ? nil : lines
            }
        )
    }
}
