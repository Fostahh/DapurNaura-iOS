//
//  DapurNauraApp.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/06/26.
//

import SwiftUI
import DNLibrary

@main
struct DapurNauraApp: App {
    // Composition root. Stub data until a backend exists (DN-009): the library
    // replays the approved contract fixtures through its real decoding path.
    // When the backend arrives, swap to:
    //   DNDataLayer(config: DNNetworkManagerConfig(baseUrl: AppConfig.baseURL,
    //                                              apiKey: AppConfig.apiKey))
    // — and replace the stale API_BASE_URL values in Config/*.xcconfig first.
    //
    // This is the only place that knows a DNDataLayer exists (ARCHITECTURE §5).
    private let factory = ViewModelFactory(dataLayer: DNDataLayer.companion.stub())

    var body: some Scene {
        WindowGroup {
            CookingClassListView(
                viewModel: factory.makeCookingClassList(),
                factory: factory
            )
        }
    }
}
