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
        // DN-038. The dots are drawn as plain white circles with no backing plate, so over a light
        // recipe photo they disappear — and with them the only sign that more pictures exist. The
        // backing plate holds them against any image. One picture shows no dots at all: a single
        // dot reads as a carousel that will not scroll.
        .tabViewStyle(.page(indexDisplayMode: urls.count > 1 ? .always : .never))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: DesignConstants.detailImageHeight)
        .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))
    }
}
