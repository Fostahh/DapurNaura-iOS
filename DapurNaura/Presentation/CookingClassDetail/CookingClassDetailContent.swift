//
//  CookingClassDetailContent.swift
//  DapurNaura
//
//  DN-015 — buildable from state alone, so every state is previewable (ARCHITECTURE §3).
//

import SwiftUI
import DNLibrary

/// The class detail's three states.
///
/// Takes `state` rather than the ViewModel, so a `#Preview` can pin any state
/// exactly — including the failure, which the stub data layer never produces.
struct CookingClassDetailContent: View {
    let state: CookingClassDetailViewModel.State
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Memuat kelas…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            LoadFailedView(message: message, retry: onRetry)

        case .loaded(let detail):
            CookingClassDetailLoadedView(detail: detail)
        }
    }
}

private func previewDetail(status: PurchaseStatus, locked: Bool) -> CookingClassDetail {
    CookingClassDetail(
        id: "1",
        name: "Makanan Kekinian",
        description: "Aneka jajanan yang lagi digemari, dari brownies sampai dessert box.",
        imageUrl: "",
        price: 125_000,
        currency: "IDR",
        purchaseStatus: status,
        recipes: [
            // portions and loyang are nil when the class is not bought — absent,
            // not blank, so "locked" stays distinguishable from "no value".
            RecipeSummary(
                id: "11",
                name: "Brownies",
                imageUrl: "",
                portions: locked ? nil : "20 pcs",
                loyang: locked ? nil : "20x20 cm"
            ),
            RecipeSummary(
                id: "12",
                name: "Dessert Box",
                imageUrl: "",
                portions: locked ? nil : "6 cup",
                loyang: nil
            )
        ]
    )
}

#Preview("Gagal") {
    CookingClassDetailContent(state: .failed("Tidak ada koneksi internet."), onRetry: {})
}

#Preview("Sudah dibeli") {
    NavigationStack {
        CookingClassDetailContent(
            state: .loaded(previewDetail(status: .purchased, locked: false)),
            onRetry: {}
        )
    }
}

#Preview("Menunggu verifikasi") {
    NavigationStack {
        CookingClassDetailContent(
            state: .loaded(previewDetail(status: .pendingVerification, locked: true)),
            onRetry: {}
        )
    }
}

#Preview("Belum dibeli") {
    NavigationStack {
        CookingClassDetailContent(
            state: .loaded(previewDetail(status: .notPurchased, locked: true)),
            onRetry: {}
        )
    }
}
