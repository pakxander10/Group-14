//
//  CareerMatchView.swift
//  Group-14 — Features/MentorMatch/Views
//

import SwiftUI

struct CareerMatchView: View {
    @StateObject private var vm = CareerMatchViewModel()

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
                Text("Career Mentorship")
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
                        .fill(LinearGradient(colors: [.trackTech, .ascendAccent], startPoint: .leading, endPoint: .trailing))
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
                case 0: careerStageStep
                case 1: targetIndustryStep
                case 2: roleClarityStep
                case 3: neededSupportStep
                case 4: educationBackgroundStep
                case 5: firstGenStep
                case 6: companyTypeStep
                case 7: mentorCareerPathStep
                case 8: confidenceStep
                default: EmptyView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Screen 1: Where You Are in Your Career

    private var careerStageStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "Which best describes where you are right now?", subtitle: "")
            ForEach(careerStageOptions) { option in
                optionCard(option: option, isSelected: vm.selectedCareerStage == option.value) {
                    vm.selectedCareerStage = option.value
                }
            }
        }
    }

    private let careerStageOptions: [MatchOption] = [
        .init(label: "I'm in school with no work experience yet", value: "student_no_exp", emoji: "🎒"),
        .init(label: "I'm in school and actively looking for internships", value: "seeking_internship", emoji: "🔍"),
        .init(label: "I have an internship or part-time role in my field", value: "has_internship", emoji: "💼"),
        .init(label: "I just received my first full-time offer", value: "first_offer", emoji: "📩"),
        .init(label: "I'm in my first role and trying to grow", value: "first_role_growing", emoji: "🌱"),
        .init(label: "I'm looking to switch into finance or tech", value: "career_switch", emoji: "🔄"),
    ]

    // MARK: - Screen 2: Target Industry

    private var targetIndustryStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "Which industry are you trying to break into or grow within?", subtitle: "")
            ForEach(targetIndustryOptions) { option in
                optionCard(option: option, isSelected: vm.selectedTargetIndustry == option.value) {
                    vm.selectedTargetIndustry = option.value
                }
            }
        }
    }

    private let targetIndustryOptions: [MatchOption] = [
        .init(label: "Investment banking or capital markets", value: "investment_banking", emoji: "🏦"),
        .init(label: "Financial planning or wealth management", value: "wealth_management", emoji: "📊"),
        .init(label: "Fintech or financial technology", value: "fintech", emoji: "💡"),
        .init(label: "Software engineering or product at a tech company", value: "software_eng", emoji: "💻"),
        .init(label: "Data science or analytics", value: "data_science", emoji: "📈"),
        .init(label: "Corporate finance or accounting", value: "corporate_finance", emoji: "🏢"),
        .init(label: "I'm still exploring — show me options", value: "exploring", emoji: "🧭"),
    ]

    // MARK: - Screen 3: Role Clarity

    private var roleClarityStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "How clear are you on what role you actually want?", subtitle: "")
            ForEach(roleClarityOptions) { option in
                optionCard(option: option, isSelected: vm.selectedRoleClarity == option.value) {
                    vm.selectedRoleClarity = option.value
                }
            }
        }
    }

    private let roleClarityOptions: [MatchOption] = [
        .init(label: "I know exactly what I want and I'm pursuing it", value: "very_clear", emoji: "🎯"),
        .init(label: "I have a general direction but I'm unsure of the specific role", value: "general_direction", emoji: "🗺️"),
        .init(label: "I know the industry but have no idea what roles exist", value: "industry_only", emoji: "🔭"),
        .init(label: "I have no idea where to start", value: "no_idea", emoji: "😶"),
    ]

    // MARK: - Screen 4: Most Needed Support

    private var neededSupportStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What kind of career support do you need most right now?", subtitle: "")
            ForEach(neededSupportOptions) { option in
                optionCard(option: option, isSelected: vm.selectedNeededSupport == option.value) {
                    vm.selectedNeededSupport = option.value
                }
            }
        }
    }

    private let neededSupportOptions: [MatchOption] = [
        .init(label: "Understanding what different roles pay and require", value: "roles_pay", emoji: "💰"),
        .init(label: "Building or improving my resume for finance or tech", value: "resume", emoji: "📄"),
        .init(label: "Preparing for interviews or technical assessments", value: "interviews", emoji: "🎤"),
        .init(label: "Navigating my first 90 days in a new role", value: "first_90_days", emoji: "📅"),
        .init(label: "Growing within my current company", value: "internal_growth", emoji: "📈"),
        .init(label: "Finding a mentor for long-term career development", value: "long_term", emoji: "🤝"),
    ]

    // MARK: - Screen 5: Education Background

    private var educationBackgroundStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What is your current or most recent level of education?", subtitle: "")
            ForEach(educationBackgroundOptions) { option in
                optionCard(option: option, isSelected: vm.selectedEducationBackground == option.value) {
                    vm.selectedEducationBackground = option.value
                }
            }
        }
    }

    private let educationBackgroundOptions: [MatchOption] = [
        .init(label: "Currently pursuing a bachelor's degree", value: "pursuing_bachelors", emoji: "📚"),
        .init(label: "Bachelor's degree completed", value: "bachelors_done", emoji: "🎓"),
        .init(label: "Currently pursuing a master's or MBA", value: "pursuing_masters", emoji: "📖"),
        .init(label: "Master's or MBA completed", value: "masters_done", emoji: "🏅"),
        .init(label: "Trade or vocational certification", value: "trade_cert", emoji: "🔧"),
        .init(label: "No degree — self-taught or bootcamp background", value: "self_taught", emoji: "💡"),
    ]

    // MARK: - Screen 6: First-Generation Status

    private var firstGenStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "Are you the first in your family entering this industry?", subtitle: "")
            ForEach(firstGenOptions) { option in
                optionCard(option: option, isSelected: vm.selectedFirstGen == option.value) {
                    vm.selectedFirstGen = option.value
                }
            }
        }
    }

    private let firstGenOptions: [MatchOption] = [
        .init(label: "Yes — no one in my family works in finance or tech", value: "first_gen", emoji: "🌱"),
        .init(label: "Somewhat — I have distant family context but no direct guidance", value: "somewhat", emoji: "🤝"),
        .init(label: "No — I have family in the field but want outside perspective", value: "no", emoji: "👨‍👩‍👧"),
    ]

    // MARK: - Screen 7: Company Type Preference

    private var companyTypeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What type of company do you see yourself at?", subtitle: "")
            ForEach(companyTypeOptions) { option in
                optionCard(option: option, isSelected: vm.selectedCompanyType == option.value) {
                    vm.selectedCompanyType = option.value
                }
            }
        }
    }

    private let companyTypeOptions: [MatchOption] = [
        .init(label: "Large financial institution or bank", value: "large_bank", emoji: "🏦"),
        .init(label: "Fintech startup or scale-up", value: "fintech_startup", emoji: "🚀"),
        .init(label: "Big tech company", value: "big_tech", emoji: "💻"),
        .init(label: "Consulting or advisory firm", value: "consulting", emoji: "🤝"),
        .init(label: "I'm open — I want to understand my options first", value: "open", emoji: "🧭"),
    ]

    // MARK: - Screen 8: Mentor Career Path Preference

    private var mentorCareerPathStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What kind of career story do you want your mentor to have?", subtitle: "")
            ForEach(mentorCareerPathOptions) { option in
                optionCard(option: option, isSelected: vm.selectedMentorCareerPath == option.value) {
                    vm.selectedMentorCareerPath = option.value
                }
            }
        }
    }

    private let mentorCareerPathOptions: [MatchOption] = [
        .init(label: "Someone who took a traditional path — top school, direct entry", value: "traditional", emoji: "🎓"),
        .init(label: "Someone who took a non-traditional path — community college, career switch, self-taught", value: "non_traditional", emoji: "🔄"),
        .init(label: "Someone who looks like me and has navigated being underrepresented in their field", value: "underrepresented", emoji: "💪"),
        .init(label: "Someone who has hired people like me and knows what companies want", value: "hiring_experience", emoji: "🔍"),
        .init(label: "Any path — just match me based on my goals", value: "any", emoji: "✨"),
    ]

    // MARK: - Screen 9: Confidence Baseline

    private var confidenceStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "When it comes to your career path, where do you honestly feel you are?", subtitle: "")
            ForEach(confidenceOptions) { option in
                optionCard(option: option, isSelected: vm.selectedConfidence == Int(option.value) ?? -1) {
                    vm.selectedConfidence = Int(option.value) ?? 3
                }
            }
        }
    }

    private let confidenceOptions: [MatchOption] = [
        .init(label: "Lost — I have no idea what I'm doing or where to start", value: "1", emoji: "😰"),
        .init(label: "Confused — I have a direction but no clear next step", value: "2", emoji: "😕"),
        .init(label: "Getting there — I'm making moves but second-guessing myself", value: "3", emoji: "😐"),
        .init(label: "Fairly confident — I have a plan and I'm executing it", value: "4", emoji: "🙂"),
        .init(label: "Confident — I want a mentor to sharpen me, not guide me from scratch", value: "5", emoji: "😊"),
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
                            LinearGradient(colors: [.trackTech, .ascendAccent], startPoint: .leading, endPoint: .trailing)
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
}

#Preview {
    NavigationStack {
        CareerMatchView()
    }
    .preferredColorScheme(.dark)
}
