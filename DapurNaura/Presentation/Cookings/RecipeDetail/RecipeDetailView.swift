//
//  RecipeDetailView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 07/08/26.
//

import SwiftUI
import DNLibrary

struct RecipeDetailView: View {
    @State private var viewModel: RecipeDetailViewModel

    init(viewModel: RecipeDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        RecipeDetailContent(state: viewModel.state) {
            Task { await viewModel.load() }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}
