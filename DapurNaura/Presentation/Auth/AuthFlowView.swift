//
//  AuthFlowView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI

struct AuthFlowView: View {
    @Environment(DapurNauraAppRouter.self) private var router

    private let factory: ViewModelFactory

    init(factory: ViewModelFactory) {
        self.factory = factory
    }

    var body: some View {
        NavigationStack {
            LoginView(viewModel: factory.makeLogin()) {
                withAnimation(.snappy) { router.root = .main }
            }
        }
    }
}
