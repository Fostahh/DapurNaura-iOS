//
//  RecipePlaceholderView.swift
//  DapurNaura
//
//  DN-012 — TEMPORARY. This exists so the rule it proves is verifiable on the running
//  app: a recipe opens in a bought class and goes nowhere in every other state. The
//  real recipe screen — images, ingredients with their groups, and the method — is its
//  own ticket from the recipe-detail requirement approved 2026-08-06, and replaces this
//  file wholesale. Do not build on it.
//

import SwiftUI
import DNLibrary

struct RecipePlaceholderView: View {
    let recipe: RecipeSummary

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: recipe.imageUrl)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(.quaternary)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(recipe.name)
                .font(.title3.bold())

            if let portions = recipe.portions {
                Text("Porsi: \(portions)")
                    .foregroundStyle(.secondary)
            }
            if let loyang = recipe.loyang {
                Text("Loyang: \(loyang)")
                    .foregroundStyle(.secondary)
            }

            Text("Halaman resep belum dibuat.")
                .font(.footnote)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .padding()
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
