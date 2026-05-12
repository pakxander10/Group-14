//
//  ExpertiseChipPickerSection.swift
//  Group-14 — Features/MentorOnboarding/Views
//
//  Searchable multi-select chip picker over the curated ExpertiseCatalog.
//  Used by mentor onboarding and mentor profile editing.
//

import SwiftUI

struct ExpertiseChipPickerSection: View {
    let selected: [String]
    let suggestions: [String]
    @Binding var searchQuery: String
    let onAdd: (String) -> Void
    let onRemove: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !selected.isEmpty {
                selectedChipsRow
            }
            searchField
            suggestionsList
        }
    }

    private var selectedChipsRow: some View {
        ExpertiseFlowLayout(spacing: 6) {
            ForEach(selected, id: \.self) { term in
                ExpertiseChip(term: term) { onRemove(term) }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.ascendTextSecondary)
            TextField("Search expertise (e.g. Roth IRA, iOS)", text: $searchQuery)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundColor(.white)
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.ascendTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.ascendSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var suggestionsList: some View {
        if suggestions.isEmpty {
            Text(searchQuery.isEmpty
                 ? "Pick a track above to see suggestions."
                 : "No matches.")
                .font(.caption)
                .foregroundColor(.ascendTextSecondary)
                .padding(.vertical, 4)
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                ExpertiseFlowLayout(spacing: 6) {
                    ForEach(suggestions, id: \.self) { term in
                        Button {
                            onAdd(term)
                        } label: {
                            Text(term)
                                .font(.footnote)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.ascendCard)
                                .foregroundColor(.ascendTextPrimary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.ascendAccent.opacity(0.4), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 180)
        }
    }
}

// MARK: - ExpertiseChip

private struct ExpertiseChip: View {
    let term: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(term)
                .font(.footnote.bold())
                .foregroundColor(.white)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(term)")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color.ascendAccent.opacity(0.85))
        )
    }
}

// MARK: - ExpertiseFlowLayout

/// Wraps subviews onto multiple lines, left-aligned. Name-suffixed to avoid
/// collision with `FlowLayout` in the legacy `QuestionnaireView.swift`.
struct ExpertiseFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = computeRows(subviews: subviews, maxWidth: maxWidth)
        let totalHeight = rows.reduce(CGFloat.zero) { $0 + $1.height + spacing } - (rows.isEmpty ? 0 : spacing)
        return CGSize(width: maxWidth, height: max(totalHeight, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(subviews: subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let subview = subviews[index]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var height: CGFloat = 0
    }

    private func computeRows(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = [Row()]
        var x: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let width = size.width
            let projected = (rows[rows.count - 1].indices.isEmpty ? width : x + spacing + width)

            if projected > maxWidth && !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
                x = 0
            }

            if rows[rows.count - 1].indices.isEmpty {
                x = width
            } else {
                x += spacing + width
            }
            rows[rows.count - 1].indices.append(index)
            rows[rows.count - 1].height = max(rows[rows.count - 1].height, size.height)
        }

        return rows
    }
}
