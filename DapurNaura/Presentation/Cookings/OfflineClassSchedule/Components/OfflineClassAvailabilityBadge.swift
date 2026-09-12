//
//  OfflineClassAvailabilityBadge.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/08/26.
//

import SwiftUI
import DNLibrary

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

    private var label: String {
        DNFormat.shared.offlineClassAvailabilityLabel(availability: availability)
    }

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
