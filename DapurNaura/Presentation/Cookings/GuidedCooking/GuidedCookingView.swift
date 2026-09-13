//
//  GuidedCookingView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct GuidedCookingView: View {
    @Environment(DapurNauraAppRouter.self) private var router
    @State private var viewModel: GuidedCookingViewModel
    @State private var controlsVisible = true
    @State private var idleTask: Task<Void, Never>?

    private static let idleDelay = Duration.seconds(5)

    init(viewModel: GuidedCookingViewModel) {
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
                    GuidedCookingProgressBar(
                        pageIndex: viewModel.pageIndex,
                        pageCount: GuidedCookingViewModel.pageCount
                    )

                    GuidedCookingPager(
                        recipe: recipe,
                        viewModel: viewModel,
                        onRestart: restart,
                        onFinish: finish
                    )

                    if controlsVisible, viewModel.pageIndex < GuidedCookingViewModel.pageCount - 1 {
                        GuidedCookingControls(
                            canGoBack: viewModel.pageIndex > 0,
                            onNext: next,
                            onBack: back
                        )
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(.rect)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in registerActivity() }
        )
        .task { await viewModel.load() }
        .task { registerActivity() }
        .onDisappear { idleTask?.cancel() }
    }

    private func registerActivity() {
        idleTask?.cancel()

        if !controlsVisible {
            withAnimation(.snappy) { controlsVisible = true }
        }

        idleTask = Task {
            try? await Task.sleep(for: Self.idleDelay)
            guard !Task.isCancelled else { return }
            withAnimation(.snappy) { controlsVisible = false }
        }
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
