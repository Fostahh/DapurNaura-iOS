//
//  CookingsFlowView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI

struct CookingsFlowView: View {
    @Environment(DapurNauraAppRouter.self) private var router

    private let factory: ViewModelFactory

    init(factory: ViewModelFactory) {
        self.factory = factory
    }

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            CookingClassSelectionView()
                .navigationDestination(for: Route.self) { route in
                    RouteDestination(route: route, factory: factory)
                        .id(route)
                }
        }
    }
}
