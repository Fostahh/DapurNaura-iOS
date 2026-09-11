//
//  CookingClassRow.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

struct CookingClassRow: View {
    let cookingClass: CookingClass

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
            RemoteImage(urlString: cookingClass.imageUrl)
                .frame(height: DesignConstants.listImageHeight)
                .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))

            HStack(alignment: .firstTextBaseline) {
                Text(cookingClass.name)
                    .font(.headline)
                Spacer()
                PurchaseStatusBadge(status: cookingClass.purchaseStatus)
            }

            Text(cookingClass.description_)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(DNFormat.shared.rupiah(value: cookingClass.price))
                    .font(.subheadline.bold())
                Spacer()
                Text("\(cookingClass.recipeCount) resep")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, DesignConstants.rowSpacing)
    }
}
