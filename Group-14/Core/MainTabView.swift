//
//  MainTabView.swift
//  Group-14
//
//  Root tab container. Tab set is role-aware:
//    learner → Profile, Confidence, Match, Q Thread, Inbox
//    mentor  → Profile, Q Thread
//

import SwiftUI

struct MainTabView: View {
    @AppStorage("userRole") private var userRole: String = ""

    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }

            if userRole == UserRole.learner.storageValue {
                ConfidenceDashboardView()
                    .tabItem {
                        Label("Confidence", systemImage: "chart.bar.fill")
                    }

                MentorMatchView()
                    .tabItem {
                        Label("Match", systemImage: "sparkles")
                    }
            }

            ThreadFeedView()
                .tabItem {
                    Label("Q Thread", systemImage: "bubble.left.and.bubble.right.fill")
                }

            if userRole == UserRole.learner.storageValue {
                InboxView()
                    .tabItem {
                        Label("Inbox", systemImage: "tray.fill")
                    }
            }
        }
        .tint(.investPrimary)
    }
}

#Preview {
    MainTabView()
}
