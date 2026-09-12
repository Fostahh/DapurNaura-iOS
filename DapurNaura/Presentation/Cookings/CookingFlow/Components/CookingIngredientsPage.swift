//
//  CookingIngredientsPage.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct CookingIngredientsPage: View {
    let recipe: Recipe
    let isTicked: (Int, String) -> Bool
    let onToggle: (Int, String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignConstants.sectionSpacing) {
                Text("Siapkan bahan-bahan")
                    .font(.title2.bold())

                ForEach(Array(recipe.components.enumerated()), id: \.offset) { index, component in
                    if index > 0 {
                        Divider()
                    }

                    VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
                        if let name = component.name {
                            Text(name)
                                .font(.title3.bold())
                        }

                        ForEach(Array(component.ingredients.enumerated()), id: \.offset) { _, ingredient in
                            IngredientCheckRow(
                                ingredient: ingredient,
                                isTicked: isTicked(index, ingredient.name),
                                onTap: { onToggle(index, ingredient.name) }
                            )
                        }
                    }
                }
            }
            .padding(DesignConstants.sectionSpacing)
        }
    }
}
