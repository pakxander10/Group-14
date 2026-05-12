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
                case 0: intentStep
                case 1: whoYouAreStep
                case 2: firstGenStep
                case 3: careerJourneyStep
                case 4: confidenceStep
                case 5: mentorPreferencesStep
                default: EmptyView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Step 0: Intent

    private var intentStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "What's bringing you here today?", subtitle: "There's no wrong answer.")
            ForEach(intentOptions) { option in
                optionCard(option: option, isSelected: vm.selectedIntent == option.value) {
                    vm.selectedIntent = option.value
                }
            }
        }
    }

    private let intentOptions: [MatchOption] = [
        .init(label: "I want to build a career in finance or tech but have no roadmap", value: "no_roadmap", emoji: "🗺️"),
        .init(label: "I just got my first job offer and I don't know what to do", value: "first_offer", emoji: "📩"),
        .init(label: "I'm about to graduate and I'm worried about my career path", value: "grad_worried", emoji: "🎓"),
        .init(label: "I'm looking to switch into finance or tech", value: "career_switch", emoji: "🔄"),
        .init(label: "I just want to feel less lost about all of this", value: "less_lost", emoji: "🧭"),
    ]

    // MARK: - Step 1: Who You Are

    private var whoYouAreStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "Tell us a little about yourself", subtitle: "This helps us find someone who gets your situation.")

            VStack(alignment: .leading, spacing: 12) {
                Text("How do you identify?").font(.subheadline.bold()).foregroundColor(.ascendTextPrimary)
                ForEach(genderOptions) { option in
                    compactOptionCard(option: option, isSelected: vm.selectedGender == option.value) {
                        vm.selectedGender = option.value
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("What year are you in?").font(.subheadline.bold()).foregroundColor(.ascendTextPrimary)
                ForEach(yearOptions) { option in
                    compactOptionCard(option: option, isSelected: vm.selectedYear == option.value) {
                        vm.selectedYear = option.value
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("What type of school do you attend?").font(.subheadline.bold()).foregroundColor(.ascendTextPrimary)
                ForEach(schoolTypeOptions) { option in
                    compactOptionCard(option: option, isSelected: vm.selectedSchoolType == option.value) {
                        vm.selectedSchoolType = option.value
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("What's your major or field? (optional)").font(.subheadline.bold()).foregroundColor(.ascendTextPrimary)
                TextField("e.g. Computer Science, Business, Undecided…", text: $vm.selectedMajor)
                    .padding(14)
                    .background(Color.ascendSurface)
                    .foregroundColor(.ascendTextPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private let genderOptions: [MatchOption] = [
        .init(label: "Man", value: "man", emoji: "👤"),
        .init(label: "Woman", value: "woman", emoji: "👤"),
        .init(label: "Non-binary", value: "non_binary", emoji: "👤"),
        .init(label: "Prefer not to say", value: "prefer_not", emoji: "🔒"),
    ]

    private let yearOptions: [MatchOption] = [
        .init(label: "Freshman", value: "freshman", emoji: "1️⃣"),
        .init(label: "Sophomore", value: "sophomore", emoji: "2️⃣"),
        .init(label: "Junior", value: "junior", emoji: "3️⃣"),
        .init(label: "Senior", value: "senior", emoji: "4️⃣"),
        .init(label: "Recent Graduate", value: "recent_grad", emoji: "🎓"),
        .init(label: "Working", value: "working", emoji: "💼"),
    ]

    private let schoolTypeOptions: [MatchOption] = [
        .init(label: "4-year university", value: "4year", emoji: "🏛️"),
        .init(label: "Community college", value: "community", emoji: "🏫"),
        .init(label: "Trade or vocational school", value: "trade", emoji: "🔧"),
        .init(label: "I'm not in school", value: "not_in_school", emoji: "🏠"),
    ]

    // MARK: - Step 2: First-Gen Status

    private var firstGenStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "Are you the first in your family navigating this?", subtitle: "This helps us match you with mentors who've walked a similar path.")
            ForEach(firstGenOptions) { option in
                optionCard(option: option, isSelected: vm.selectedFirstGen == option.value) {
                    vm.selectedFirstGen = option.value
                }
            }
        }
    }

    private let firstGenOptions: [MatchOption] = [
        .init(label: "Yes — I'm the first in my family to go to college", value: "first_gen_college", emoji: "🌱"),
        .init(label: "Yes — I'm the first in my family entering this career field", value: "first_gen_career", emoji: "🚀"),
        .init(label: "Somewhat — I have some family guidance but not much", value: "somewhat", emoji: "🤝"),
        .init(label: "No — I have family who've been through this", value: "no", emoji: "👨‍👩‍👧"),
    ]

    // MARK: - Step 3: Career Journey

    private var careerJourneyStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 20) {
                stepHeader(title: "Where are you in your career journey?", subtitle: "")
                ForEach(careerStageOptions) { option in
                    optionCard(option: option, isSelected: vm.selectedCareerStage == option.value) {
                        vm.selectedCareerStage = option.value
                    }
                }
            }

            Divider().background(Color.ascendSurface)

            VStack(alignment: .leading, spacing: 20) {
                stepHeader(title: "What kind of support would help you most?", subtitle: "")
                ForEach(careerSupportOptions) { option in
                    optionCard(option: option, isSelected: vm.selectedCareerSupport == option.value) {
                        vm.selectedCareerSupport = option.value
                    }
                }
            }
        }
    }

    private let careerStageOptions: [MatchOption] = [
        .init(label: "Still in school, exploring what's possible", value: "exploring", emoji: "🔭"),
        .init(label: "Actively applying for internships or jobs right now", value: "applying", emoji: "📝"),
        .init(label: "I have an offer but I'm not sure about it", value: "has_offer", emoji: "🤔"),
        .init(label: "I'm in my first role and trying to grow", value: "first_role", emoji: "🌱"),
        .init(label: "I'm looking to switch into finance or tech", value: "switching", emoji: "🔄"),
    ]

    private let careerSupportOptions: [MatchOption] = [
        .init(label: "Understanding what roles actually exist and what they pay", value: "roles", emoji: "🗺️"),
        .init(label: "Building my resume or LinkedIn for finance or tech", value: "resume", emoji: "📄"),
        .init(label: "Preparing for interviews", value: "interviews", emoji: "🎤"),
        .init(label: "Navigating my first 90 days in a new role", value: "first_90_days", emoji: "📅"),
        .init(label: "Finding a long-term mentor, not just one-time advice", value: "long_term", emoji: "🤝"),
    ]

    // MARK: - Step 4: Confidence

    private var confidenceStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "When it comes to your career, how do you feel right now?", subtitle: "Pick the one that feels most true.")
            ForEach(confidenceOptions) { option in
                optionCard(option: option, isSelected: vm.selectedConfidence == Int(option.value) ?? -1) {
                    vm.selectedConfidence = Int(option.value) ?? 3
                }
            }
        }
    }

    private let confidenceOptions: [MatchOption] = [
        .init(label: "Lost — I don't know where to start", value: "1", emoji: "😰"),
        .init(label: "Confused — I understand some basics but get stuck", value: "2", emoji: "😕"),
        .init(label: "Getting there — I know enough to get by but want more", value: "3", emoji: "😐"),
        .init(label: "Fairly confident — I have a foundation, I want to grow it", value: "4", emoji: "🙂"),
        .init(label: "Confident — I'm here to level up, not start from scratch", value: "5", emoji: "😊"),
    ]

    // MARK: - Step 5: Mentor Preferences

    private var mentorPreferencesStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 20) {
                stepHeader(title: "What matters most to you in a mentor?", subtitle: "Pick up to two.")
                ForEach(mentorPreferenceOptions) { option in
                    multiSelectCard(
                        option: option,
                        isSelected: vm.selectedMentorPreferences.contains(option.value)
                    ) {
                        vm.toggleMentorPreference(option.value)
                    }
                }
            }

            Divider().background(Color.ascendSurface)

            VStack(alignment: .leading, spacing: 20) {
                stepHeader(title: "How do you prefer to get support?", subtitle: "")
                ForEach(supportStyleOptions) { option in
                    optionCard(option: option, isSelected: vm.selectedSupportStyle == option.value) {
                        vm.selectedSupportStyle = option.value
                    }
                }
            }
        }
    }

    private let mentorPreferenceOptions: [MatchOption] = [
        .init(label: "Someone who started where I am — first-gen, limited resources", value: "first_gen", emoji: "🌱"),
        .init(label: "Someone in a role I want to be in someday", value: "aspirational", emoji: "🎯"),
        .init(label: "Someone who gives practical, direct answers", value: "practical", emoji: "⚡"),
        .init(label: "Someone I can build a longer relationship with over time", value: "long_term", emoji: "🤝"),
        .init(label: "Someone who understands what it's like to be underrepresented in finance or tech", value: "underrepresented", emoji: "💪"),
    ]

    private let supportStyleOptions: [MatchOption] = [
        .init(label: "Reading through threads and learning from others' questions", value: "threads", emoji: "📖"),
        .init(label: "Asking my own questions and getting direct answers", value: "direct", emoji: "💬"),
        .init(label: "A mix of both", value: "both", emoji: "🔄"),
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

    private func compactOptionCard(option: MatchOption, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(option.emoji).font(.body)
                Text(option.label).font(.subheadline)
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.ascendAccent)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.ascendSurface)
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
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
        CareerMatchView()
    }
    .preferredColorScheme(.dark)
}
