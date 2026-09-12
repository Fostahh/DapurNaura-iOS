//
//  IngredientCheckRow.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct IngredientCheckRow: View {
    let ingredient: Ingredient
    let isTicked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
                Image(systemName: isTicked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isTicked ? Color.accentColor : Color.secondary)
                    .imageScale(.large)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredient.name)
                        .font(.subheadline)
                        .strikethrough(isTicked)

                    if let merk = ingredient.merk {
                        Text(merk)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .strikethrough(isTicked)
                    }
                }

                Spacer(minLength: DesignConstants.rowGutter)

                Text(ingredient.quantity)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .strikethrough(isTicked)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isTicked ? Color.secondary : Color.primary)
        .accessibilityAddTraits(isTicked ? .isSelected : [])
    }
}
