//
//  PurchaseSection.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

/// Three states, not two. The price rides on the buy button and appears nowhere
/// else, so a bought class shows no price at all — it is no longer actionable.
struct PurchaseSection: View {
    let detail: CookingClassDetail

    /// Pressed when the user wants to pay. **A closure, not a `Route`** — §4 keeps route names at
    /// screen level, and this is a section under `Components/`. The screen decides where it goes.
    let onBuy: () -> Void

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
            // DN-048: this used to answer with "Pembelian lewat aplikasi belum tersedia." It now
            // opens the payment flow. What the flow cannot yet do is record the payment — so a user
            // who sends proof returns to this same button, and that is honest rather than broken.
            Button(action: onBuy) {
                Text("Beli Kelas · \(DNFormat.shared.rupiah(value: detail.price))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
