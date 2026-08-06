//
//  CookingClassListContent.swift
//  DapurNaura
//
//  DN-015 — buildable from state alone, so every state is previewable (ARCHITECTURE §3).
//

import SwiftUI
import DNLibrary

/// The class list's three states.
///
/// Takes `state` rather than the ViewModel, so a `#Preview` can pin any state
/// exactly — including the failure, which the stub data layer never produces.
struct CookingClassListContent: View {
    let state: CookingClassListViewModel.State
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Memuat kelas…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            LoadFailedView(message: message, retry: onRetry)

        case .loaded(let classes):
            List(classes, id: \.id) { cookingClass in
                NavigationLink(value: Route.classes(.detail(classId: cookingClass.id))) {
                    CookingClassRow(cookingClass: cookingClass)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview("Memuat") {
    CookingClassListContent(state: .loading, onRetry: {})
}

#Preview("Gagal") {
    CookingClassListContent(state: .failed("Tidak ada koneksi internet."), onRetry: {})
}

#Preview("Berisi") {
    NavigationStack {
        CookingClassListContent(
            state: .loaded([
                CookingClass(
                    id: "1",
                    name: "Makanan Kekinian",
                    description: "Aneka jajanan yang lagi digemari, dari brownies sampai dessert box.",
                    imageUrl: "",
                    price: 125_000,
                    currency: "IDR",
                    recipeCount: 6,
                    purchaseStatus: .purchased
                ),
                // The pairing that crowds first at large text sizes: a long name
                // beside the widest badge. Preview it here rather than discovering
                // it on a device.
                CookingClass(
                    id: "2",
                    name: "Kue Kering Lebaran Spesial Keluarga",
                    description: "Nastar, kastengel, putri salju.",
                    imageUrl: "",
                    price: 150_000,
                    currency: "IDR",
                    recipeCount: 12,
                    purchaseStatus: .pendingVerification
                )
            ]),
            onRetry: {}
        )
    }
}
