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

                ForEach(detail.recipes, id: \.id) { recipe in
                    RecipeLink(recipe: recipe, classId: detail.id, openable: isPurchased)
                }
            }
            .padding()
        }
    }

    private var isPurchased: Bool {
        switch detail.purchaseStatus {
        case .purchased: true
        default: false
        }
    }
}
