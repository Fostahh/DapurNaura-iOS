//
//  CategoryFilterChips.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 08/08/26.
//

import SwiftUI
import DNLibrary

struct CategoryFilterChips: View {
    let selected: CookingClassCategory?
    let onSelect: (CookingClassCategory?) -> Void

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
        .scrollIndicators(.hidden)
    }

    private func background(for category: CookingClassCategory?) -> Color {
        category == selected
            ? .accentColor
            : .accentColor.opacity(DesignConstants.chipTintOpacity)
    }
}

#Preview("Semua terpilih") {
    CategoryFilterChips(selected: nil, onSelect: { _ in })
}

#Preview("Satu kategori terpilih") {
    CategoryFilterChips(selected: .baking, onSelect: { _ in })
}
