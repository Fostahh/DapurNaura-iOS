//
//  RecipeRow.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
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
