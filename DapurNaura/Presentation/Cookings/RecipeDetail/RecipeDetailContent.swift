//
//  RecipeDetailContent.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 07/08/26.
//

import SwiftUI
import DNLibrary

struct RecipeDetailContent: View {
    let state: RecipeDetailViewModel.State
    let onRetry: () -> Void
    let onStartCooking: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Memuat resep…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            LoadFailedView(message: message, retry: onRetry)

        case .loaded(let recipe):
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignConstants.sectionSpacing) {
                    if !recipe.images.isEmpty {
                        RecipeImageCarousel(urls: recipe.images)
                    }

                    Text(recipe.name)
                        .font(.title2.bold())

                    if recipe.portions != nil || recipe.loyang != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            if let portions = recipe.portions {
                                Text("Porsi: \(portions)")
                            }
                            if let loyang = recipe.loyang {
                                Text("Loyang: \(loyang)")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    ForEach(Array(recipe.components.enumerated()), id: \.offset) { index, component in
                        if index > 0 { Divider() }
                        RecipeComponentSection(component: component)
                    }
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: onStartCooking) {
                    Text("Mulai buat resep")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, DesignConstants.sectionSpacing)
                .padding(.vertical, DesignConstants.rowGutter)
                .background(.bar)
            }
            .navigationTitle(recipe.name)
        }
    }
}

// MARK: - Previews

private func previewRecipe(components: [RecipeComponent], portions: String? = nil) -> Recipe {
    Recipe(
        id: "11",
        classId: "1",
        name: "Brownies Red Velvet Cheese & Original Cheese",
        images: [],
        portions: portions,
        loyang: "Loyang sekat 20x20 cm",
        videoUrl: "https://placehold.co/video/brownies.mp4",
        components: components
    )
}

private let browniesComponent = RecipeComponent(
    name: "Brownies",
    ingredients: [
        Ingredient(name: "Dark chocolate", quantity: "150gr", merk: nil, note: nil),
        Ingredient(
            name: "Butter", quantity: "90gr",
            merk: "Butter Anchor atau Bakermix Anchor", note: "Sesuaikan dengan harga jual"
        ),
        Ingredient(name: "Telur", quantity: "2 butir", merk: nil, note: nil),
        Ingredient(name: "Gula halus", quantity: "150gr", merk: nil, note: nil),
        Ingredient(
            name: "Tepung terigu protein rendah", quantity: "100gr",
            merk: "Kunci Biru", note: nil
        )
    ],
    steps: [
        RecipeStep(
            text: "Lelehkan dark chocolate dan butter dengan cara di-tim atau langsung di kompor "
                + "dengan api kecil dan diaduk terus.",
            videoTimestampSeconds: nil
        ),
        RecipeStep(
            text: "Kocok telur dan gula halus menggunakan whisk hingga gula larut, "
                + "masukkan lelehan coklat, aduk rata.",
            videoTimestampSeconds: nil
        )
    ]
)

private let topingComponent = RecipeComponent(
    name: "Toping creamcheese",
    ingredients: [
        Ingredient(
            name: "Creamcheese", quantity: "150gr",
            merk: "Elle atau Anchor", note: "Procis oles untuk varian ekonomis"
        ),
        Ingredient(
            name: "Margarin / butter", quantity: "35gr",
            merk: "Bakermix Anchor", note: "Dipakai DN (Owner)"
        ),
        Ingredient(name: "Whipping cream cair", quantity: "20gr", merk: nil, note: "Opsional"),
        Ingredient(
            name: "Pasta red velvet", quantity: "2 tetes",
            merk: nil, note: "Pewarna — hanya untuk varian red velvet"
        )
    ],
    steps: [
        RecipeStep(
            text: "Mix creamcheese, gula halus, margarin dan whipping cream. "
                + "Masukkan kuning telur, mix lagi, kemudian masukkan tepung.",
            videoTimestampSeconds: nil
        ),
        RecipeStep(text: "Panggang suhu 170°C selama 30 menitan.", videoTimestampSeconds: nil)
    ]
)

#Preview("Memuat") {
    RecipeDetailContent(state: .loading, onRetry: {}, onStartCooking: {})
}

#Preview("Gagal") {
    RecipeDetailContent(
        state: .failed("Tidak ada koneksi internet."),
        onRetry: {},
        onStartCooking: {}
    )
}

#Preview("Dua komponen") {
    NavigationStack {
        RecipeDetailContent(
            state: .loaded(previewRecipe(components: [browniesComponent, topingComponent])),
            onRetry: {},
            onStartCooking: {}
        )
    }
}

#Preview("Satu komponen tanpa judul") {
    NavigationStack {
        RecipeDetailContent(
            state: .loaded(previewRecipe(
                components: [RecipeComponent(
                    name: nil,
                    ingredients: browniesComponent.ingredients,
                    steps: browniesComponent.steps
                )],
                portions: "20 pcs"
            )),
            onRetry: {},
            onStartCooking: {}
        )
    }
}
