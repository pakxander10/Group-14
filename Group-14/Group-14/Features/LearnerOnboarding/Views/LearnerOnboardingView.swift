//
//  LearnerOnboardingView.swift
//  Group-14 — Features/LearnerOnboarding/Views
//
//  YOUR view (Xander). Partner never touches this file.
//  Questions aligned to Ascend blueprint spec.
//

import SwiftUI

struct LearnerOnboardingView: View {
    @StateObject private var viewModel = LearnerOnboardingViewModel()
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.ascendBackground.ignoresSafeArea()

            if viewModel.isComplete, let mentor = viewModel.matchedMentor {
                matchResultScreen(mentor: mentor)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                VStack(spacing: 0) {
                    progressHeader
                    stepContent
                    navigationBar
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isComplete)
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Create Learner Profile")
                    .font(.largeTitle.bold())
                    .foregroundColor(.ascendTextPrimary)
                Spacer()
                Text("\(viewModel.currentStep + 1) / \(viewModel.totalSteps)")
                    .font(.caption.bold())
                    .foregroundColor(.ascendTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.ascendSurface).frame(height: 6)
                    Capsule()
                        .fill(LinearGradient(colors: [.ascendPrimary, .ascendAccent],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * viewModel.progressFraction, height: 6)
                        .animation(.spring(), value: viewModel.currentStep)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
    }

    // MARK: - Step Router

    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch viewModel.currentStep {
                case 0: nameStep
                case 1: trackStep
                case 2: demographicsStep
                case 3: schoolStep
                case 4: intentStep
                case 5: confidenceStep
                case 6: financialAccountsStep
                default: EmptyView()
                }

                if let error = viewModel.errorMessage {
                    Text(error).font(.caption).foregroundColor(.red).padding(.horizontal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
    }

    // MARK: ── Step 0: Name ─────────────────────────────────────────────

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(
                title: "What's your name?",
                subtitle: "Your mentor will use this to personalize their guidance."
            )
            TextField("First name", text: $viewModel.data.name)
                .font(.title2.bold())
                .padding(18)
                .background(Color.ascendSurface)
                .foregroundColor(.ascendTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.ascendAccent.opacity(viewModel.data.name.isEmpty ? 0 : 0.6),
                                lineWidth: 1.5)
                )
                .tint(.ascendAccent)
        }
    }

    // MARK: ── Step 1: Track Selection ─────────────────────────────────

    private var trackStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(
                title: "What kind of guidance are you seeking?",
                subtitle: "This determines which Fidelity mentors we show you."
            )
            ForEach(MentorTrack.allCases) { track in
                trackCard(track: track, isSelected: viewModel.data.track == track) {
                    viewModel.data.track = track
                }
            }
        }
    }

    private func trackCard(track: MentorTrack, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { action() }
        } label: {
            HStack(spacing: 16) {
                Text(track.emoji)
                    .font(.title)
                    .frame(width: 52, height: 52)
                    .background(isSelected ? Color.ascendAccent.opacity(0.2) : Color.ascendCard)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(track.displayName)
                        .font(.headline)
                        .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)
                    Text(track.subtitle)
                        .font(.caption)
                        .foregroundColor(.ascendTextSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.ascendAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color.ascendSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.ascendAccent : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: ── Step 2: Demographics ────────────────────────────────────

    private var demographicsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            // First-gen
            VStack(alignment: .leading, spacing: 12) {
                stepHeader(
                    title: "Are you a first-generation college student?",
                    subtitle: "First-gen students get specialized mentor matching."
                )
                firstGenCard(label: "Yes, I'm first-gen 🌱", value: true)
                firstGenCard(label: "No / Not applicable",   value: false)
            }

            // Gender
            VStack(alignment: .leading, spacing: 12) {
                Text("How do you identify?")
                    .font(.headline)
                    .foregroundColor(.ascendTextPrimary)
                Text("Ascend focuses on connecting young women and underrepresented students.")
                    .font(.caption)
                    .foregroundColor(.ascendTextSecondary)

                ForEach(LearnerGender.allCases) { gender in
                    selectionCard(
                        emoji: gender.emoji,
                        label: gender.displayName,
                        isSelected: viewModel.data.gender == gender,
                        onTap: { viewModel.data.gender = gender }
                    )
                }
            }
        }
    }

    private func firstGenCard(label: String, value: Bool) -> some View {
        let isSelected = viewModel.data.isFirstGen == value
        return Button {
            withAnimation(.spring(response: 0.3)) { viewModel.data.isFirstGen = value }
        } label: {
            HStack {
                Text(label)
                    .font(.subheadline.bold())
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.ascendAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14).fill(Color.ascendSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.ascendAccent : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: ── Step 3: School / Career ─────────────────────────────────

    private var schoolStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            // School type
            VStack(alignment: .leading, spacing: 12) {
                stepHeader(
                    title: "What type of school do you attend?",
                    subtitle: "Or select your current situation."
                )
                ForEach(SchoolType.allCases) { type in
                    selectionCard(
                        emoji: type.emoji,
                        label: type.displayName,
                        isSelected: viewModel.data.schoolType == type,
                        onTap: { viewModel.data.schoolType = type }
                    )
                }
            }

            // Graduation Year
            VStack(alignment: .leading, spacing: 12) {
                Text("Expected graduation year")
                    .font(.headline).foregroundColor(.ascendTextPrimary)

                VStack(spacing: 8) {
                    Text("\(viewModel.data.graduationYear)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.ascendAccent)
                        .frame(maxWidth: .infinity)

                    Slider(value: Binding(
                        get: { Double(viewModel.data.graduationYear) },
                        set: { viewModel.data.graduationYear = Int($0) }
                    ), in: 2024...2032, step: 1)
                    .tint(.ascendAccent)

                    HStack {
                        Text("2024").font(.caption).foregroundColor(.ascendTextSecondary)
                        Spacer()
                        Text("2032").font(.caption).foregroundColor(.ascendTextSecondary)
                    }
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.ascendSurface))
            }

            // Major / Occupation
            VStack(alignment: .leading, spacing: 8) {
                Text("Your major or current occupation")
                    .font(.headline).foregroundColor(.ascendTextPrimary)

                TextField("e.g. Business, Computer Science, Barista…",
                          text: $viewModel.data.majorOrOccupation)
                    .font(.subheadline)
                    .padding(16)
                    .background(Color.ascendSurface)
                    .foregroundColor(.ascendTextPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.ascendAccent.opacity(viewModel.data.majorOrOccupation.isEmpty ? 0 : 0.5),
                                    lineWidth: 1.5)
                    )
                    .tint(.ascendAccent)
            }
        }
    }

    // MARK: ── Step 4: Intent ──────────────────────────────────────────

    private var intentStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(
                title: "What brought you here today?",
                subtitle: "Choose the goal that resonates most with you right now."
            )
            ForEach(LearnerIntent.allCases) { intent in
                selectionCard(
                    emoji: intent.emoji,
                    label: intent.displayName,
                    isSelected: viewModel.data.intent == intent,
                    onTap: { viewModel.data.intent = intent }
                )
            }
        }
    }

    // MARK: ── Step 5: Baseline Confidence ─────────────────────────────

    private var confidenceStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(
                title: "Where do you feel you are right now?",
                subtitle: "Rate your current financial or career confidence — be honest! This is your starting point."
            )

            VStack(spacing: 16) {
                // Large score display
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.ascendPrimary, .ascendAccent],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .opacity(0.2)

                    VStack(spacing: 2) {
                        Text("\(viewModel.data.baselineConfidence)")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundColor(.ascendAccent)
                        Text("out of 10")
                            .font(.caption)
                            .foregroundColor(.ascendTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity)

                Text(confidenceLabel(for: viewModel.data.baselineConfidence))
                    .font(.subheadline.bold())
                    .foregroundColor(.ascendAccent)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Slider(value: Binding(
                    get: { Double(viewModel.data.baselineConfidence) },
                    set: { viewModel.data.baselineConfidence = Int($0) }
                ), in: 1...10, step: 1)
                .tint(.ascendAccent)

                HStack {
                    Text("1 — Just starting").font(.caption).foregroundColor(.ascendTextSecondary)
                    Spacer()
                    Text("10 — Very confident").font(.caption).foregroundColor(.ascendTextSecondary)
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.ascendSurface))
        }
    }

    private func confidenceLabel(for score: Int) -> String {
        switch score {
        case 1...2:  return "Total beginner — that's totally okay 🌱"
        case 3...4:  return "Just getting started 🤔"
        case 5...6:  return "I know the basics 📚"
        case 7...8:  return "Fairly comfortable 💪"
        case 9...10: return "Confident, but want to grow more 🚀"
        default:     return ""
        }
    }

    // MARK: ── Step 6: Financial Accounts (Financial track only) ────────

    private var financialAccountsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(
                title: "Which financial accounts do you currently have?",
                subtitle: "Select all that apply. This helps us match you with the right mentor."
            )

            ForEach(FinancialAccount.allCases) { account in
                multiSelectCard(
                    emoji: account.emoji,
                    label: account.displayName,
                    isSelected: viewModel.data.financialAccounts.contains(account),
                    onTap: { viewModel.toggleAccount(account) }
                )
            }
        }
    }

    // MARK: - Reusable Components

    private func selectionCard(emoji: String, label: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { onTap() }
        } label: {
            HStack(spacing: 14) {
                Text(emoji).font(.title2)
                    .frame(width: 42, height: 42)
                    .background(isSelected ? Color.ascendAccent.opacity(0.2) : Color.ascendCard)
                    .clipShape(Circle())
                Text(label).font(.subheadline.bold())
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.ascendAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14).fill(Color.ascendSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.ascendAccent : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    /// Multi-select variant — does NOT deselect on re-tap, uses square checkbox icon
    private func multiSelectCard(emoji: String, label: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { onTap() }
        } label: {
            HStack(spacing: 14) {
                Text(emoji).font(.title2)
                    .frame(width: 42, height: 42)
                    .background(isSelected ? Color.ascendAccent.opacity(0.2) : Color.ascendCard)
                    .clipShape(Circle())
                Text(label).font(.subheadline.bold())
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextSecondary)
                    .font(.title3)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14).fill(Color.ascendSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.ascendAccent : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title3.bold()).foregroundColor(.ascendTextPrimary)
            Text(subtitle).font(.subheadline).foregroundColor(.ascendTextSecondary)
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.ascendSurface)
            HStack(spacing: 12) {
                if viewModel.currentStep > 0 {
                    Button {
                        withAnimation(.spring()) { viewModel.previousStep() }
                    } label: {
                        Image(systemName: "chevron.left").font(.headline)
                            .frame(width: 52, height: 52)
                            .background(Color.ascendSurface)
                            .foregroundColor(.ascendTextPrimary)
                            .clipShape(Circle())
                    }
                }

                let isLast = viewModel.currentStep == viewModel.totalSteps - 1

                Button {
                    if isLast { viewModel.submit() }
                    else { withAnimation(.spring()) { viewModel.nextStep() } }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(isLast ? "Find My Mentor ✨" : "Next").font(.headline)
                            if !isLast { Image(systemName: "chevron.right") }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(colors: [.ascendPrimary, .ascendAccent],
                                       startPoint: .leading, endPoint: .trailing)
                        .opacity(viewModel.canAdvance ? 1 : 0.5)
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .ascendPrimary.opacity(viewModel.canAdvance ? 0.35 : 0), radius: 10, y: 5)
                }
                .disabled(!viewModel.canAdvance || viewModel.isLoading)
            }
            .padding(20)
            .background(Color.ascendBackground)
        }
    }

    // MARK: - Match Result

    private func matchResultScreen(mentor: MentorProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("🎉").font(.system(size: 64))
                    Text("Hi \(viewModel.data.name)!")
                        .font(.largeTitle.bold()).foregroundColor(.ascendTextPrimary)
                    Text("Meet your matched Fidelity mentor")
                        .font(.subheadline).foregroundColor(.ascendTextSecondary)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: mentor.track == "Tech" ? [.trackTech, .ascendAccent] : [.trackFinancial, .ascendPrimary],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 88, height: 88)
                        Text(mentor.avatarInitials)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .ascendPrimary.opacity(0.4), radius: 12)

                    VStack(spacing: 4) {
                        Text(mentor.name).font(.title2.bold()).foregroundColor(.ascendTextPrimary)
                        Text(mentor.title).font(.subheadline).foregroundColor(.ascendTextSecondary)
                        Text(mentor.company).font(.caption.bold()).foregroundColor(.ascendAccent)
                    }

                    Label("\(mentor.track) Track", systemImage: mentor.track == "Tech" ? "laptopcomputer" : "dollarsign.circle")
                        .font(.caption.bold())
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background((mentor.track == "Tech" ? Color.trackTech : Color.trackFinancial).opacity(0.2))
                        .foregroundColor(mentor.track == "Tech" ? .trackTech : .trackFinancial)
                        .clipShape(Capsule())

                    Divider().background(Color.ascendSurface)

                    Text(mentor.bio)
                        .font(.body).foregroundColor(.ascendTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    // Expertise tags
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 8) {
                        ForEach(mentor.expertise, id: \.self) { tag in
                            Text(tag)
                                .font(.caption.bold())
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                                .background(Color.ascendPrimary.opacity(0.2))
                                .foregroundColor(.ascendAccent)
                                .clipShape(Capsule())
                        }
                    }

                    Text("\(mentor.yearsExperience) years at \(mentor.company)")
                        .font(.caption).foregroundColor(.ascendTextSecondary)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24).fill(Color.ascendSurface)
                        .overlay(RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.ascendAccent.opacity(0.25), lineWidth: 1))
                )
                .padding(.horizontal, 20)

                Button("Go to My Profile") { onComplete() }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(LinearGradient(colors: [.ascendPrimary, .ascendAccent],
                                               startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    .shadow(color: .ascendPrimary.opacity(0.4), radius: 10, y: 5)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.ascendBackground.ignoresSafeArea())
    }
}

#Preview {
    LearnerOnboardingView(onComplete: {})
        .preferredColorScheme(.dark)
}
