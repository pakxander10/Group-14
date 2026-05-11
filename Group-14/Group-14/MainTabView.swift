//
//  MainTabView.swift
//  Group-14
//
//  Root 4-tab container. Shown after onboarding is complete.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1 — Profile
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }

            // Tab 2 — Confidence
            Text("Confidence")
                .tabItem {
                    Label("Confidence", systemImage: "chart.bar.fill")
                }

            // Tab 3 — Questionnaire / Match
            Text("Match")
                .tabItem {
                    Label("Match", systemImage: "sparkles")
                }

            // Tab 4 — Mentor Q Thread
            Text("Q Thread")
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
        .preferredColorScheme(.dark)
}
