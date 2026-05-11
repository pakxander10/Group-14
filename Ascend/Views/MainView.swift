import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }

            ConfidenceDashboardView()
                .tabItem { Label("Confidence", systemImage: "chart.bar.fill") }

            QuestionnaireView()
                .tabItem { Label("Match", systemImage: "list.bullet.clipboard") }

            MentorThreadView()
                .tabItem { Label("Thread", systemImage: "bubble.left.and.bubble.right.fill") }
        }
        .tint(.indigo)
    }
}

#Preview { MainView() }
