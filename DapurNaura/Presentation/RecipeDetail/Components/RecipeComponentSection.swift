//
//  RecipeComponentSection.swift
//  DapurNaura
//
//  DN-021 — one part of a recipe: its bowl, then its method.
//

import SwiftUI
import DNLibrary

/// Ingredients and method are drawn **together, inside one section**, because that is the whole
/// reason the owner splits them: so a student can measure each component into its own bowl before
/// starting. A reader must never have to work out which bowl an ingredient belongs to.
///
/// `name` is nil for a recipe with no natural split; the heading then disappears rather than
/// showing an empty one.
struct RecipeComponentSection: View {
    let component: RecipeComponent

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
            if let name = component.name {
                Text(name)
                    .font(.title3.bold())
            }

            Text("Bahan")
                .font(.headline)
                .padding(.top, DesignConstants.rowSpacing)

            VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
                ForEach(Array(component.ingredients.enumerated()), id: \.offset) { _, ingredient in
                    IngredientRow(ingredient: ingredient)
                }
            }

            Text("Cara buat")
                .font(.headline)
                .padding(.top, DesignConstants.sectionSpacing)

            // Numbered and in order. This is a method someone follows with their hands busy,
            // so the number is the reader's place-marker, not decoration.
            VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
                ForEach(Array(component.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
                        Text("\(index + 1).")
                            .font(.subheadline.bold())
                            .frame(width: DesignConstants.stepNumberWidth, alignment: .trailing)
                        Text(step.text)
                            .font(.subheadline)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
}
