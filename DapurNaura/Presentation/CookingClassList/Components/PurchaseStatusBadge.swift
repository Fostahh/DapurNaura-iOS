//
//  PurchaseStatusBadge.swift
//  DapurNaura
//
//  DN-015 — extracted out of CookingClassListView (ARCHITECTURE §3).
//

import SwiftUI
import DNLibrary

/// A hint, never a gate. Locked content never reaches the client in the first
/// place — the server omits it by contract design — so this badge describes what
/// the user is looking at rather than protecting it.
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
        switch status {
        case .purchased: "Sudah Dibeli"
        case .pendingVerification: "Menunggu Verifikasi"
        case .notPurchased: "Belum Dibeli"
        }
    }

    private var color: Color {
        switch status {
        case .purchased: .green
        case .pendingVerification: .orange
        case .notPurchased: .secondary
        }
    }
}
