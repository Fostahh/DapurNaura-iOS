//
//  CategoryFilterChips.swift
//  DapurNaura
//
//  DN-025 — the class list's category filter.
//

import SwiftUI
import DNLibrary

/// One row of chips, one of them active. `nil` is the *Semua* chip — the absence of a
/// filter is a choice like any other, so it is a value here rather than a special case.
///
/// Holds no wording of its own: the labels come from `DNFormat` (ARCHITECTURE §10), so an
/// Android chip row cannot word the same filter differently.
struct CategoryFilterChips: View {
    let selected: CookingClassCategory?
    let onSelect: (CookingClassCategory?) -> Void

    /// Written out rather than derived from the library's `allCases`, and `Semua` first:
    /// which chips appear and in what order is a screen decision, not the data layer's.
    private let choices: [CookingClassCategory?] = [nil, .minuman, .baking, .cooking]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: DesignConstants.rowSpacing) {
                ForEach(choices, id: \.self) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        Text(DNFormat.shared.categoryFilterLabel(category: category))
                            .font(.subheadline)
                            .padding(.horizontal, DesignConstants.chipHorizontalPadding)
                            .frame(minHeight: DesignConstants.minimumTapTarget)
                            .background(background(for: category), in: .capsule)
                            .foregroundStyle(category == selected ? .white : Color.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DesignConstants.rowGutter)
            .padding(.vertical, DesignConstants.rowSpacing)
        }
        // The row scrolls, but nothing else about it should look scrollable.
        .scrollIndicators(.hidden)
    }

    private func background(for category: CookingClassCategory?) -> some ShapeStyle {
        category == selected
            ? AnyShapeStyle(Color.accentColor)
            : AnyShapeStyle(Color.accentColor.opacity(DesignConstants.chipTintOpacity))
    }
}

#Preview("Semua terpilih") {
    CategoryFilterChips(selected: nil, onSelect: { _ in })
}

#Preview("Satu kategori terpilih") {
    CategoryFilterChips(selected: .baking, onSelect: { _ in })
}
