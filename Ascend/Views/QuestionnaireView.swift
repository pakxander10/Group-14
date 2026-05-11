import SwiftUI

struct QuestionnaireView: View {
    @StateObject private var vm = QuestionnaireViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("About you") {
                    Toggle("First-generation student", isOn: $vm.isFirstGen)
                    Picker("Interest track", selection: $vm.interestTrack) {
                        Text("Financial").tag("Financial")
                        Text("Tech").tag("Tech")
                    }
                    .pickerStyle(.segmented)
                    Stepper(
                        "Preferred mentor experience: \(vm.preferredExperienceYears) yrs",
                        value: $vm.preferredExperienceYears, in: 1...30
                    )
                }
                Section("Goals (comma-separated)") {
                    TextField("Financial goals", text: $vm.financialGoals)
                    TextField("Career goals", text: $vm.careerGoals)
                }
                Section {
                    Button {
                        Task { await vm.submit() }
                    } label: {
                        if vm.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Find my mentor").bold()
                        }
                    }
                    .disabled(vm.isSubmitting)
                }
                if let mentor = vm.matchedMentor {
                    Section("Your match") {
                        MentorCard(mentor: mentor)
                    }
                }
                if let err = vm.errorMessage {
                    Section { Text(err).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Match Me")
        }
    }
}

private struct MentorCard: View {
    let mentor: MentorProfile
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(mentor.name).font(.title3).bold()
            Text("\(mentor.title) · \(mentor.company)")
                .font(.subheadline).foregroundStyle(.secondary)
            Text("Track: \(mentor.track) · \(mentor.yearsExperience) yrs")
                .font(.caption)
            Text(mentor.bio).font(.body).padding(.top, 4)
            if !mentor.specialties.isEmpty {
                Text("Specialties: " + mentor.specialties.joined(separator: ", "))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview { QuestionnaireView() }
