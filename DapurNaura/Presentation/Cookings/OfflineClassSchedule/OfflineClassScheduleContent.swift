//
//  OfflineClassScheduleContent.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/08/26.
//

import SwiftUI
import DNLibrary

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
