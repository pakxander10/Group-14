//
//  FinancialMatchView.swift
//  Group-14 — Features/MentorMatch/Views
//

import SwiftUI

struct FinancialMatchView: View {
    @StateObject private var vm = FinancialMatchViewModel()

    var body: some View {
        ZStack {
            Color.ascendBackground.ignoresSafeArea()

            if vm.isLoading {
                loadingScreen
            } else if vm.isComplete, let mentor = vm.matchedMentor {
                MatchResultView(mentor: mentor, onReset: vm.reset)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                VStack(spacing: 0) {
                    progressBar
                    stepContent
                    navigationButtons
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: vm.isComplete)
        .animation(.easeInOut(duration: 0.35), value: vm.isLoading)
        .navigationBarBackButtonHidden(vm.isComplete || vm.isLoading)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Financial Guidance")
                    .font(.title3.bold())
                    .foregroundColor(.ascendTextPrimary)
                Spacer()
                Text("\(vm.currentStep + 1) / \(vm.totalSteps)")
                    .font(.caption.bold())
                    .foregroundColor(.ascendTextSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.ascendSurface).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.trackFinancial, .ascendAccent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * Double(vm.currentStep + 1) / Double(vm.totalSteps), height: 6)
                        .animation(.spring(), value: vm.currentStep)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch vm.currentStep {
                case 0: situationStep
                case 1: financialGapStep
                case 2: accountsStep
                case 3: urgentPriorityStep
                case 4: firstGenStep
                case 5: mentorBackgroundStep
                case 6: experiencePreferenceStep
                case 7: communicationStyleStep
                case 8: confidenceStep
                default: EmptyView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Screen 1: Where You're Starting From

    private var situationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What best describes your current situation?", subtitle: "")
            ForEach(situationOptions) { option in
                optionCard(option: option, isSelected: vm.selectedSituation == option.value) {
                    vm.selectedSituation = option.value
                }
            }
        }
    }

    private let situationOptions: [MatchOption] = [
        .init(label: "I'm a college student with little to no income", value: "student_no_income", emoji: "🎒"),
        .init(label: "I'm working part-time while in school", value: "part_time_student", emoji: "⏰"),
        .init(label: "I just started my first full-time job", value: "first_full_time", emoji: "💼"),
        .init(label: "I recently graduated and I'm navigating finances alone", value: "recent_grad_solo", emoji: "🎓"),
        .init(label: "I'm working but feel behind on financial basics", value: "working_behind", emoji: "📉"),
    ]

    // MARK: - Screen 2: Biggest Financial Gap

    private var financialGapStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What do you understand the least right now?", subtitle: "")
            ForEach(financialGapOptions) { option in
                optionCard(option: option, isSelected: vm.selectedFinancialGap == option.value) {
                    vm.selectedFinancialGap = option.value
                }
            }
        }
    }

    private let financialGapOptions: [MatchOption] = [
        .init(label: "How taxes and paychecks actually work", value: "taxes_paychecks", emoji: "🧾"),
        .init(label: "How to build and stick to a budget", value: "budgeting", emoji: "🗂️"),
        .init(label: "How to start saving or investing with limited money", value: "saving_investing", emoji: "💰"),
        .init(label: "How student loans work and how to manage them", value: "student_loans", emoji: "📚"),
        .init(label: "What financial accounts I should have and why", value: "financial_accounts", emoji: "🏦"),
        .init(label: "How to negotiate a salary or evaluate a job offer", value: "salary_negotiation", emoji: "💬"),
    ]

    // MARK: - Screen 3: Accounts You Currently Hold

    private var accountsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "Which of these do you currently have?", subtitle: "Select all that apply.")
            ForEach(accountOptions) { option in
                multiSelectCard(option: option, isSelected: vm.selectedAccounts.contains(option.value)) {
                    vm.toggleAccount(option.value)
                }
            }
        }
    }

    private let accountOptions: [MatchOption] = [
        .init(label: "Checking account", value: "checking", emoji: "🏦"),
        .init(label: "Savings account", value: "savings", emoji: "🪙"),
        .init(label: "Credit card", value: "credit_card", emoji: "💳"),
        .init(label: "Student loans", value: "student_loans", emoji: "📚"),
        .init(label: "401k or workplace retirement plan", value: "401k", emoji: "📊"),
        .init(label: "Roth IRA or personal investment account", value: "roth_ira", emoji: "📈"),
        .init(label: "None of these yet", value: "none", emoji: "🔲"),
    ]

    // MARK: - Screen 4: Most Urgent Priority

    private var urgentPriorityStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What's the one financial thing keeping you up at night?", subtitle: "")
            ForEach(urgentPriorityOptions) { option in
                optionCard(option: option, isSelected: vm.selectedUrgentPriority == option.value) {
                    vm.selectedUrgentPriority = option.value
                }
            }
        }
    }

    private let urgentPriorityOptions: [MatchOption] = [
        .init(label: "Making rent or covering basic expenses", value: "rent", emoji: "🏠"),
        .init(label: "Understanding what's being taken out of my paycheck", value: "paycheck", emoji: "🧾"),
        .init(label: "Getting out of or managing debt", value: "debt", emoji: "📋"),
        .init(label: "Not knowing how or where to start investing", value: "investing", emoji: "📈"),
        .init(label: "Feeling completely behind compared to everyone else", value: "behind", emoji: "😟"),
        .init(label: "Not having anyone to ask who actually knows the answer", value: "no_guidance", emoji: "🧭"),
    ]

    // MARK: - Screen 5: First-Generation Status

    private var firstGenStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "Are you the first in your family navigating finances independently?", subtitle: "")
            ForEach(firstGenOptions) { option in
                optionCard(option: option, isSelected: vm.selectedFirstGen == option.value) {
                    vm.selectedFirstGen = option.value
                }
            }
        }
    }

    private let firstGenOptions: [MatchOption] = [
        .init(label: "Yes — no one in my family has guided me through this", value: "first_gen", emoji: "🌱"),
        .init(label: "Somewhat — I have some family context but limited guidance", value: "somewhat", emoji: "🤝"),
        .init(label: "No — I have family support but still want professional guidance", value: "no", emoji: "👨‍👩‍👧"),
    ]

    // MARK: - Screen 6: Preferred Mentor Background

    private var mentorBackgroundStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What kind of financial professional do you want to learn from?", subtitle: "")
            ForEach(mentorBackgroundOptions) { option in
                optionCard(option: option, isSelected: vm.selectedMentorBackground == option.value) {
                    vm.selectedMentorBackground = option.value
                }
            }
        }
    }

    private let mentorBackgroundOptions: [MatchOption] = [
        .init(label: "Someone who works in personal finance or financial planning", value: "personal_finance", emoji: "📋"),
        .init(label: "Someone who works in banking or wealth management", value: "banking_wealth", emoji: "🏦"),
        .init(label: "Someone who works in investment or asset management", value: "investment", emoji: "📈"),
        .init(label: "Someone in corporate finance or accounting", value: "corporate_finance", emoji: "🏢"),
        .init(label: "I don't know the difference — match me based on my answers", value: "auto_match", emoji: "✨"),
    ]

    // MARK: - Screen 7: Mentor Experience Preference

    private var experiencePreferenceStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "How much professional experience do you want your mentor to have?", subtitle: "")
            ForEach(experiencePreferenceOptions) { option in
                optionCard(option: option, isSelected: vm.selectedExperiencePreference == option.value) {
                    vm.selectedExperiencePreference = option.value
                }
            }
        }
    }

    private let experiencePreferenceOptions: [MatchOption] = [
        .init(label: "3 to 5 years — relatable, not too far ahead of me", value: "3_5_years", emoji: "🌱"),
        .init(label: "6 to 10 years — established but still approachable", value: "6_10_years", emoji: "📊"),
        .init(label: "10 or more years — I want the most experienced guidance possible", value: "10_plus_years", emoji: "🏆"),
        .init(label: "It doesn't matter — just match me to the right fit", value: "any", emoji: "🎯"),
    ]

    // MARK: - Screen 8: Communication Style

    private var communicationStyleStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "How do you prefer to receive guidance?", subtitle: "")
            ForEach(communicationStyleOptions) { option in
                optionCard(option: option, isSelected: vm.selectedCommunicationStyle == option.value) {
                    vm.selectedCommunicationStyle = option.value
                }
            }
        }
    }

    private let communicationStyleOptions: [MatchOption] = [
        .init(label: "Short, direct answers I can act on immediately", value: "direct", emoji: "⚡"),
        .init(label: "Detailed explanations that help me understand the full picture", value: "detailed", emoji: "📖"),
        .init(label: "Relatable stories from someone who's been in my position", value: "stories", emoji: "💬"),
        .init(label: "A mix depending on the question", value: "mix", emoji: "🔄"),
    ]

    // MARK: - Screen 9: Confidence Baseline

    private var confidenceStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "When it comes to your finances, where do you honestly feel you are?", subtitle: "")
            ForEach(confidenceOptions) { option in
                optionCard(option: option, isSelected: vm.selectedConfidence == Int(option.value) ?? -1) {
                    vm.selectedConfidence = Int(option.value) ?? 3
                }
            }
        }
    }

    private let confidenceOptions: [MatchOption] = [
        .init(label: "Lost — I don't know where to begin", value: "1", emoji: "😰"),
        .init(label: "Confused — I know a little but get stuck quickly", value: "2", emoji: "😕"),
        .init(label: "Getting there — I manage basics but want to do more", value: "3", emoji: "😐"),
        .init(label: "Fairly confident — I have a foundation and want to build on it", value: "4", emoji: "🙂"),
        .init(label: "Confident — I want advanced guidance, not basics", value: "5", emoji: "😊"),
    ]

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        VStack(spacing: 0) {
            Divider().background(Color.ascendSurface)
            HStack(spacing: 12) {
                if vm.currentStep > 0 {
                    Button {
                        withAnimation(.spring(response: 0.4)) { vm.previousStep() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .frame(width: 52, height: 52)
                            .background(Color.ascendSurface)
                            .foregroundColor(.ascendTextPrimary)
                            .clipShape(Circle())
                    }
                }

                let isLastStep = vm.currentStep == vm.totalSteps - 1
                Button {
                    if isLastStep {
                        vm.submit()
                    } else {
                        withAnimation(.spring(response: 0.4)) { vm.nextStep() }
                    }
                } label: {
                    Text(isLastStep ? "Find My Mentor ✨" : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(colors: [.trackFinancial, .ascendAccent], startPoint: .leading, endPoint: .trailing)
                                .opacity(vm.canAdvance ? 1 : 0.4)
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!vm.canAdvance)
            }
            .padding(20)
            .background(Color.ascendBackground)
        }
    }

    // MARK: - Loading Screen

    private var loadingScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            ProgressView()
                .scaleEffect(1.6)
                .tint(.ascendAccent)
            VStack(spacing: 8) {
                Text("You're in the right place.")
                    .font(.title2.bold())
                    .foregroundColor(.ascendTextPrimary)
                Text("Based on your answers, we're finding your best match from our network of verified Fidelity professionals. Every mentor here has navigated what you're navigating now.")
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
    }

    // MARK: - Shared Components

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title3.bold()).foregroundColor(.ascendTextPrimary)
            if !subtitle.isEmpty {
                Text(subtitle).font(.subheadline).foregroundColor(.ascendTextSecondary)
            }
        }
    }

    private func optionCard(option: MatchOption, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(option.emoji).font(.title2)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? Color.ascendAccent.opacity(0.2) : Color.ascendCard)
                    .clipShape(Circle())
                Text(option.label).font(.subheadline.bold())
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.ascendAccent)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.ascendSurface)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? Color.ascendAccent : Color.clear, lineWidth: 1.5))
            )
        }
    }

    private func multiSelectCard(option: MatchOption, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(option.emoji).font(.title2)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? Color.ascendAccent.opacity(0.2) : Color.ascendCard)
                    .clipShape(Circle())
                Text(option.label).font(.subheadline.bold())
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextSecondary)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.ascendSurface)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? Color.ascendAccent : Color.clear, lineWidth: 1.5))
            )
        }
    }
}

#Preview {
    NavigationStack {
        FinancialMatchView()
    }
    .preferredColorScheme(.dark)
}
