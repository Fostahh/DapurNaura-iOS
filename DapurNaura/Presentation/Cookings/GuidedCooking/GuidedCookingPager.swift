//
//  GuidedCookingPager.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct GuidedCookingPager: View {
    let recipe: Recipe
    let viewModel: GuidedCookingViewModel
    let onRestart: () -> Void
    let onFinish: () -> Void

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                CookingIngredientsPage(
                    recipe: recipe,
                    isTicked: { viewModel.isTicked(componentIndex: $0, ingredientName: $1) },
                    onToggle: { viewModel.toggle(componentIndex: $0, ingredientName: $1) }
                )
                .frame(width: proxy.size.width)

                CookingMethodPage(recipe: recipe, isActive: viewModel.pageIndex == 1)
                    .frame(width: proxy.size.width)

                CookingFinishedPage(
                    recipeName: recipe.name,
                    onRestart: onRestart,
                    onFinish: onFinish
                )
                .frame(width: proxy.size.width)
            }
            .offset(x: -CGFloat(viewModel.pageIndex) * proxy.size.width)
        }
        .clipped()
    }
}
