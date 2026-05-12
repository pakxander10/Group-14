//
//  ConfidenceDashboardView.swift
//  Group-14 — Features/Confidence/Views
//
//  Renders the Finance-Exclusive Readiness Ladder.
//  Tech-track learners see an ineligible state — the score and tiers are
//  exclusive to the Financial track.
//

import SwiftUI

struct ConfidenceDashboardView: View {
    @StateObject private var viewModel = ConfidenceViewModel()
    @AppStorage("userId") private var userId: String = ""

    // Drives the ring's animated reveal on first appear.
    @State private var animatedFraction: Double = 0
    @State private var isShowingInfoSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        header

                        if viewModel.isEligibleForScoring {
                            eligibleContent
                        } else {
                            ineligibleContent
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .task(id: userId) {
                viewModel.load(userId: userId)
            }
            // Drive the ring's animated reveal off the loaded score so a slow
            // network doesn't cause the ring to settle on the wrong value.
            .onChange(of: viewModel.score) { _, newScore in
                let target = Double(max(0, min(1000, newScore))) / 1000.0
                withAnimation(.easeOut(duration: 1.2)) {
                    animatedFraction = target
                }
            }
            .sheet(isPresented: $isShowingInfoSheet) {
                earningPointsSheet
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Confidence Score")
                    .font(.largeTitle.bold())
                    .foregroundColor(.ascendTextPrimary)
                Text("Your Financial Readiness Ladder")
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
            }

            Spacer()

            Button {
                isShowingInfoSheet = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.ascendAccent)
            }
            .accessibilityLabel("How do I earn points?")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Eligible (Financial Track)

    private var eligibleContent: some View {
        VStack(spacing: 28) {
            ringGauge
            currentTierCard
            tierListSection
        }
    }

    // MARK: - Ineligible (Tech Track)

    private var ineligibleContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.ascendAccent)
                .padding(.top, 24)

            Text("Readiness Ladder is Finance-only")
                .font(.title3.bold())
                .foregroundColor(.ascendTextPrimary)
                .multilineTextAlignment(.center)

            Text("The Confidence Score and tier progression are exclusive to the Financial track. Tech-track learners advance through the mentor matching path instead.")
                .font(.subheadline)
                .foregroundColor(.ascendTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ascendSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.ascendAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Ring Gauge

    private var ringGauge: some View {
        ZStack {
            Circle()
                .stroke(Color.ascendSurface, lineWidth: 18)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: animatedFraction)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.confidenceLow, .confidenceMid, .confidenceHigh]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)
                .animation(.easeOut(duration: 1.2), value: animatedFraction)

            VStack(spacing: 4) {
                Text("\(viewModel.score)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.ascendTextPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeOut, value: viewModel.score)

                Text("out of 1000")
                    .font(.caption)
                    .foregroundColor(.ascendTextSecondary)
            }
        }
        .shadow(color: .ascendAccent.opacity(0.25), radius: 24)
    }

    // MARK: - Current Tier Card

    private var currentTierCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Tier")
                        .font(.caption)
                        .foregroundColor(.ascendTextSecondary)
                    Text(viewModel.tier.displayName)
                        .font(.title3.bold())
                        .foregroundColor(.ascendAccent)
                }

                Spacer()

                Text("\(Int(viewModel.normalizedFraction * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.ascendTextSecondary)
            }

            Text(viewModel.tier.readinessPrompt)
                .font(.subheadline)
                .foregroundColor(.ascendTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.ascendBackground)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.ascendPrimary, .ascendAccent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * animatedFraction, height: 8)
                        .animation(.easeOut(duration: 1.0), value: animatedFraction)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ascendSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.ascendAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Tier List

    private var tierListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Readiness Ladder")
                .font(.headline)
                .foregroundColor(.ascendTextPrimary)

            ForEach(ConfidenceTier.allCases, id: \.self) { tier in
                tierRow(tier)
            }
        }
    }

    private func tierRow(_ tier: ConfidenceTier) -> some View {
        let isCurrent = viewModel.tier == tier
        let isAchieved = viewModel.score >= tier.threshold

        return HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(isAchieved ? Color.ascendAccent : Color.ascendSurface)
                    .frame(width: 36, height: 36)
                Image(systemName: isAchieved ? "checkmark" : "lock.fill")
                    .font(.caption.bold())
                    .foregroundColor(isAchieved ? .white : .ascendTextSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(tier.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(isAchieved ? .ascendTextPrimary : .ascendTextSecondary)

                    if isCurrent {
                        Text("CURRENT")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(Color.ascendAccent)
                            )
                    }
                }

                Text("\(tier.range.lowerBound)–\(tier.range.upperBound) points")
                    .font(.caption)
                    .foregroundColor(.ascendTextSecondary)

                Text(tier.readinessPrompt)
                    .font(.caption)
                    .foregroundColor(.ascendTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.ascendCard)
                .opacity(isAchieved ? 1 : 0.6)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isCurrent ? Color.ascendAccent : Color.clear, lineWidth: 2)
                )
        )
    }

    // MARK: - Earning Points Sheet

    private var earningPointsSheet: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Points are earned on the Financial Track only.")
                            .font(.subheadline)
                            .foregroundColor(.ascendTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: 10) {
                            earningRow(icon: "checklist", title: "Complete Questionnaire", points: "+30")
                            earningRow(icon: "square.and.pencil", title: "First Finance Post", points: "+25")
                            earningRow(icon: "text.bubble", title: "Subsequent Posts", points: "+5")
                            earningRow(icon: "hand.thumbsup", title: "Upvote", points: "+1")
                            earningRow(icon: "bubble.left.and.bubble.right", title: "Mentor Replies", points: "+10")
                        }

                        Text("Tech-track learners do not earn confidence points — the Readiness Ladder is exclusive to the Financial track.")
                            .font(.footnote)
                            .foregroundColor(.ascendTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Earning Finance Points")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isShowingInfoSheet = false }
                        .foregroundColor(.ascendAccent)
                }
            }
        }
    }

    private func earningRow(icon: String, title: String, points: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.ascendAccent.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline.bold())
                    .foregroundColor(.ascendAccent)
            }

            Text(title)
                .font(.subheadline)
                .foregroundColor(.ascendTextPrimary)

            Spacer()

            Text(points)
                .font(.subheadline.bold())
                .foregroundColor(.ascendAccent)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.ascendSurface)
        )
    }
}

#Preview {
    ConfidenceDashboardView()
        .preferredColorScheme(.dark)
}
