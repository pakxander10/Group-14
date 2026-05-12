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
            ZStack {
                Color.investBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if let draft = viewModel.editingLearner {
                            nameCard(initial: draft.name)
                            interestCard(initial: draft.interest)
                            goalCard(initial: draft.goal)
                            majorCard(initial: draft.occupationMajor ?? "")
                        }

                        if let message = viewModel.errorMessage {
                            errorCard(message: message)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
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
                    .bold()
                    .disabled(viewModel.isSaving)
                }
            }
            .onChange(of: viewModel.editingLearner == nil) { _, dismissed in
                // ProfileViewModel sets editingLearner = nil on successful save.
                if dismissed { dismiss() }
            }
        }
        .tint(Color.investPrimary)
    }

    // MARK: - Section cards

    private func nameCard(initial: String) -> some View {
        sectionCard(title: "Name") {
            TextField("Full Name", text: bindingForName(initial: initial))
                .textInputAutocapitalization(.words)
                .textFieldStyle(InvestTextFieldStyle())
        }
    }

    private func interestCard(initial: String) -> some View {
        sectionCard(title: "Interest") {
            Picker("Interest", selection: bindingForInterest(initial: initial)) {
                ForEach(Self.interestOptions, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func goalCard(initial: String) -> some View {
        sectionCard(title: "Goal") {
            Picker("Goal", selection: bindingForGoal(initial: initial)) {
                ForEach(Self.goalOptions, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.investPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func majorCard(initial: String) -> some View {
        sectionCard(title: "Major / Field of Study") {
            TextField(
                "e.g. Computer Science",
                text: bindingForMajor(initial: initial)
            )
            .textInputAutocapitalization(.words)
            .textFieldStyle(InvestTextFieldStyle())
        }
    }

    private func errorCard(message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundColor(.red)
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

// MARK: - Shared text-field style

struct InvestTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
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
