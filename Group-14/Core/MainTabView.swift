//
//  MainTabView.swift
//  Group-14
//
//  Root 4-tab container for the Ascend app.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }

            ConfidenceDashboardView()
                .tabItem {
                    Label("Confidence", systemImage: "chart.bar.fill")
                }

            QuestionnaireView()
                .tabItem {
                    Label("Match", systemImage: "sparkles")
                }

            MentorThreadView()
                .tabItem {
                    Label("Q Thread", systemImage: "bubble.left.and.bubble.right.fill")
                }
        }
        .tint(.ascendAccent)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
