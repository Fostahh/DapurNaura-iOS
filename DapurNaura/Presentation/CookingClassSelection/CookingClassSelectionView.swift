//
//  CookingClassSelectionView.swift
//  DapurNaura
//
//  DN-033 — the app's entry screen, taken over from the class list.
//

import SwiftUI

/// The first screen: which kind of class did you come for?
///
/// **No ViewModel, deliberately.** §1 puts one between a view and a use case, and
/// there is no use case here — the two choices are literals, nothing is fetched, and
/// §7's three states do not exist because nothing can fail. A ViewModel would hold no
/// state and forward no events. This is the absence of the thing a ViewModel manages,
/// **not a precedent for skipping one on a screen that loads anything.**
///
/// It owns the app's `NavigationStack` and its single `navigationDestination`, both
/// moved here from `CookingClassListView` when that stopped being the root. §4 wants
/// the registration on content that always renders; this screen has no state switch
/// at all, so it is the safest place that registration has sat.
struct CookingClassSelectionView: View {
    @Environment(DapurNauraAppRouter.self) private var router

    private let factory: ViewModelFactory

    /// A sheet is not a route (§4) — it is local presentation state on the view that
    /// raises it.
    @State private var offlineNoticeShown = false

    init(factory: ViewModelFactory) {
        self.factory = factory
    }

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            CookingClassSelectionContent(onSelectOffline: showOfflineNotice)
                .navigationTitle("Dapur Naura")
                .navigationDestination(for: Route.self) { route in
                    // DN-015: `.id(route)` anchors view identity to the route value.
                    // Without it, identity is positional — replacing the route at a
                    // given depth reuses the previous screen's @State.
                    RouteDestination(route: route, factory: factory)
                        .id(route)
                }
        }
        // DN-033: an overlay on the stack, not `.sheet` — the notice is our own view
        // (owner's instruction, 2026-08-09), so it is presented like any other view.
        // Overlaying the stack rather than its root puts it above the navigation bar.
        .overlay {
            NoticeSheet(
                isPresented: $offlineNoticeShown,
                imageURL: "https://placehold.co/600x400/png?text=Kelas+Offline",
                title: "Segera Hadir",
                message: "Kelas Offline sedang kami siapkan. Mohon ditunggu, ya.",
                // Owner's decision, 2026-08-09: not needed here yet. The X is the way out.
                allowsDragToDismiss: false
            )
        }
    }

    private func showOfflineNotice() {
        offlineNoticeShown = true
    }
}
