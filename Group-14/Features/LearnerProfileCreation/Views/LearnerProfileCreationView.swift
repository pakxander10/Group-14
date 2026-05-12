//
//  LearnerProfileCreationView.swift
//  Group-14 — Features/LearnerProfileCreation/Views
//
//  Single-form onboarding screen. Observes LearnerProfileCreationViewModel.
//  Zero business logic — all decisions live in the ViewModel.
//

import SwiftUI
import PhotosUI

struct LearnerProfileCreationView: View {

    @StateObject private var viewModel = LearnerProfileCreationViewModel()
    @AppStorage("userId")   private var userId:   String = ""
    @AppStorage("userRole") private var userRole: String = ""

    @State private var pickerItem: PhotosPickerItem?
    @State private var photoPreview: Image?

    private let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        ZStack {
            Color.ascendBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    photoSection
                    nameField
                    schoolPicker
                    graduationYearPicker
                    genderPicker
                    occupationField
                    confidenceSlider

                    if case .failed(let message) = viewModel.state {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: pickerItem) {
            loadPickedPhoto()
        }
        .onChange(of: viewModel.state) { _, newValue in
            if case .created(let learner) = newValue {
                userId = learner.id
                userRole = UserRole.learner.storageValue
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 6) {
            Text("Welcome to Ascend")
                .font(.title.bold())
                .foregroundStyle(Color.ascendTextPrimary)
            Text("Tell us a little about yourself so we can match you with the right mentor.")
                .font(.subheadline)
                .foregroundStyle(Color.ascendTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var photoSection: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            ZStack {
                Circle()
                    .fill(Color.ascendSurface)
                    .frame(width: 110, height: 110)

                if let photoPreview {
                    photoPreview
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundStyle(Color.ascendAccent)
                }
            }
        }
    }

    private var nameField: some View {
        labeled("Name") {
            TextField("Your name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var schoolPicker: some View {
        labeled("Type of School") {
            Picker("Type of School", selection: $viewModel.typeOfSchool) {
                Text("Select…").tag("")
                ForEach(SchoolType.allCases, id: \.rawValue) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .tint(.ascendAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.ascendSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var graduationYearPicker: some View {
        labeled("Graduation Year") {
            Picker("Graduation Year", selection: $viewModel.graduationYear) {
                ForEach(currentYear...(currentYear + 10), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .tint(.ascendAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.ascendSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var genderPicker: some View {
        labeled("Gender") {
            Picker("Gender", selection: $viewModel.gender) {
                Text("Select…").tag("")
                ForEach(Gender.allCases, id: \.rawValue) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .tint(.ascendAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.ascendSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var occupationField: some View {
        labeled("Occupation / Major") {
            TextField("e.g. Computer Science", text: $viewModel.occupationMajor)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var confidenceSlider: some View {
        labeled("Current Confidence Score: \(viewModel.currentConfidenceScore)") {
            Slider(
                value: Binding(
                    get: { Double(viewModel.currentConfidenceScore) },
                    set: { viewModel.currentConfidenceScore = Int($0) }
                ),
                in: 1...1000,
                step: 50
            )
            .tint(.ascendAccent)
        }
    }

    private var submitButton: some View {
        Button {
            viewModel.submit()
        } label: {
            HStack {
                if case .submitting = viewModel.state {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Create Profile")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(viewModel.canSubmit ? Color.ascendAccent : Color.ascendSurface)
            .foregroundStyle(.white)
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
                .foregroundStyle(Color.ascendTextSecondary)
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

// MARK: - Preview

#Preview {
    LearnerProfileCreationView()
        .preferredColorScheme(.dark)
}
