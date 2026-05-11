//
//  ConfidenceDashboardView.swift
//  Group-14 — Features/Confidence/Views
//

import SwiftUI

struct ConfidenceDashboardView: View {
    @StateObject private var viewModel = ConfidenceViewModel()

    // Drive the animated ring trim
    @State private var animatedFraction: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // ── Page Title ────────────────────────────────────
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Confidence Score")
                                .font(.largeTitle.bold())
                                .foregroundColor(.ascendTextPrimary)
                            Text("Track your growth journey")
                                .font(.subheadline)
                                .foregroundColor(.ascendTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // ── Animated Ring ─────────────────────────────────
                        ringGauge

                        // ── Tier Card ─────────────────────────────────────
                        tierCard

                        // ── Boost Button ──────────────────────────────────
                        boostButton

                        // ── Milestones ────────────────────────────────────
                        milestonesSection

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .task {
                // Small delay so the ring animates from 0 → score on first appear
                try? await Task.sleep(nanoseconds: 300_000_000)
                withAnimation(.easeOut(duration: 1.2)) {
                    animatedFraction = viewModel.normalizedFraction
                }
            }
        }
    }

    // MARK: - Ring Gauge

    private var ringGauge: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.ascendSurface, lineWidth: 18)
                .frame(width: 220, height: 220)

            // Score ring
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

            // Score label
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

    // MARK: - Tier Card

    private var tierCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Tier")
                    .font(.caption)
                    .foregroundColor(.ascendTextSecondary)
                Text(viewModel.tier)
                    .font(.title3.bold())
                    .foregroundColor(.ascendAccent)
            }

            Spacer()

            // Animated progress bar
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(viewModel.normalizedFraction * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.ascendTextSecondary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.ascendSurface)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [.ascendPrimary, .ascendAccent], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * animatedFraction, height: 8)
                            .animation(.easeOut(duration: 1.0), value: animatedFraction)
                    }
                }
                .frame(width: 120, height: 8)
            }
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

    // MARK: - Boost Button

    private var boostButton: some View {
        Button {
            withAnimation {
                viewModel.boost(delta: 50)
                animatedFraction = viewModel.normalizedFraction
            }
        } label: {
            HStack {
                Image(systemName: "bolt.fill")
                Text(viewModel.isUpdating ? "Updating…" : "Boost My Confidence +50")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.ascendPrimary, .ascendAccent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .ascendPrimary.opacity(0.4), radius: 12, y: 6)
        }
        .disabled(viewModel.isUpdating)
        .scaleEffect(viewModel.isUpdating ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: viewModel.isUpdating)
    }

    // MARK: - Milestones

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)
                .foregroundColor(.ascendTextPrimary)

            ForEach(milestones, id: \.threshold) { m in
                milestonRow(m)
            }
        }
    }

    private func milestonRow(_ m: Milestone) -> some View {
        let achieved = viewModel.score >= m.threshold
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(achieved ? Color.ascendAccent : Color.ascendSurface)
                    .frame(width: 36, height: 36)
                Image(systemName: achieved ? "checkmark" : "lock.fill")
                    .font(.caption.bold())
                    .foregroundColor(achieved ? .white : .ascendTextSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(m.label)
                    .font(.subheadline.bold())
                    .foregroundColor(achieved ? .ascendTextPrimary : .ascendTextSecondary)
                Text("\(m.threshold) points")
                    .font(.caption)
                    .foregroundColor(.ascendTextSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.ascendCard)
                .opacity(achieved ? 1 : 0.6)
        )
    }

    // MARK: - Data

    private struct Milestone {
        let threshold: Int
        let label: String
    }

    private let milestones: [Milestone] = [
        .init(threshold: 100,  label: "First Step 🌱"),
        .init(threshold: 250,  label: "Building Momentum 🔥"),
        .init(threshold: 500,  label: "Halfway Hero 🏅"),
        .init(threshold: 750,  label: "Financial Warrior ⚔️"),
        .init(threshold: 1000, label: "Ascended 🚀"),
    ]
}

#Preview {
    ConfidenceDashboardView()
        .preferredColorScheme(.dark)
}
