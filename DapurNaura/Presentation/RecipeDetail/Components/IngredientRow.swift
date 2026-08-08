//
//  IngredientRow.swift
//  DapurNaura
//
//  DN-021 — one ingredient: how much, what, and which brand.
//

import SwiftUI
import DNLibrary

/// `merk` is given visible weight deliberately. It is commercial advice, not decoration —
/// the audience is people learning to cook **for income**, and the owner names both the brand
/// to buy and the cheaper one that still works. Burying it as a footnote would drop half the
/// teaching.
///
/// `merk` and `note` are independently optional, and absent is not blank: a row simply does not
/// draw what it was not given.
struct IngredientRow: View {
    let ingredient: Ingredient

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
            Text(ingredient.quantity)
                .font(.subheadline.bold())
                .frame(width: DesignConstants.quantityColumnWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.subheadline)

                if let merk = ingredient.merk {
                    Text(merk)
                        .font(.caption)
                        .foregroundStyle(.tint)
                }
                if let note = ingredient.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview("Lengkap") {
    IngredientRow(ingredient: Ingredient(
        name: "Butter",
        quantity: "90gr",
        merk: "Butter Anchor atau Bakermix Anchor",
        note: "Sesuaikan dengan harga jual"
    ))
    .padding()
}

#Preview("Tanpa merk dan catatan") {
    IngredientRow(ingredient: Ingredient(
        name: "Dark chocolate", quantity: "150gr", merk: nil, note: nil
    ))
    .padding()
}
