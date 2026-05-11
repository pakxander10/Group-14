import SwiftUI

// Title Bar
struct TitleBar: View {
    @Binding var userRole: UserRole

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("InvestInMe")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                RolePill(label: "Learner", isActive: userRole == .learner) {
                    userRole = .learner
                }
                RolePill(label: "Mentor", isActive: userRole == .mentor) {
                    userRole = .mentor
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}

struct RolePill: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isActive ? .white : AppColors.textTertiary)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(isActive ? AppColors.primary : Color(hex: "#f5f5f5"))
                .cornerRadius(16)
        }
    }
}

// MTab Bar
struct TabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            TabBarItem(icon: "person", label: "Profile",   tab: .profile,   selectedTab: $selectedTab)
            TabBarItem(icon: "chart.line.uptrend.xyaxis", label: "Progress", tab: .progress, selectedTab: $selectedTab)
            TabBarItem(icon: "heart",  label: "Match",    tab: .match,    selectedTab: $selectedTab)
            TabBarItem(icon: "message", label: "Q&A",     tab: .qa,       selectedTab: $selectedTab)
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(Color.white)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(AppColors.divider), alignment: .top)
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let tab: AppTab
    @Binding var selectedTab: AppTab

    var isActive: Bool { selectedTab == tab }

    var body: some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundColor(isActive ? AppColors.primary : AppColors.textTertiary)
            .frame(maxWidth: .infinity)
        }
    }
}

// Reusable Card
struct AppCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .background(Color.white)
            .cornerRadius(14)
    }
}

// Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(AppColors.primary)
                .cornerRadius(12)
        }
    }
}
