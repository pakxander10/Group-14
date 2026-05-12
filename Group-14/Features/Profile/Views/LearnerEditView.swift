//
//  LearnerEditView.swift
//  Group-14 — Features/Profile/Views
//
//  Sheet form for editing a learner's mutable fields. Bound to
//  `ProfileViewModel.editingLearner`; dismisses itself on save/cancel.
//

import SwiftUI

struct LearnerEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    /// Goal options match the existing mock learner goal vocabulary.
    private static let goalOptions: [(label: String, value: String)] = [
        ("Building Credit", "building_credit"),
        ("Buying a House", "buying_a_house"),
        ("Career Growth", "career"),
        ("Investing", "investing"),
        ("Retirement", "retirement"),
        ("Saving", "saving"),
        ("Student Loans", "student_loans")
    ]

    private static let interestOptions: [(label: String, value: String)] = [
        ("Financial Guidance", "financial"),
        ("Tech Career", "tech")
    ]

    var body: some View {
        NavigationStack {
            Form {
                if let draft = viewModel.editingLearner {
                    Section("Name") {
                        TextField("Full Name", text: bindingForName(initial: draft.name))
                            .textInputAutocapitalization(.words)
                    }

                    Section("Interest") {
                        Picker("Interest", selection: bindingForInterest(initial: draft.interest)) {
                            ForEach(Self.interestOptions, id: \.value) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Goal") {
                        Picker("Goal", selection: bindingForGoal(initial: draft.goal)) {
                            ForEach(Self.goalOptions, id: \.value) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                    }

                    Section("Major / Field of Study") {
                        TextField(
                            "e.g. Computer Science",
                            text: bindingForMajor(initial: draft.occupationMajor ?? "")
                        )
                        .textInputAutocapitalization(.words)
                    }
                }

                if let message = viewModel.errorMessage {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
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
                        viewModel.saveLearnerEdit()
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .onChange(of: viewModel.editingLearner == nil) { _, dismissed in
                // ProfileViewModel sets editingLearner = nil on successful save.
                if dismissed { dismiss() }
            }
        }
    }

    // MARK: - Bindings

    private func bindingForName(initial: String) -> Binding<String> {
        Binding(
            get: { viewModel.editingLearner?.name ?? initial },
            set: { viewModel.editingLearner?.name = $0 }
        )
    }

    private func bindingForInterest(initial: String) -> Binding<String> {
        Binding(
            get: { viewModel.editingLearner?.interest ?? initial },
            set: { viewModel.editingLearner?.interest = $0 }
        )
    }

    private func bindingForGoal(initial: String) -> Binding<String> {
        Binding(
            get: { viewModel.editingLearner?.goal ?? initial },
            set: { viewModel.editingLearner?.goal = $0 }
        )
    }

    private func bindingForMajor(initial: String) -> Binding<String> {
        Binding(
            get: { viewModel.editingLearner?.occupationMajor ?? initial },
            set: { viewModel.editingLearner?.occupationMajor = $0.isEmpty ? nil : $0 }
        )
    }
}
