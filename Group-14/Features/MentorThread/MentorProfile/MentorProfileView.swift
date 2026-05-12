//
//  MentorProfileView.swift
//  Group-14
//
//  Created by Medha Kuchimanchi on 5/11/26.
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
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Photo Picker
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.2))
                                .frame(width: 100, height: 100)

                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) {
                        Task {
                            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                profileImage = Image(uiImage: uiImage)
                                mentor.profilePicture = data
                            }
                        }
                    }

                    // MARK: Name
                    Text(mentor.name)
                        .font(.title2).bold()
                        .foregroundStyle(.white)

                    Divider()
                        .overlay(Color.white.opacity(0.2))

                    // MARK: Info Rows
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(label: "Title", value: mentor.title)
                        InfoRow(label: "Company", value: mentor.company)
                        InfoRow(label: "Experience", value: "\(mentor.yearsExperience) years")

                        if let email = mentor.email, !email.isEmpty {
                            InfoRow(label: "Email", value: email)
                        }

                        if let linkedin = mentor.linkedInUrl, !linkedin.isEmpty {
                            InfoRow(label: "LinkedIn", value: linkedin)
                        }

                        InfoRow(label: "Bio", value: mentor.bio)

                        if let education = mentor.educationHistory, !education.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Education")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                ForEach(education, id: \.self) { entry in
                                    Text("• \(entry)")
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 40)
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
                        .foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            MentorEditView(mentor: $mentor)
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
            Text(value)
                .foregroundStyle(.white)
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
                Color.black.ignoresSafeArea()

                Form {
                    Section("Personal") {
                        EditField(label: "Name", text: $name)
                        EditField(label: "Email", text: $email)
                        EditField(label: "LinkedIn URL", text: $linkedInUrl)
                    }

                    Section("Professional") {
                        EditField(label: "Title", text: $title)
                        EditField(label: "Company", text: $company)
                        EditField(label: "Track", text: $track)
                        EditField(label: "Years of Experience", text: $yearsExperience)
                    }

                    Section("Bio") {
                        TextEditor(text: $bio)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(.white)
                    }

                    Section("Education (one per line)") {
                        TextEditor(text: $educationHistory)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(.white)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.blue)
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
                    .foregroundStyle(.blue)
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
    }
}

// MARK: - Edit Field

private struct EditField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
            TextField(label, text: $text)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MentorProfileView()
    }
    .preferredColorScheme(.dark)
}
