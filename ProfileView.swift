import SwiftUI

struct ProfileView: View {
    let user = UserProfile()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Profile card
                AppCard {
                    HStack(spacing: 12) {
                        // Avatar
                        Text(initials(from: user.name))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryDark)
                            .frame(width: 52, height: 52)
                            .background(Color(hex: "#F4C0D1"))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.system(size: 16, weight: .semibold))
                            HStack(spacing: 4) {
                                Image(systemName: "person")
                                    .font(.system(size: 10))
                                Text("Learner")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppColors.primaryLight)
                            .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(14)
                }

                // Confidence score card
                ConfidenceScoreCard(score: user.confidenceScore, max: user.maxScore)

                // Info rows
                AppCard {
                    VStack(spacing: 0) {
                        InfoRow(icon: "building.columns", iconBg: AppColors.primaryLight, iconColor: AppColors.primary, label: "Type of school", value: user.schoolType)
                        Divider().padding(.leading, 48)
                        InfoRow(icon: "calendar", iconBg: AppColors.successLight, iconColor: AppColors.success, label: "Graduation year", value: "\(user.graduationYear)")
                        Divider().padding(.leading, 48)
                        InfoRow(icon: "person", iconBg: AppColors.purpleLight, iconColor: AppColors.purple, label: "Gender", value: user.gender)
                    }
                }

            }
            .padding(16)
        }
        .background(AppColors.bg)
    }

    func initials(from name: String) -> String {
        name.components(separatedBy: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
    }
}

struct InfoRow: View {
    let icon: String
    let iconBg: Color
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconBg)
                .cornerRadius(7)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.system(size: 11)).foregroundColor(AppColors.textTertiary)
                Text(value).font(.system(size: 13, weight: .medium))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

struct ConfidenceScoreCard: View {
    let score: Int
    let max: Int
    var progress: Double { Double(score) / Double(max) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confidence Score")
                .font(.system(size: 12)).foregroundColor(.white.opacity(0.85))
            Text("\(score)")
                .font(.system(size: 36, weight: .bold)).foregroundColor(.white)
            Text("out of \(max)")
                .font(.system(size: 11)).foregroundColor(.white.opacity(0.75))

            ProgressView(value: progress)
                .tint(.white)
                .background(Color.white.opacity(0.25))
                .cornerRadius(3)

            VStack(alignment: .leading, spacing: 2) {
                Text("Building Foundation")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                Text("Keep engaging with mentors to grow")
                    .font(.system(size: 11)).foregroundColor(.white.opacity(0.8))
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [AppColors.primary, AppColors.primaryDark],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(14)
    }
}
