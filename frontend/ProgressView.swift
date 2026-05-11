import SwiftUI

struct ProgressView: View {
    let score = 425
    let maxScore = 1000

    var progress: Double { Double(score) / Double(maxScore) }

    let tiers = [
        (points: 0,   name: "Getting started",    sub: "Begin your journey",     isCurrent: false),
        (points: 250, name: "Building foundation", sub: "Learning the basics",    isCurrent: true),
        (points: 500, name: "Growing confident",   sub: "Applying knowledge",     isCurrent: false),
        (points: 750, name: "Thriving",            sub: "Leading with purpose",   isCurrent: false),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Score card
                AppCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your confidence score")
                            .font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                        Text("\(score)")
                            .font(.system(size: 32, weight: .bold)).foregroundColor(AppColors.primary)
                        Text("out of \(maxScore)")
                            .font(.system(size: 12)).foregroundColor(AppColors.textTertiary)

                        HStack {
                            Text("Progress").font(.system(size: 11)).foregroundColor(AppColors.textTertiary)
                            Spacer()
                            Text("\(Int(progress * 100))%").font(.system(size: 11)).foregroundColor(AppColors.textTertiary)
                        }
                        ProgressView(value: progress).tint(AppColors.primary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Building Foundation")
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(AppColors.primaryDark)
                            Text("Keep engaging with mentors to unlock higher tiers")
                                .font(.system(size: 11)).foregroundColor(AppColors.primaryMid)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.primaryLight)
                        .cornerRadius(10)
                    }
                    .padding(14)
                }

                // Confidence tiers
                AppCard {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Confidence tiers")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        ForEach(tiers, id: \.name) { tier in
                            TierRow(points: tier.points, name: tier.name, sub: tier.sub, isCurrent: tier.isCurrent)
                            if tier.name != tiers.last?.name {
                                Divider().padding(.leading, 52)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }

            }
            .padding(16)
        }
        .background(AppColors.bg)
    }
}

struct TierRow: View {
    let points: Int
    let name: String
    let sub: String
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("\(points)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isCurrent ? .white : AppColors.textTertiary)
                .frame(width: 32, height: 32)
                .background(isCurrent ? AppColors.primary : Color(hex: "#f5f5f5"))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 13, weight: .medium))
                Text(sub).font(.system(size: 11)).foregroundColor(AppColors.textTertiary)
            }
            Spacer()
            if isCurrent {
                Text("Current")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(AppColors.primaryLight)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
