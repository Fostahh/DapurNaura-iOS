//
//  PurchaseSection.swift
//  DapurNaura
//
//  DN-015 — extracted out of CookingClassDetailView (ARCHITECTURE §3).
//

import SwiftUI
import DNLibrary

/// Three states, not two. The price rides on the buy button and appears nowhere
/// else, so a bought class shows no price at all — it is no longer actionable.
struct PurchaseSection: View {
    let detail: CookingClassDetail

    @State private var purchaseUnavailableShown = false

    var body: some View {
        switch detail.purchaseStatus {
        case .purchased:
            EmptyView()

        case .pendingVerification:
            // Deliberately no buy button. Someone who has already transferred money
            // and is shown one may conclude the transfer failed and send it twice —
            // which is the whole reason this state exists separately from
            // "not bought".
            Label("Pembayaran sedang dicek", systemImage: "clock")
                .font(.subheadline)
                .foregroundStyle(.orange)
                .padding(DesignConstants.noticePadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    .orange.opacity(DesignConstants.noticeTintOpacity),
                    in: .rect(cornerRadius: DesignConstants.noticeCornerRadius)
                )

        case .notPurchased:
            Button(action: showPurchaseUnavailable) {
                Text("Beli Kelas · \(rupiah(detail.price))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .alert("Belum Tersedia", isPresented: $purchaseUnavailableShown) {
            } message: {
                Text("Pembelian lewat aplikasi belum tersedia.")
            }
        }
    }

    private func showPurchaseUnavailable() {
        purchaseUnavailableShown = true
    }
}
