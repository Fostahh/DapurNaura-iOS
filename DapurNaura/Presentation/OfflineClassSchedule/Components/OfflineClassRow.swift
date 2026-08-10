//
//  OfflineClassRow.swift
//  DapurNaura
//
//  DN-036 — one class as a ticket, following the owner's reference.
//

import SwiftUI
import DNLibrary

/// Picture on the leading edge, the class in the middle, the date standing apart on the trailing
/// edge — the shape the owner supplied on 2026-08-09.
///
/// **It renders no quota.** `OfflineClass.remainingQuota` exists so the library can derive the
/// availability state; how many people have signed up is the owner's business, and nothing here
/// may publish it (owner's decision, 2026-08-09).
///
/// Names no `Route` (§4): it takes values and the caller decides what pressing it means.
struct OfflineClassRow: View {
    let offlineClass: OfflineClass

    var body: some View {
        HStack(spacing: DesignConstants.rowGutter) {
            RemoteImage(urlString: offlineClass.imageUrl, showsProgress: false)
                .frame(
                    width: DesignConstants.ticketImageSize,
                    height: DesignConstants.ticketImageSize
                )
                .clipShape(.rect(cornerRadius: DesignConstants.thumbnailCornerRadius))

            details

            Spacer(minLength: 0)

            dateColumn
        }
        .padding(DesignConstants.rowGutter)
        .background(.background, in: .rect(cornerRadius: DesignConstants.ticketCornerRadius))
        // A neutral hairline, not the availability colour — owner's correction, 2026-08-10. The
        // badge carries the state on its own; repeating it on the outline and on the date made
        // three green things saying one thing, and a list of outlined colours read as noise.
        .overlay {
            RoundedRectangle(cornerRadius: DesignConstants.ticketCornerRadius)
                .stroke(.quaternary, lineWidth: DesignConstants.ticketBorderWidth)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
            Text(DNFormat.shared.offlineClassDate(date: offlineClass.date))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(offlineClass.name)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)

            Text(DNFormat.shared.offlineClassPrice(value: offlineClass.price))
                .font(.subheadline)
                .bold()

            OfflineClassAvailabilityBadge(availability: offlineClass.availability)
        }
    }

    /// The ticket stub: short month above the day, the way the owner's reference sets it.
    private var dateColumn: some View {
        VStack(spacing: 0) {
            Text(DNFormat.shared.offlineClassShortMonth(date: offlineClass.date))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(offlineClass.date.day)")
                .font(.title)
                .bold()
        }
        .frame(width: DesignConstants.ticketDateColumnWidth)
    }
}

#Preview("Tiga status") {
    VStack(spacing: DesignConstants.rowSpacing) {
        ForEach(OfflineClassPreviewSamples.september().classes, id: \.id) { offlineClass in
            OfflineClassRow(offlineClass: offlineClass)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
