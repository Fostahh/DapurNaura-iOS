//
//  OfflineClassMonthSection.swift
//  DapurNaura
//
//  DN-036 — one month, openable and closable.
//

import SwiftUI
import DNLibrary

/// A month heading with its classes underneath, which the reader can fold away.
///
/// Names no `Route` (§4): pressing a class is a closure the screen supplies.
struct OfflineClassMonthSection: View {
    let month: OfflineClassMonth
    let isCollapsed: Bool
    let onToggle: () -> Void
    let onSelect: (OfflineClass) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
            header

            if !isCollapsed {
                ForEach(month.classes, id: \.id) { offlineClass in
                    Button {
                        onSelect(offlineClass)
                    } label: {
                        OfflineClassRow(offlineClass: offlineClass)
                    }
                    .buttonStyle(.plain)
                    // Rows slide out from under the heading rather than blinking away. Asymmetric
                    // on purpose: they leave upward, towards the header that swallowed them.
                    .transition(
                        .opacity.combined(with: .move(edge: .top))
                    )
                }
            }
        }
        // On the whole section, not just the chevron: the rows appearing and the arrow turning are
        // one gesture's worth of movement, so they have to run on one animation.
        .animation(.snappy, value: isCollapsed)
    }

    private var header: some View {
        Button(action: onToggle) {
            HStack(spacing: DesignConstants.sectionHeaderSpacing) {
                Text(DNFormat.shared.offlineClassMonthTitle(month: month))
                    .font(.title3)
                    .bold()

                joinableCount

                Spacer(minLength: 0)

                Image(systemName: "chevron.down")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
            }
            .foregroundStyle(.primary)
            .frame(minHeight: DesignConstants.minimumTapTarget)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    /// **Absent rather than zero when every class that month is full.** A `0` beside a chevron
    /// reads as an error; nothing at all reads as "no room here", which is what it means.
    ///
    /// It is what makes a *closed* section still worth reading — a reader scanning two folded
    /// months can see where there is still room without opening either.
    @ViewBuilder
    private var joinableCount: some View {
        if month.joinableCount > 0 {
            Text("\(month.joinableCount)")
                .font(.caption)
                .bold()
                .padding(.horizontal, DesignConstants.badgeHorizontalPadding)
                .padding(.vertical, DesignConstants.badgeVerticalPadding)
                .background(.tint.opacity(DesignConstants.badgeTintOpacity), in: .capsule)
                .foregroundStyle(.tint)
        }
    }
}

#Preview("Terbuka") {
    ScrollView {
        OfflineClassMonthSection(
            month: OfflineClassPreviewSamples.september(),
            isCollapsed: false,
            onToggle: {},
            onSelect: { _ in }
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Tertutup, dan sebulan penuh tanpa sisa tempat") {
    ScrollView {
        VStack(spacing: DesignConstants.sectionSpacing) {
            OfflineClassMonthSection(
                month: OfflineClassPreviewSamples.september(),
                isCollapsed: true,
                onToggle: {},
                onSelect: { _ in }
            )

            // Every class full — the section shows no number at all.
            OfflineClassMonthSection(
                month: OfflineClassPreviewSamples.august(),
                isCollapsed: false,
                onToggle: {},
                onSelect: { _ in }
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
