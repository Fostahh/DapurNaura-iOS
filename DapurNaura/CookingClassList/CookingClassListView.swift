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

    private let factory: ViewModelFactory

    init(viewModel: CookingClassListViewModel, factory: ViewModelFactory) {
        _viewModel = State(initialValue: viewModel)
        self.factory = factory
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Kelas Masak")
                // DN-015: the single registration in the app, attached to content
                // that always renders. It previously sat inside `case .loaded`,
                // so tapping Coba Lagi deregistered it and tore down any pushed
                // screen. Never move this inside the state switch.
                .navigationDestination(for: Route.self) { route in
                    RouteDestination(route: route, factory: factory)
                }
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Memuat kelas…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            LoadFailedView(message: message) {
                Task { await viewModel.load() }
            }

        case .loaded(let classes):
            List(classes, id: \.id) { cookingClass in
                NavigationLink(value: Route.classes(.detail(classId: cookingClass.id))) {
                    CookingClassRow(cookingClass: cookingClass)
                }
            }
            .listStyle(.plain)
        }
    }
}
