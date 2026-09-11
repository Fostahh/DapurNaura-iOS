//
//  PurchaseStatusBadge.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
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

    /// The wording lives in DNLibrary (DN-026). A label derived from a library enum and nothing else
    /// is data, not view context, so Android cannot word the same status differently — ARCHITECTURE §10.
    private var label: String {
        DNFormat.shared.purchaseStatusLabel(status: status)
    }

    /// The tint stays here on purpose. A colour is a decision about *this* badge on *this* surface,
    /// which is view context — §10's boundary is the view, and the library has no business knowing
    /// that "bought" reads green here.
    private var color: Color {
        switch status {
        case .purchased: .green
        case .pendingVerification: .orange
        case .notPurchased: .secondary
        }
    }
}
