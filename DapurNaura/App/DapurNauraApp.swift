//
//  DapurNauraApp.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/06/26.
//

import SwiftUI
import DNLibrary

@main
@MainActor
struct DapurNauraApp: App {
    private let factory = ViewModelFactory(dataLayer: DNDataLayer.companion.stub())

    @State private var router = DapurNauraAppRouter()

    @State private var toasts = ToastCenter()

    var body: some Scene {
        WindowGroup {
            RootView(factory: factory)
                .environment(router)
                .environment(toasts)
        }
    }
}
