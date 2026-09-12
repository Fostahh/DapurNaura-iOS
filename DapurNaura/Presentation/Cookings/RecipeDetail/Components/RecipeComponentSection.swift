//
//  RecipeComponentSection.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 07/08/26.
//

import SwiftUI
import DNLibrary

struct RecipeComponentSection: View {
    let component: RecipeComponent

    @ScaledMetric(relativeTo: .subheadline) private var stepNumberWidth = DesignConstants.stepNumberWidth

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

            VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
                ForEach(Array(component.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
                        Text("\(index + 1).")
                            .font(.subheadline.bold())
                            .frame(width: stepNumberWidth, alignment: .trailing)
                        Text(step.text)
                            .font(.subheadline)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
}
