//
//  CookingClassListView.swift
//  DapurNaura
//
//  DN-009 — the cooking-class list. Content is Bahasa Indonesia.
//

import SwiftUI
import DNLibrary

struct CookingClassListView: View {
    @State private var viewModel: CookingClassListViewModel

    init(viewModel: CookingClassListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Kelas Masak")
        }
        .task { await viewModel.load() }
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

        case .loaded(let classes):
            List(classes, id: \.id) { cookingClass in
                CookingClassRow(cookingClass: cookingClass)
            }
            .listStyle(.plain)
        }
    }
}

private struct CookingClassRow: View {
    let cookingClass: CookingClass

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: cookingClass.imageUrl)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.quaternary)
                    .overlay { ProgressView() }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(alignment: .firstTextBaseline) {
                Text(cookingClass.name)
                    .font(.headline)
                Spacer()
                statusBadge
            }

            Text(cookingClass.description_)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(rupiah(cookingClass.price))
                    .font(.subheadline.bold())
                Spacer()
                Text("\(cookingClass.recipeCount) resep")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    // purchaseStatus is a UI hint, never a gate — locked content never reaches
    // the client in the first place (contract rule).
    private var statusBadge: some View {
        let (label, color): (String, Color) = switch cookingClass.purchaseStatus {
        case .purchased: ("Sudah Dibeli", .green)
        case .pendingVerification: ("Menunggu Verifikasi", .orange)
        case .notPurchased: ("Belum Dibeli", .secondary)
        }
        return Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }

    private func rupiah(_ value: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let grouped = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "Rp\(grouped)"
    }
}
