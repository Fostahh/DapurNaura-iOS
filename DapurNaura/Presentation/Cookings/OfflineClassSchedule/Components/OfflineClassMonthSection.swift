//
//  OfflineClassMonthSection.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/08/26.
//

import SwiftUI
import DNLibrary

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
                    .transition(
                        .opacity.combined(with: .move(edge: .top))
                    )
                }
            }
        }
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
