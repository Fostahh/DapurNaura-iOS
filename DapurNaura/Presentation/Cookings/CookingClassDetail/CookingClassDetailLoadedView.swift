//
//  CookingClassDetailLoadedView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

struct CookingClassDetailLoadedView: View {
    let detail: CookingClassDetail

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignConstants.sectionSpacing) {
                RemoteImage(urlString: detail.imageUrl)
                    .frame(height: DesignConstants.detailImageHeight)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))

                Text(detail.name)
                    .font(.title2.bold())

                Text(detail.description_)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                PurchaseSection(detail: detail)

                Divider()

                Text("Resep")
                    .font(.headline)

                if isPurchased {
                    ForEach(detail.recipes, id: \.id) { recipe in
                        NavigationLink(
                            value: Route.recipes(.detail(classId: detail.id, recipeId: recipe.id))
                        ) {
                            RecipeRow(recipe: recipe, openable: true)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    ForEach(detail.recipes, id: \.id) { recipe in
                        RecipeRow(recipe: recipe, openable: false)
                    }
                }
            }
            .padding()
        }
    }

    private var isPurchased: Bool {
        detail.purchaseStatus == .purchased
    }
}
