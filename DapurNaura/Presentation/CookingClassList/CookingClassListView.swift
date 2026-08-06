//
//  CookingClassListView.swift
//  DapurNaura
//
//  DN-009 — the cooking-class list. Content is Bahasa Indonesia.
//

import SwiftUI
import DNLibrary

struct CookingClassListView: View {
    @State private var viewModel: CookingClassListViewModel

    @Environment(DapurNauraAppRouter.self) private var router

    private let factory: ViewModelFactory

    init(viewModel: CookingClassListViewModel, factory: ViewModelFactory) {
        _viewModel = State(initialValue: viewModel)
        self.factory = factory
    }

    var body: some View {
        // DN-015: the stack binds to the router's path, so the app has one owned,
        // inspectable navigation path rather than SwiftUI's implicit one.
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            CookingClassListContent(state: viewModel.state) {
                Task { await viewModel.load() }
            }
            .navigationTitle("Kelas Masak")
            // DN-015: the single registration in the app, attached to content that
            // always renders. It previously sat inside `case .loaded`, so tapping
            // Coba Lagi deregistered it and tore down any pushed screen. Never
            // move this inside the state switch.
            .navigationDestination(for: Route.self) { route in
                // DN-015: `.id(route)` anchors view identity to the route value.
                // Without it, identity is positional — replacing the route at a
                // given depth reuses the previous screen's @State, so the old
                // ViewModel survives and the screen shows the previous class.
                RouteDestination(route: route, factory: factory)
                    .id(route)
            }
        }
        .task { await viewModel.load() }
    }
}
