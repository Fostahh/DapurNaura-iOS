//
//  CookingClassListContent.swift
//  DapurNaura
//
//  DN-015 — buildable from state alone, so every state is previewable (ARCHITECTURE §3).
//

import SwiftUI
import DNLibrary

/// The class list's three states, under a filter row that outlives all of them.
///
/// Takes `state` rather than the ViewModel, so a `#Preview` can pin any state
/// exactly — including the failure, which the stub data layer never produces.
struct CookingClassListContent: View {
    let state: CookingClassListViewModel.State
    let selectedCategory: CookingClassCategory?
    let onSelectCategory: (CookingClassCategory?) -> Void
    let onRetry: () -> Void

    var body: some View {
        // DN-025: the chips sit outside the switch on purpose. Every chip tap is a request,
        // so a row that lived inside `case .loaded` would vanish exactly when the user needs
        // it — mid-load, or on a failure they want to escape by choosing another category.
        VStack(spacing: 0) {
            CategoryFilterChips(selected: selectedCategory, onSelect: onSelectCategory)

            switch state {
            case .loading:
                ProgressView("Memuat kelas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let message):
                LoadFailedView(message: message, retry: onRetry)

            case .loaded(let classes) where classes.isEmpty:
                // A category with nothing in it is a successful answer, so it offers no
                // Coba Lagi — retrying would fetch the same empty list (ARCHITECTURE §7).
                ContentUnavailableView {
                    Label("Belum Ada Kelas", systemImage: "tray")
                } description: {
                    Text("Belum ada kelas di kategori ini.")
                }

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
}

#Preview("Memuat") {
    CookingClassListContent(
        state: .loading,
        selectedCategory: .baking,
        onSelectCategory: { _ in },
        onRetry: {}
    )
}

#Preview("Gagal") {
    CookingClassListContent(
        state: .failed("Tidak ada koneksi internet."),
        selectedCategory: nil,
        onSelectCategory: { _ in },
        onRetry: {}
    )
}

#Preview("Kategori kosong") {
    CookingClassListContent(
        state: .loaded([]),
        selectedCategory: .cooking,
        onSelectCategory: { _ in },
        onRetry: {}
    )
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
                    category: .baking,
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
                    category: .baking,
                    purchaseStatus: .pendingVerification
                )
            ]),
            selectedCategory: nil,
            onSelectCategory: { _ in },
            onRetry: {}
        )
    }
}
