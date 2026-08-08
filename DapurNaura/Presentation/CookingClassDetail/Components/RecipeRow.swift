//
//  RecipeRow.swift
//  DapurNaura
//
//  DN-015 — extracted out of CookingClassDetailView (ARCHITECTURE §3).
//

import SwiftUI
import DNLibrary

struct RecipeRow: View {
    let recipe: RecipeSummary
    let openable: Bool

    var body: some View {
        HStack(spacing: DesignConstants.rowGutter) {
            RemoteImage(urlString: recipe.imageUrl, showsProgress: false)
                .frame(width: DesignConstants.thumbnailSize, height: DesignConstants.thumbnailSize)
                .clipShape(.rect(cornerRadius: DesignConstants.thumbnailCornerRadius))

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.subheadline.bold())

                // Portions and loyang are separate concepts and are never merged into
                // one string. They arrive nil for a class that has not been bought —
                // absent, not blank, so "locked" stays distinguishable from "no value".
                if let portions = recipe.portions {
                    Text("Porsi: \(portions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let loyang = recipe.loyang {
                    Text("Loyang: \(loyang)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: openable ? "chevron.right" : "lock.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
    }
}
