//
//  OfflineClassAvailabilityBadge.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/08/26.
//

import SwiftUI
import DNLibrary

/// **Words and colour together, never colour alone.**
///
/// The three states are green, yellow and red — exactly the set red-green colour blindness
/// collapses, and it affects roughly one man in twelve. A reader who cannot tell *SUDAH PENUH*
/// from *MASIH BISA DAFTAR* would arrive at a class with no place left. The phrase is not
/// decoration beside the colour; it is what makes the colour safe to use.
struct OfflineClassAvailabilityBadge: View {
    let availability: OfflineClassAvailability

    var body: some View {
        Text(label)
            .font(.caption)
            .bold()
            .padding(.horizontal, DesignConstants.badgeHorizontalPadding)
            .padding(.vertical, DesignConstants.badgeVerticalPadding)
            .background(tint.opacity(DesignConstants.badgeTintOpacity), in: .capsule)
            .foregroundStyle(tint)
    }

    /// The wording lives in DNLibrary (§10) — a label derived from a library enum and nothing else
    /// is data, so an Android badge cannot word the same state differently.
    private var label: String {
        DNFormat.shared.offlineClassAvailabilityLabel(availability: availability)
    }

    /// The tint stays here, the same split DN-026 settled for `PurchaseStatusBadge`: a colour is a
    /// decision about this badge on this surface, and the library has no business knowing that
    /// "full" reads red here.
    private var tint: Color {
        DesignConstants.availabilityTint(for: availability)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
        OfflineClassAvailabilityBadge(availability: .available)
        OfflineClassAvailabilityBadge(availability: .nearlyFull)
        OfflineClassAvailabilityBadge(availability: .full)
    }
    .padding()
}
