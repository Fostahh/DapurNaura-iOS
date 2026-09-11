//
//  CookingClassListContent.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

struct CookingClassListContent: View {
    let state: CookingClassListViewModel.State
    let selectedCategory: CookingClassCategory?
    let onSelectCategory: (CookingClassCategory?) -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CategoryFilterChips(selected: selectedCategory, onSelect: onSelectCategory)

            switch state {
            case .loading:
                ProgressView("Memuat kelas…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let message):
                LoadFailedView(message: message, retry: onRetry)

            case .loaded(let classes) where classes.isEmpty:
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
