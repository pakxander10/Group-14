//
//  QuestionnaireView.swift
//  Group-14 — Features/Questionnaire/Views
//

import SwiftUI

struct QuestionnaireView: View {
    @StateObject private var viewModel = QuestionnaireViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                if viewModel.isComplete, let mentor = viewModel.matchedMentor {
                    // ── Result ─────────────────────────────────────────────
                    MentorMatchResultView(mentor: mentor, onReset: viewModel.reset)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    // ── Questionnaire ──────────────────────────────────────
                    VStack(spacing: 0) {
                        progressBar
                        stepContent
                        navigationButtons
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: viewModel.isComplete)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Find Your Mentor")
                    .font(.largeTitle.bold())
                    .foregroundColor(.ascendTextPrimary)
                Spacer()
                Text("\(viewModel.currentStep + 1) / \(viewModel.totalSteps)")
                    .font(.caption.bold())
                    .foregroundColor(.ascendTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.ascendSurface)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.ascendPrimary, .ascendAccent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * Double(viewModel.currentStep + 1) / Double(viewModel.totalSteps), height: 6)
                        .animation(.spring(), value: viewModel.currentStep)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch viewModel.currentStep {
                case 0: ageStep
                case 1: optionStep(
                    title: "What's your background?",
                    subtitle: "This helps us tailor your mentor match.",
                    options: viewModel.backgroundOptions,
                    selected: $viewModel.selectedBackground
                )
                case 2: optionStep(
                    title: "What area do you want guidance in?",
                    subtitle: "Choose the track that excites you most.",
                    options: viewModel.interestOptions,
                    selected: $viewModel.selectedInterest
                )
                case 3: optionStep(
                    title: "What's your primary goal?",
                    subtitle: "We'll find the perfect mentor for it.",
                    options: viewModel.goalOptions,
                    selected: $viewModel.selectedGoal
                )
                default: EmptyView()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Age Step

    private var ageStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: "How old are you?", subtitle: "Your age helps us personalize your financial journey.")

            VStack(spacing: 8) {
                Text("\(viewModel.selectedAge)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(.ascendAccent)
                    .frame(maxWidth: .infinity)

                Slider(value: Binding(
                    get: { Double(viewModel.selectedAge) },
                    set: { viewModel.selectedAge = Int($0) }
                ), in: 16...35, step: 1)
                .tint(.ascendAccent)

                HStack {
                    Text("16").font(.caption).foregroundColor(.ascendTextSecondary)
                    Spacer()
                    Text("35").font(.caption).foregroundColor(.ascendTextSecondary)
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.ascendSurface))
        }
    }

    // MARK: - Generic Option Step

    private func optionStep(title: String, subtitle: String, options: [QuestionnaireOption], selected: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(title: title, subtitle: subtitle)

            ForEach(options) { option in
                optionCard(option: option, isSelected: selected.wrappedValue == option.value) {
                    withAnimation(.spring(response: 0.3)) {
                        selected.wrappedValue = option.value
                    }
                }
            }
        }
    }

    private func optionCard(option: QuestionnaireOption, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(option.emoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? Color.ascendAccent.opacity(0.2) : Color.ascendCard)
                    .clipShape(Circle())

                Text(option.label)
                    .font(.subheadline.bold())
                    .foregroundColor(isSelected ? .ascendAccent : .ascendTextPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.ascendAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.ascendSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.ascendAccent : Color.clear, lineWidth: 1.5)
                    )
            )
        }
    }

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.ascendTextPrimary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.ascendTextSecondary)
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        VStack(spacing: 0) {
            Divider().background(Color.ascendSurface)

            HStack(spacing: 12) {
                if viewModel.currentStep > 0 {
                    Button {
                        withAnimation(.spring(response: 0.4)) { viewModel.previousStep() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .frame(width: 52, height: 52)
                            .background(Color.ascendSurface)
                            .foregroundColor(.ascendTextPrimary)
                            .clipShape(Circle())
                    }
                }

                let isLastStep = viewModel.currentStep == viewModel.totalSteps - 1
                Button {
                    if isLastStep {
                        viewModel.submit()
                    } else {
                        withAnimation(.spring(response: 0.4)) { viewModel.nextStep() }
                    }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(isLastStep ? "Find My Mentor ✨" : "Next")
                                .font(.headline)
                            if !isLastStep {
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(colors: [.ascendPrimary, .ascendAccent], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .ascendPrimary.opacity(0.35), radius: 10, y: 5)
                }
                .disabled(viewModel.isLoading)
            }
            .padding(20)
            .background(Color.ascendBackground)
        }
    }
}

// MARK: - MentorMatchResultView

struct MentorMatchResultView: View {
    let mentor: MentorProfile
    let onReset: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Celebration header
                VStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 64))
                    Text("Your Mentor Match!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.ascendTextPrimary)
                    Text("We found the perfect guide for your journey.")
                        .font(.subheadline)
                        .foregroundColor(.ascendTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // Mentor Card
                VStack(spacing: 20) {
                    // Avatar + name
                    VStack(spacing: 12) {
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
                            Text(mentor.name)
                                .font(.title2.bold())
                                .foregroundColor(.ascendTextPrimary)
                            Text(mentor.title)
                                .font(.subheadline)
                                .foregroundColor(.ascendTextSecondary)
                            Text(mentor.company)
                                .font(.caption.bold())
                                .foregroundColor(.ascendAccent)
                        }

                        // Track Badge
                        Label(mentor.track + " Track", systemImage: mentor.track == "Tech" ? "laptopcomputer" : "dollarsign.circle")
                            .font(.caption.bold())
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(mentor.track == "Tech" ? Color.trackTech.opacity(0.2) : Color.trackFinancial.opacity(0.2))
                            .foregroundColor(mentor.track == "Tech" ? .trackTech : .trackFinancial)
                            .clipShape(Capsule())
                    }

                    Divider().background(Color.ascendSurface)

                    // Bio
                    Text(mentor.bio)
                        .font(.body)
                        .foregroundColor(.ascendTextSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Expertise chips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expertise")
                            .font(.caption.bold())
                            .foregroundColor(.ascendTextSecondary)
                        FlowLayout(spacing: 8) {
                            ForEach(mentor.expertise, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(Color.ascendPrimary.opacity(0.2))
                                    .foregroundColor(.ascendAccent)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(mentor.yearsExperience) years at \(mentor.company)")
                        .font(.caption)
                        .foregroundColor(.ascendTextSecondary)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.ascendSurface)
                        .overlay(RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.ascendAccent.opacity(0.25), lineWidth: 1))
                )

                Button("Start Over") {
                    withAnimation { onReset() }
                }
                .font(.subheadline)
                .foregroundColor(.ascendTextSecondary)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.ascendBackground.ignoresSafeArea())
    }
}

// MARK: - FlowLayout (simple tag cloud)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.size.height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.size.height }.max() ?? 0
            for item in row {
                item.view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[(view: LayoutSubview, size: CGSize)]] {
        let maxWidth = proposal.width ?? 0
        var rows: [[(view: LayoutSubview, size: CGSize)]] = [[]]
        var rowWidth: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append((subview, size))
            rowWidth += size.width + spacing
        }
        return rows
    }
}

#Preview {
    QuestionnaireView()
}
