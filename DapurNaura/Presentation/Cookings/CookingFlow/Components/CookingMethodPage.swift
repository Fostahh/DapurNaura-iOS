//
//  CookingMethodPage.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct CookingMethodPage: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignConstants.sectionSpacing) {
                Text("Cara membuat")
                    .font(.title2.bold())

                // DN-053 replaces this with the video and its tappable timestamps.
                RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                    .fill(Color(.secondarySystemBackground))
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .overlay {
                        VStack(spacing: DesignConstants.rowSpacing) {
                            Image(systemName: "play.rectangle")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("Video menyusul")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                ForEach(Array(recipe.components.enumerated()), id: \.offset) { index, component in
                    if index > 0 {
                        Divider()
                    }

                    VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
                        if let name = component.name {
                            Text(name)
                                .font(.title3.bold())
                        }

                        ForEach(Array(component.steps.enumerated()), id: \.offset) { stepIndex, step in
                            HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
                                Text("\(stepIndex + 1).")
                                    .font(.subheadline.bold())
                                    .monospacedDigit()
                                Text(step.text)
                                    .font(.subheadline)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
            .padding(DesignConstants.sectionSpacing)
        }
    }
}
