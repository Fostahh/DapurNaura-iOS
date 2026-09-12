//
//  IngredientRow.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 07/08/26.
//

import SwiftUI
import DNLibrary

struct IngredientRow: View {
    let ingredient: Ingredient

    @ScaledMetric(relativeTo: .subheadline) private var quantityWidth = DesignConstants.quantityColumnWidth

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
            Text(ingredient.quantity)
                .font(.subheadline.bold())
                .frame(width: quantityWidth, alignment: .leading)

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
