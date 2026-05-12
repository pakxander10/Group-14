//
//  MentorProfileView.swift
//  Group-14
//
//  Post-questionnaire mentor detail. Shown after the learner is matched
//  with a mentor via the questionnaire flow.
//

import SwiftUI
import PhotosUI

// MARK: - Main View

struct MentorProfileView: View {
    @State private var mentor: MentorProfile

    init(mentor: MentorProfile = MentorProfile(
        id: "1",
        name: "Sarah Chen",
        title: "Senior Software Engineer",
        company: "Fidelity",
        track: "Tech",
        bio: "Passionate about mentoring early-career engineers and helping them navigate the tech industry.",
        expertise: ["iOS", "Swift", "System Design"],
        yearsExperience: 12,
        avatarInitials: "SC",
        email: "sarah.chen@fidelity.com",
        linkedInUrl: "linkedin.com/in/sarahchen",
        educationHistory: ["BS Computer Science, UNC"],
        profilePicture: nil
    )) {
        self._mentor = State(initialValue: mentor)
    }

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var showingEdit = false

    var body: some View {
        ZStack {
            Color.investBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    avatarSection
                    nameSection
                    infoCard
                    if let education = mentor.educationHistory, !education.isEmpty {
                        educationCard(entries: education)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Mentor Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEdit = true
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.investPrimary)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            MentorEditView(mentor: $mentor)
        }
        .tint(Color.investPrimary)
    }

    // MARK: - Sections

    private var avatarSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack {
                Circle()
                    .fill(Color.investHeroBand)
                    .overlay(Circle().stroke(Color.investBorder, lineWidth: 1))
                    .frame(width: 112, height: 112)

                if let profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 112, height: 112)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.investBorder, lineWidth: 1))
                } else {
                    Text(mentor.avatarInitials)
                        .font(.title.bold())
                        .foregroundStyle(Color.investPrimary)
                }

                Circle()
                    .fill(Color.investPrimary)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.white)
                    )
                    .offset(x: 40, y: 40)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedPhoto) {
            Task {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                    mentor.profilePicture = data
                }
            }
        }
    }

    private var nameSection: some View {
        VStack(spacing: 4) {
            Text(mentor.name)
                .font(.title2.bold())
                .foregroundStyle(Color.investTitle)
            Text(mentor.title)
                .font(.subheadline)
                .foregroundStyle(Color.investTextSecondary)
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            infoRow(label: "Company", value: mentor.company)
            infoRow(label: "Experience", value: "\(mentor.yearsExperience) years")

            if let email = mentor.email, !email.isEmpty {
                infoRow(label: "Email", value: email)
            }

            if let linkedin = mentor.linkedInUrl, !linkedin.isEmpty {
                infoRow(label: "LinkedIn", value: linkedin)
            }

            infoRow(label: "Bio", value: mentor.bio)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }

    private func educationCard(entries: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EDUCATION")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.investAccent)
                .tracking(0.5)
            ForEach(entries, id: \.self) { entry in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.investPrimary)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                    Text(entry)
                        .font(.subheadline)
                        .foregroundStyle(Color.investTextPrimary)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }

    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.investAccent)
                .tracking(0.5)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color.investTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Edit View

struct MentorEditView: View {
    @Binding var mentor: MentorProfile
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var title = ""
    @State private var company = ""
    @State private var track = ""
    @State private var yearsExperience = ""
    @State private var email = ""
    @State private var linkedInUrl = ""
    @State private var bio = ""
    @State private var educationHistory = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.investBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        sectionCard(title: "Personal") {
                            VStack(spacing: 10) {
                                editField(label: "Name", text: $name)
                                editField(label: "Email", text: $email)
                                editField(label: "LinkedIn URL", text: $linkedInUrl)
                            }
                        }

                        sectionCard(title: "Professional") {
                            VStack(spacing: 10) {
                                editField(label: "Title", text: $title)
                                editField(label: "Company", text: $company)
                                editField(label: "Track", text: $track)
                                editField(label: "Years of Experience", text: $yearsExperience)
                            }
                        }

                        sectionCard(title: "Bio") {
                            TextEditor(text: $bio)
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

                        sectionCard(title: "Education (one per line)") {
                            TextEditor(text: $educationHistory)
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        mentor.name = name
                        mentor.title = title
                        mentor.company = company
                        mentor.track = track
                        mentor.yearsExperience = Int(yearsExperience) ?? mentor.yearsExperience
                        mentor.email = email.isEmpty ? nil : email
                        mentor.linkedInUrl = linkedInUrl.isEmpty ? nil : linkedInUrl
                        mentor.bio = bio
                        mentor.educationHistory = educationHistory
                            .split(separator: "\n")
                            .map { String($0).trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                name = mentor.name
                title = mentor.title
                company = mentor.company
                track = mentor.track
                yearsExperience = "\(mentor.yearsExperience)"
                email = mentor.email ?? ""
                linkedInUrl = mentor.linkedInUrl ?? ""
                bio = mentor.bio
                educationHistory = (mentor.educationHistory ?? []).joined(separator: "\n")
            }
        }
        .tint(Color.investPrimary)
    }

    private func editField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.investTextSecondary)
            TextField(label, text: text)
                .textFieldStyle(InvestTextFieldStyle())
        }
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
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MentorProfileView()
    }
}
