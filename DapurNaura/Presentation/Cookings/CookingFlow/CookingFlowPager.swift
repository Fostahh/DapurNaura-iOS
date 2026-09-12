//
//  CookingFlowPager.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

/// The three pages of the cooking flow, moved by button rather than by swipe.
///
/// The pages sit side by side and the row is offset, the way a pager works. A `.transition` cannot
/// do this correctly: SwiftUI captures a view's removal transition when it is **inserted**, so after
/// stepping back, page 1/3 still carried the backward removal and left towards trailing on the next
/// step forward. Offsetting is position rather than identity, so the direction is right by
/// construction and no page has to remember which way it last travelled.
struct CookingFlowPager: View {
    let recipe: Recipe
    let viewModel: CookingFlowViewModel
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

                CookingMethodPage(recipe: recipe)
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
