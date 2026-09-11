//
//  CookingClassDetailView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

struct CookingClassDetailView: View {
    @State private var viewModel: CookingClassDetailViewModel

    init(viewModel: CookingClassDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        CookingClassDetailContent(state: viewModel.state) {
            Task { await viewModel.load() }
        }
        .navigationTitle("Detail Kelas")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}
