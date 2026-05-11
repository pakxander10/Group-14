import SwiftUI

@main
struct InvestInMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .profile
    @State private var userRole: UserRole = .learner

    var body: some View {
        VStack(spacing: 0) {

            // Top title bar
            TitleBar(userRole: $userRole)

            // Screen content
            switch selectedTab {
            case .profile:  ProfileView()
            case .progress: ProgressView()
            case .match:    MatchView()
            case .qa:       QAView()
            }

            // Bottom tab bar
            TabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
