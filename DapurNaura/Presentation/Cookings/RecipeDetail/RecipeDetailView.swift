//
//  RecipeDetailView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 07/08/26.
//

import SwiftUI
import DNLibrary

struct RecipeDetailView: View {
    @Environment(DapurNauraAppRouter.self) private var router
    @State private var viewModel: RecipeDetailViewModel

    private let recipeId: String

    init(recipeId: String, viewModel: RecipeDetailViewModel) {
        self.recipeId = recipeId
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        RecipeDetailContent(
            state: viewModel.state,
            onRetry: { Task { await viewModel.load() } },
            onStartCooking: { router.path.append(.recipes(.cook(recipeId: recipeId))) }
        )
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}
