//
//  CookingFlowView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct CookingFlowView: View {
    @Environment(DapurNauraAppRouter.self) private var router
    @State private var viewModel: CookingFlowViewModel

    init(viewModel: CookingFlowViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let message):
                ContentUnavailableView {
                    Label("Gagal Memuat", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Coba Lagi", action: retry)
                }

            case .loaded(let recipe):
                VStack(spacing: 0) {
                    CookingFlowProgressBar(
                        pageIndex: viewModel.pageIndex,
                        pageCount: CookingFlowViewModel.pageCount
                    )

                    CookingFlowPager(
                        recipe: recipe,
                        viewModel: viewModel,
                        onRestart: restart,
                        onFinish: finish
                    )

                    if viewModel.pageIndex < CookingFlowViewModel.pageCount - 1 {
                        CookingFlowControls(
                            canGoBack: viewModel.pageIndex > 0,
                            onNext: next,
                            onBack: back
                        )
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func retry() {
        Task { await viewModel.load() }
    }

    private func next() {
        withAnimation(.snappy) { viewModel.advance() }
    }

    private func back() {
        withAnimation(.snappy) { viewModel.goBack() }
    }

    private func restart() {
        Task {
            await viewModel.clearStoredProgress()
            withAnimation(.snappy) { viewModel.resetToFirstPage() }
        }
    }

    private func finish() {
        guard !router.path.isEmpty else { return }
        router.path.removeLast()
    }
}
