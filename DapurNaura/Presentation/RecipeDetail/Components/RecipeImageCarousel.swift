//
//  RecipeImageCarousel.swift
//  DapurNaura
//
//  DN-021 — a recipe carries more than one picture (ARCHITECTURE §3).
//

import SwiftUI

/// The requirement says *"the recipe's pictures — the recipe carries more than one"*, so a single
/// hero image would drop content the owner supplied. Paging rather than a vertical stack: on a
/// kitchen counter the method deserves the screen, not four photographs of the same cake.
struct RecipeImageCarousel: View {
    let urls: [String]

    var body: some View {
        TabView {
            ForEach(Array(urls.enumerated()), id: \.offset) { _, url in
                RemoteImage(urlString: url)
            }
        }
        .tabViewStyle(.page)
        .frame(height: DesignConstants.detailImageHeight)
        .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))
    }
}
