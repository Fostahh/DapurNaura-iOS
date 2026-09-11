//
//  RootView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI

struct RootView: View {
    @Environment(DapurNauraAppRouter.self) private var router

    private let factory: ViewModelFactory

    init(factory: ViewModelFactory) {
        self.factory = factory
    }

    var body: some View {
        ZStack {
            switch router.root {
            case .auth:
                AuthFlowView(factory: factory)
                    .transition(.move(edge: .leading))

            case .main:
                CookingsFlowView(factory: factory)
                    .transition(.move(edge: .trailing))
            }
        }
        .overlay(alignment: .top) { ToastHost() }
    }
}
