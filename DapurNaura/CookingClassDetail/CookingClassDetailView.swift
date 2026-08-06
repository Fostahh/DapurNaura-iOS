//
//  CookingClassDetailView.swift
//  DapurNaura
//
//  DN-012 — one class and the recipes it teaches. Content is Bahasa Indonesia.
//  Layout is the agent's, delegated by the owner in the requirement.
//

import SwiftUI
import DNLibrary

struct CookingClassDetailView: View {
    @State private var viewModel: CookingClassDetailViewModel

    init(viewModel: CookingClassDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Detail Kelas")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Memuat kelas…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            LoadFailedView(message: message) {
                Task { await viewModel.load() }
            }

        case .loaded(let detail):
            CookingClassDetailLoadedView(detail: detail)
        }
    }
}
