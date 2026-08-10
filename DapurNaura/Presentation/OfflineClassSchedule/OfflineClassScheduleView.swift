//
//  OfflineClassScheduleView.swift
//  DapurNaura
//
//  DN-036 — the offline schedule. Content is Bahasa Indonesia.
//

import SwiftUI
import DNLibrary

struct OfflineClassScheduleView: View {
    @State private var viewModel: OfflineClassScheduleViewModel

    /// Whose materials the sheet is showing. A sheet is not a route (§4) — it is local
    /// presentation state on the view that raises it.
    ///
    /// **Deliberately not cleared on dismiss.** It is the sheet's content, and blanking it the
    /// instant the sheet starts leaving would animate an empty card off the screen.
    @State private var selectedClass: OfflineClass?

    /// Whether the sheet is up. Separate from [selectedClass] so `NoticeSheet` stays **mounted**
    /// across the whole cycle: a view inserted with `isPresented` already true has no false-to-true
    /// change to animate, which is why the sheet used to appear with no transition at all.
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

    /// The app's own `NoticeSheet`, unchanged in shape: a picture, a message, and now a button.
    ///
    /// **Mounted unconditionally**, with `selectedClass` deliberately not cleared on dismiss. A
    /// sheet inserted with `isPresented` already true has no false-to-true change to animate, and
    /// blanking the content as it leaves would animate an empty card off the screen.
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

    /// **No button when the class is full** — being full removes the way in, not the way to look.
    private var buyTitle: String? {
        guard let selectedClass, selectedClass.availability != .full else { return nil }
        return "Beli Kelas"
    }

    private var buyAction: (() -> Void)? {
        guard let selectedClass, selectedClass.availability != .full else { return nil }
        // The same answer the online class detail gives, because it is the same situation: the app
        // cannot take money yet, and says so rather than implying it did.
        return {
            isSheetShown = false
            purchaseUnavailableShown = true
        }
    }
}
