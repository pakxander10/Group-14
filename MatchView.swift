import SwiftUI

struct MatchView: View {
    @State private var currentStep = 1
    let totalSteps = 7  // update as questions are added 
    @State private var answers = QuestionnairePayload(track: "", goal: "", style: "", year: "")

    var progress: Double { Double(currentStep) / Double(totalSteps) }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                // Progress bar
                AppCard {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Step \(currentStep) of \(totalSteps)")
                                .font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                        }
                        ProgressView(value: progress).tint(AppColors.primary)
                    }
                    .padding(14)
                }

                // Question card — swap content per step
                AppCard {
                    VStack(alignment: .leading, spacing: 12) {
                        switch currentStep {
                        case 1: QuestionTrack(selected: $answers.track)
                        case 2: QuestionGoal(selected: $answers.goal)
                        case 3: QuestionStyle(selected: $answers.style)
                        // TODO: Add more question views here for steps 4-7
                        default: QuestionPlaceholder(step: currentStep)
                        }

                        // Navigation
                        PrimaryButton(title: currentStep == totalSteps ? "Find my mentor" : "Next") {
                            if currentStep < totalSteps {
                                currentStep += 1
                            } else {
                                submitQuestionnaire()
                            }
                        }
                        if currentStep > 1 {
                            Button("Back") { currentStep -= 1 }
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(14)
                }

            }
            .padding(16)
        }
        .background(AppColors.bg)
    }

    func submitQuestionnaire() {
        // TODO: POST answers to Python backend /api/match
        // Your teammate wires this up
        print("Submitting:", answers)
    }
}

// MARK: - Question 1: Choose track
struct QuestionTrack: View {
    @Binding var selected: String

    let options = [
        ("💰", "Financial guidance",  "Budgeting, investing, and planning", "financial"),
        ("💼", "Career mentor",       "Navigate your path in finance",      "career"),
        ("🎓", "Academic support",    "Exams, courses, study strategies",   "academic"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose your track")
                .font(.system(size: 17, weight: .semibold))
            Text("What type of mentorship are you seeking?")
                .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
                .padding(.bottom, 4)

            ForEach(options, id: \.3) { emoji, title, sub, value in
                MatchOption(emoji: emoji, title: title, subtitle: sub, isSelected: selected == value) {
                    selected = value
                }
            }
        }
    }
}

// MARK: - Question 2: Goal
struct QuestionGoal: View {
    @Binding var selected: String

    let options = [
        ("🎯", "Get an internship",       "Land a finance role this year",       "internship"),
        ("📈", "Learn to invest",          "Understand markets and portfolios",   "investing"),
        ("💳", "Manage my money",          "Budget, save, and build credit",      "money"),
        ("🤝", "Build my network",         "Connect with finance professionals",  "network"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's your main goal?")
                .font(.system(size: 17, weight: .semibold))
            Text("Pick one.")
                .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
                .padding(.bottom, 4)

            ForEach(options, id: \.3) { emoji, title, sub, value in
                MatchOption(emoji: emoji, title: title, subtitle: sub, isSelected: selected == value) {
                    selected = value
                }
            }
        }
    }
}

// MARK: - Question 3: Style
struct QuestionStyle: View {
    @Binding var selected: String

    let options = [
        ("💬", "Chat on the app",         "Message back and forth",              "chat"),
        ("📹", "Video calls",              "Face to face sessions",               "video"),
        ("⏰", "Async replies",            "Reply on my own schedule",            "async"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How do you prefer to connect?")
                .font(.system(size: 17, weight: .semibold))
            Text("Pick one.")
                .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
                .padding(.bottom, 4)

            ForEach(options, id: \.3) { emoji, title, sub, value in
                MatchOption(emoji: emoji, title: title, subtitle: sub, isSelected: selected == value) {
                    selected = value
                }
            }
        }
    }
}

// MARK: - Placeholder for steps 4-7 (your team fills these in)
struct QuestionPlaceholder: View {
    let step: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Question \(step)")
                .font(.system(size: 17, weight: .semibold))
            Text("Add your question here.")
                .font(.system(size: 13)).foregroundColor(AppColors.textTertiary)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Reusable option row
struct MatchOption: View {
    let emoji: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 20))
                    .frame(width: 36, height: 36)
                    .background(isSelected ? AppColors.primaryLight : Color(hex: "#f5f5f5"))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 13, weight: .medium))
                        .foregroundColor(isSelected ? AppColors.primaryDark : .primary)
                    Text(subtitle).font(.system(size: 11))
                        .foregroundColor(AppColors.textTertiary)
                }
                Spacer()
                Circle()
                    .fill(isSelected ? AppColors.primary : Color.clear)
                    .overlay(Circle().stroke(isSelected ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 1))
                    .frame(width: 16, height: 16)
            }
            .padding(12)
            .background(isSelected ? AppColors.primaryLight : Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppColors.primaryBorder : Color.gray.opacity(0.15), lineWidth: 0.5))
        }
    }
}
