//
//  OfflineClassScheduleContent.swift
//  DapurNaura
//
//  DN-036 — buildable from state alone, so every state is previewable (ARCHITECTURE §3).
//

import SwiftUI
import DNLibrary

/// The schedule's three states, plus the empty one.
struct OfflineClassScheduleContent: View {
    let state: OfflineClassScheduleViewModel.State
    let isCollapsed: (String) -> Bool
    let onToggleMonth: (String) -> Void
    let onSelect: (OfflineClass) -> Void
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Memuat jadwal…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            LoadFailedView(message: message, retry: onRetry)

        case .loaded(let months) where months.isEmpty:
            // The owner ruled out an unpublished schedule as a business case, so this is a
            // fallback rather than a feature: a month can still empty as its last class passes,
            // and a blank screen with no explanation is the alternative (§7).
            ContentUnavailableView {
                Label("Belum Ada Jadwal", systemImage: "calendar")
            } description: {
                Text("Belum ada kelas offline yang dijadwalkan.")
            }

        case .loaded(let months):
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignConstants.sectionSpacing) {
                    ForEach(months, id: \.id) { month in
                        OfflineClassMonthSection(
                            month: month,
                            isCollapsed: isCollapsed(month.id),
                            onToggle: { onToggleMonth(month.id) },
                            onSelect: onSelect
                        )
                    }
                }
                .padding(DesignConstants.sectionSpacing)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

extension OfflineClassMonth {
    /// Identity for `ForEach` and for the collapsed set.
    ///
    /// Built from the year and the month's own name rather than an array index: a month keeps its
    /// identity across a reload, so a section the reader folded stays folded when the list comes
    /// back — which is the whole reason the collapsed set lives in the ViewModel.
    var id: String { "\(year)-\(month.name)" }
}

#Preview("Memuat") {
    OfflineClassScheduleContent(
        state: .loading,
        isCollapsed: { _ in false },
        onToggleMonth: { _ in },
        onSelect: { _ in },
        onRetry: {}
    )
}

#Preview("Gagal") {
    OfflineClassScheduleContent(
        state: .failed("Tidak ada koneksi internet."),
        isCollapsed: { _ in false },
        onToggleMonth: { _ in },
        onSelect: { _ in },
        onRetry: {}
    )
}

#Preview("Kosong") {
    OfflineClassScheduleContent(
        state: .loaded([]),
        isCollapsed: { _ in false },
        onToggleMonth: { _ in },
        onSelect: { _ in },
        onRetry: {}
    )
}

#Preview("Berisi") {
    OfflineClassScheduleContent(
        state: .loaded([
            OfflineClassPreviewSamples.august(),
            OfflineClassPreviewSamples.september()
        ]),
        isCollapsed: { _ in false },
        onToggleMonth: { _ in },
        onSelect: { _ in },
        onRetry: {}
    )
}

#Preview("Section tertutup") {
    OfflineClassScheduleContent(
        state: .loaded([
            OfflineClassPreviewSamples.august(),
            OfflineClassPreviewSamples.september()
        ]),
        isCollapsed: { $0.hasPrefix("2026-AUGUST") },
        onToggleMonth: { _ in },
        onSelect: { _ in },
        onRetry: {}
    )
}
