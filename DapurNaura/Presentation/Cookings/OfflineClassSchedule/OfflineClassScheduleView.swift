//
//  OfflineClassScheduleView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/08/26.
//

import SwiftUI
import DNLibrary

struct OfflineClassScheduleView: View {
    @State private var viewModel: OfflineClassScheduleViewModel

    @State private var selectedClass: OfflineClass?

    @State private var isSheetShown = false

    @State private var purchaseUnavailableShown = false

    init(viewModel: OfflineClassScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        OfflineClassScheduleContent(
            state: viewModel.state,
            isCollapsed: viewModel.isCollapsed,
            onToggleMonth: viewModel.toggle,
            onSelect: { offlineClass in
                selectedClass = offlineClass
                isSheetShown = true
            },
            onRetry: { Task { await viewModel.load() } }
        )
        .navigationTitle("Kelas Offline")
        .overlay { materialsSheet }
        .animation(.snappy, value: isSheetShown)
        .alert("Belum Tersedia", isPresented: $purchaseUnavailableShown) {
        } message: {
            Text("Pembelian lewat aplikasi belum tersedia.")
        }
        .task { await viewModel.load() }
    }

    private var materialsSheet: some View {
        NoticeSheet(
            isPresented: $isSheetShown,
            imageURL: selectedClass?.imageUrl ?? "",
            title: selectedClass?.name ?? "",
            message: selectedClass.map(viewModel.materialsText) ?? "",
            actionTitle: buyTitle,
            action: buyAction,
            allowsDragToDismiss: false
        )
    }

    private var buyTitle: String? {
        guard let selectedClass, selectedClass.availability != .full else { return nil }
        return "Beli Kelas"
    }

    private var buyAction: (() -> Void)? {
        guard let selectedClass, selectedClass.availability != .full else { return nil }
        return {
            isSheetShown = false
            purchaseUnavailableShown = true
        }
    }
}
