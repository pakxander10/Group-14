//
//  MentorProfileCreationView.swift
//  Group-14 — Features/MentorOnboarding/Views
//

import SwiftUI
import PhotosUI

struct MentorProfileCreationView: View {
    @StateObject private var viewModel = MentorProfileCreationViewModel()
    @AppStorage("userId")   private var userId:   String = ""
    @AppStorage("userRole") private var userRole: String = ""

    @State private var pickerItem: PhotosPickerItem?
    @State private var photoPreview: Image?

    var body: some View {
        ZStack {
            Color.ascendBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    photoSection
                    nameField
                    titleField
                    companyField
                    trackPicker
                    yearsExperiencePicker
                    expertiseField
                    bioField
                    emailField
                    linkedInField
                    educationField

                    if case .failed(let message) = viewModel.state {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Become a Mentor")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: pickerItem) { loadPickedPhoto() }
        .onChange(of: viewModel.state) { _, newValue in
            if case .created(let mentor) = newValue {
                userId = mentor.id
                userRole = UserRole.mentor.storageValue
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 6) {
            Text("Share what you know")
                .font(.title2.bold())
                .foregroundColor(.ascendTextPrimary)
            Text("Build your mentor profile so learners can find you.")
                .font(.subheadline)
                .foregroundColor(.ascendTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var photoSection: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            ZStack {
                Circle().fill(Color.ascendSurface).frame(width: 110, height: 110)
                if let photoPreview {
                    photoPreview
                        .resizable().scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundColor(.ascendAccent)
                }
            }
        }
    }

    private var nameField: some View {
        labeled("Full Name") {
            TextField("Your full name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var titleField: some View {
        labeled("Job Title") {
            TextField("e.g. Senior Financial Advisor", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var companyField: some View {
        labeled("Company") {
            TextField("Company", text: $viewModel.company)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var trackPicker: some View {
        labeled("Track") {
            Picker("Track", selection: $viewModel.track) {
                Text("Select…").tag("")
                ForEach(MentorTrack.allCases, id: \.rawValue) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var yearsExperiencePicker: some View {
        labeled("Years of Experience: \(viewModel.yearsExperience)") {
            Stepper(
                "",
                value: $viewModel.yearsExperience,
                in: 0...50
            )
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var expertiseField: some View {
        labeled("Areas of Expertise") {
            ExpertiseChipPickerSection(
                selected: viewModel.selectedExpertise,
                suggestions: viewModel.expertiseSuggestions,
                searchQuery: $viewModel.searchQuery,
                onAdd: { viewModel.addExpertise($0) },
                onRemove: { viewModel.removeExpertise($0) }
            )
        }
    }

    private var bioField: some View {
        labeled("Bio") {
            TextEditor(text: $viewModel.bio)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.ascendSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.white)
        }
    }

    private var emailField: some View {
        labeled("Email (optional)") {
            TextField("name@fidelity.com", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
        }
    }

    private var linkedInField: some View {
        labeled("LinkedIn URL (optional)") {
            TextField("linkedin.com/in/…", text: $viewModel.linkedInUrl)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
        }
    }

    private var educationField: some View {
        labeled("Education (one per line, optional)") {
            TextEditor(text: $viewModel.educationHistoryInput)
                .frame(minHeight: 70)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.ascendSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.white)
        }
    }

    private var submitButton: some View {
        Button {
            viewModel.submit()
        } label: {
            HStack {
                if case .submitting = viewModel.state {
                    ProgressView().tint(.white)
                } else {
                    Text("Create Mentor Profile").font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(viewModel.canSubmit ? Color.ascendAccent : Color.ascendSurface)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.canSubmit || viewModel.state == .submitting)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func labeled<Content: View>(_ label: String,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.ascendTextSecondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func loadPickedPhoto() {
        guard let pickerItem else { return }
        Task {
            if let data = try? await pickerItem.loadTransferable(type: Data.self) {
                viewModel.profilePicture = data
                if let uiImage = UIImage(data: data) {
                    photoPreview = Image(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { MentorProfileCreationView() }
}
