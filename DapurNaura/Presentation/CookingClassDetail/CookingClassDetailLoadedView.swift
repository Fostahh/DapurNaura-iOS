//
//  CookingClassDetailLoadedView.swift
//  DapurNaura
//
//  DN-015 — extracted out of CookingClassDetailView (ARCHITECTURE §3).
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

                // No recipe count here, by the owner's decision: the list below
                // already shows every recipe the class contains, so a number adds
                // nothing.
                Text("Resep")
                    .font(.headline)

                // DN-015: the screen decides the destination, not the row.
                // `RecipeRow` renders and knows nothing about `Route` — recipes
                // open only in a class the user has bought, and in every other
                // state the row is inert. The ingredients, method and video are
                // not merely hidden then; the server never sent them.
                ForEach(detail.recipes, id: \.id) { recipe in
                    if isPurchased {
                        NavigationLink(
                            value: Route.recipes(.detail(classId: detail.id, recipeId: recipe.id))
                        ) {
                            RecipeRow(recipe: recipe, openable: true)
                        }
                        .buttonStyle(.plain)
                    } else {
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
