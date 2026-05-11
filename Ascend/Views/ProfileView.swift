import SwiftUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let p = vm.profile {
                    List {
                        Section("Account") {
                            LabeledContent("Name", value: p.name)
                            LabeledContent("Email", value: p.email)
                            LabeledContent("Role", value: "Learner")
                            LabeledContent("Track", value: p.track ?? "—")
                            LabeledContent("First-gen", value: p.isFirstGen ? "Yes" : "No")
                        }
                        Section("Stats") {
                            LabeledContent("Confidence", value: "\(p.confidenceScore) / 1000")
                            LabeledContent("Interests", value: p.interests.joined(separator: ", "))
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No profile",
                        systemImage: "person.crop.circle.badge.exclamationmark",
                        description: Text(vm.errorMessage ?? "Pull to retry")
                    )
                }
            }
            .navigationTitle("Profile")
            .task { await vm.load() }
            .refreshable { await vm.load() }
        }
    }
}

#Preview { ProfileView() }
