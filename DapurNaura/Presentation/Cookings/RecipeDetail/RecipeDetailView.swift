//
//  RecipeDetailView.swift
//  DapurNaura
//
//  DN-021 — one recipe in full. Content is Bahasa Indonesia.
//  Replaces the DN-012 placeholder wholesale.
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
