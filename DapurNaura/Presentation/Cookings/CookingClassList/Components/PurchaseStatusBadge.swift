//
//  PurchaseStatusBadge.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

struct PurchaseStatusBadge: View {
    let status: PurchaseStatus

    var body: some View {
        Text(label)
            .font(.caption)
            .padding(.horizontal, DesignConstants.badgeHorizontalPadding)
            .padding(.vertical, DesignConstants.badgeVerticalPadding)
            .background(color.opacity(DesignConstants.badgeTintOpacity), in: .capsule)
            .foregroundStyle(color)
    }

    private var label: String {
        DNFormat.shared.purchaseStatusLabel(status: status)
    }

    private var color: Color {
        switch status {
        case .purchased: .green
        case .pendingVerification: .orange
        case .notPurchased: .secondary
        }
    }
}
