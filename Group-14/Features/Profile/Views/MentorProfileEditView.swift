//
//  MentorEditView.swift
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
            Form {
                if viewModel.editingMentor != nil {
                    basicSection
                    trackSection
                    bioSection
                    expertiseSection
                    experienceSection
                    contactSection
                    educationSection
                }

                if let message = viewModel.errorMessage {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
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
                    .disabled(viewModel.isSaving)
                }
            }
            .onChange(of: viewModel.editingMentor == nil) { _, dismissed in
                if dismissed { dismiss() }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Sections

    private var basicSection: some View {
        Section("Basics") {
            TextField("Full Name", text: bindingForKeyPath(\.name))
                .textInputAutocapitalization(.words)
            TextField("Title", text: bindingForKeyPath(\.title))
            TextField("Company", text: bindingForKeyPath(\.company))
        }
    }

    private var trackSection: some View {
        Section("Track") {
            Picker("Track", selection: bindingForKeyPath(\.track)) {
                ForEach(MentorTrack.allCases, id: \.rawValue) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var bioSection: some View {
        Section("Bio") {
            TextEditor(text: bindingForKeyPath(\.bio))
                .frame(minHeight: 100)
        }
    }

    private var expertiseSection: some View {
        Section("Areas of Expertise") {
            ExpertiseChipPickerSection(
                selected: viewModel.editingMentor?.expertise ?? [],
                suggestions: expertiseSuggestions,
                searchQuery: $expertiseSearchQuery,
                onAdd: addExpertise,
                onRemove: removeExpertise
            )
            .padding(.vertical, 4)
        }
    }

    private var experienceSection: some View {
        Section("Years of Experience") {
            Stepper(
                value: bindingForKeyPath(\.yearsExperience),
                in: 0...50
            ) {
                Text("\(viewModel.editingMentor?.yearsExperience ?? 0) years")
            }
        }
    }

    private var contactSection: some View {
        Section("Contact (optional)") {
            TextField(
                "Email",
                text: bindingForOptional(\.email)
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            TextField(
                "LinkedIn URL",
                text: bindingForOptional(\.linkedInUrl)
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
    }

    private var educationSection: some View {
        Section("Education (one per line, optional)") {
            TextEditor(text: bindingForEducation())
                .frame(minHeight: 70)
        }
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
