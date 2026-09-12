//
//  RecipeImageCarousel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 07/08/26.
//

import SwiftUI

struct RecipeImageCarousel: View {
    let urls: [String]

    var body: some View {
        TabView {
            ForEach(Array(urls.enumerated()), id: \.offset) { _, url in
                RemoteImage(urlString: url)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: urls.count > 1 ? .always : .never))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: DesignConstants.detailImageHeight)
        .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))
    }
}
