//
//  MatchResultView.swift
//  Group-14 — Features/MentorMatch/Views
//

import SwiftUI

struct MatchResultView: View {
    let mentor: MentorProfile
    let onReset: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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

                NavigationLink(destination: MentorProfileView(mentor: mentor)) {
                    VStack(spacing: 20) {
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

                            Label(mentor.track + " Track",
                                  systemImage: mentor.track == "Tech" ? "laptopcomputer" : "dollarsign.circle")
                                .font(.caption.bold())
                                .padding(.horizontal, 12).padding(.vertical, 5)
                                .background(mentor.track == "Tech" ? Color.trackTech.opacity(0.2) : Color.trackFinancial.opacity(0.2))
                                .foregroundColor(mentor.track == "Tech" ? .trackTech : .trackFinancial)
                                .clipShape(Capsule())
                        }

                        Divider().background(Color.ascendSurface)

                        Text(mentor.bio)
                            .font(.body)
                            .foregroundColor(.ascendTextSecondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Expertise")
                                .font(.caption.bold())
                                .foregroundColor(.ascendTextSecondary)
                            MatchFlowLayout(spacing: 8) {
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

                        HStack {
                            Text("\(mentor.yearsExperience) years at \(mentor.company)")
                                .font(.caption)
                                .foregroundColor(.ascendTextSecondary)
                            Spacer()
                            Text("View full profile →")
                                .font(.caption.bold())
                                .foregroundColor(.ascendAccent)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.ascendSurface)
                            .overlay(RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.ascendAccent.opacity(0.25), lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)

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

// MARK: - Flow Layout

struct MatchFlowLayout: Layout {
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
