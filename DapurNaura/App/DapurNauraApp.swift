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
    //   DNDataLayer(config: DNNetworkManagerConfig(baseUrl: DapurNauraAppConfig.baseURL,
    //                                              apiKey: DapurNauraAppConfig.apiKey))
    // — and replace the stale API_BASE_URL values in Config/*.xcconfig first.
    //
    // This is the only place that knows a DNDataLayer exists (ARCHITECTURE §5).
    private let factory = ViewModelFactory(dataLayer: DNDataLayer.companion.stub())

    // The single navigation path (ARCHITECTURE §4). Owned here so there is exactly
    // one, and injected rather than threaded through intermediate screens.
    @State private var router = DapurNauraAppRouter()

    var body: some Scene {
        WindowGroup {
            // DN-033: the app opens on the Kelas Online / Kelas Offline choice. The
            // class list is now pushed from it rather than being the root.
            CookingClassSelectionView(factory: factory)
                .environment(router)
        }
    }
}
