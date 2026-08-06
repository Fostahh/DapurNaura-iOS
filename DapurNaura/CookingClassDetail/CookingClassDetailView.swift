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
    @State private var purchaseUnavailableShown = false

    init(viewModel: CookingClassDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Detail Kelas")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
            .alert("Belum Tersedia", isPresented: $purchaseUnavailableShown) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Pembelian lewat aplikasi belum tersedia.")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Memuat kelas…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            ContentUnavailableView {
                Label("Gagal Memuat", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Coba Lagi") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
            }

        case .loaded(let detail):
            loadedBody(detail)
        }
    }

    private func loadedBody(_ detail: CookingClassDetail) -> some View {
        let purchased = isPurchased(detail.purchaseStatus)

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: detail.imageUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.quaternary)
                        .overlay { ProgressView() }
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(detail.name)
                    .font(.title2.bold())

                Text(detail.description_)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                purchaseSection(detail)

                Divider()

                // No recipe count here, by the owner's decision: the list below already
                // shows every recipe the class contains, so a number adds nothing.
                Text("Resep")
                    .font(.headline)

                ForEach(detail.recipes, id: \.id) { recipe in
                    recipeRow(recipe, purchased: purchased)
                }
            }
            .padding()
        }
    }

    /// Three states, not two. The price rides on the buy button and appears nowhere
    /// else, so a bought class shows no price at all — it is no longer actionable.
    @ViewBuilder
    private func purchaseSection(_ detail: CookingClassDetail) -> some View {
        switch detail.purchaseStatus {
        case .purchased:
            EmptyView()

        case .pendingVerification:
            // Deliberately no buy button. Someone who has already transferred money
            // and is shown one may conclude the transfer failed and send it twice —
            // which is the whole reason this state exists separately from "not bought".
            Label("Pembayaran sedang dicek", systemImage: "clock")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.orange)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

        case .notPurchased:
            Button {
                purchaseUnavailableShown = true
            } label: {
                Text("Beli Kelas · \(rupiah(detail.price))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    /// Recipes open only in a class the user has bought. In every other state the row
    /// is inert — and the ingredients, method and video are not merely hidden here,
    /// they were never sent by the server.
    @ViewBuilder
    private func recipeRow(_ recipe: RecipeSummary, purchased: Bool) -> some View {
        if purchased {
            NavigationLink {
                RecipePlaceholderView(recipe: recipe)
            } label: {
                RecipeRow(recipe: recipe, openable: true)
            }
            .buttonStyle(.plain)
        } else {
            RecipeRow(recipe: recipe, openable: false)
        }
    }

    private func isPurchased(_ status: PurchaseStatus) -> Bool {
        switch status {
        case .purchased: true
        default: false
        }
    }
}

private struct RecipeRow: View {
    let recipe: RecipeSummary
    let openable: Bool

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(.quaternary)
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.subheadline.weight(.semibold))

                // Portions and loyang are separate concepts and are never merged into
                // one string. They arrive nil for a class that has not been bought —
                // absent, not blank, so "locked" stays distinguishable from "no value".
                if let portions = recipe.portions {
                    Text("Porsi: \(portions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let loyang = recipe.loyang {
                    Text("Loyang: \(loyang)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: openable ? "chevron.right" : "lock.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
