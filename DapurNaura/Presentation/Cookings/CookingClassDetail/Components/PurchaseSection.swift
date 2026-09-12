//
//  PurchaseSection.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

struct PurchaseSection: View {
    let detail: CookingClassDetail

    let onBuy: () -> Void

    var body: some View {
        switch detail.purchaseStatus {
        case .purchased:
            EmptyView()

        case .pendingVerification:
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
            Button(action: onBuy) {
                Text("Beli Kelas · \(DNFormat.shared.rupiah(value: detail.price))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
