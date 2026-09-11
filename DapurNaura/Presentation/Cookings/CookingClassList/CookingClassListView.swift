//
//  CookingClassListView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

struct CookingClassListView: View {
    @State private var viewModel: CookingClassListViewModel

    init(viewModel: CookingClassListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

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
        .navigationTitle("Kelas Online")
        .task { await viewModel.load() }
    }
}
