//
//  CookingClassListView.swift
//  DapurNaura
//
//  DN-009 — the cooking-class list. Content is Bahasa Indonesia.
//

import SwiftUI
import DNLibrary

struct CookingClassListView: View {
    @State private var viewModel: CookingClassListViewModel

    init(viewModel: CookingClassListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // DN-033: this screen used to be the app's root — it owned the NavigationStack,
    // the single navigationDestination and the ViewModelFactory needed to satisfy it.
    // All three moved to CookingClassSelectionView when the choice screen took over as
    // the entry point, leaving an ordinary pushed screen. The back button is SwiftUI's.
    var body: some View {
        CookingClassListContent(
            state: viewModel.state,
            selectedCategory: viewModel.selectedCategory,
            onSelectCategory: { category in
                Task { await viewModel.select(category) }
            },
            onRetry: {
                Task { await viewModel.load() }
            }
        )
        // DN-033: was "Kelas Masak". It now names the choice that led here.
        .navigationTitle("Kelas Online")
        .task { await viewModel.load() }
    }
}
