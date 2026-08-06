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
    @State private var viewModel: RecipePlaceholderViewModel

    init(viewModel: RecipePlaceholderViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            LoadFailedView(message: message) {
                Task { await viewModel.load() }
            }

        case .loaded(let recipe):
            VStack(spacing: DesignConstants.sectionSpacing) {
                RemoteImage(urlString: recipe.imageUrl, showsProgress: false)
                    .frame(height: DesignConstants.detailImageHeight)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))

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
        }
    }
}
