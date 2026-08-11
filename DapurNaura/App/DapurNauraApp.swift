//
//  DapurNauraApp.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/06/26.
//

import SwiftUI
import DNLibrary

// DN-038: `@MainActor` on the type, because both stored properties below initialise main-actor
// types from a synthesised `init()` that is nonisolated. Swift 5 allows the implicit hop; Swift 6
// makes it an error. An App's `body` is main-actor already, so this only states what was true.
@main
@MainActor
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

    // DN-040: whether this launch has been past the login screen.
    //
    // **Named `hasPassedLogin` rather than `isLoggedIn`, and the name is the point.**
    // Nobody is logged in: no credential was checked, no session exists, no identity
    // is known. The platform defers all of that (owner's decision, 2026-08-06), and a
    // flag called `isLoggedIn` would be the first thing to quietly contradict it —
    // the next screen needing a user would find something that looks like an answer.
    //
    // It is `@State`, so it dies with the process. That is what makes "every launch
    // starts at login" (owner, 2026-08-10) fall out rather than be implemented.
    @State private var hasPassedLogin = false

    var body: some Scene {
        WindowGroup {
            // DN-040: the app opens on login, which cannot be returned to — so the
            // root is swapped rather than pushed. A hidden back button would still
            // leave a back gesture, and login would sit under the app all session.
            //
            // The ZStack exists for the transition: a bare if/else swaps the root
            // between two frames, which reads as the app having glitched rather than
            // moved. Holding both for the duration is what gives them somewhere to
            // move through. The pair below is a push — the app arrives from the
            // trailing edge as login leaves by the leading one.
            ZStack {
                if hasPassedLogin {
                    // DN-033: behind login, the Kelas Online / Kelas Offline choice. It
                    // still owns the NavigationStack and the single navigationDestination.
                    CookingClassSelectionView(factory: factory)
                        .environment(router)
                        .transition(.move(edge: .trailing))
                } else {
                    LoginView(viewModel: factory.makeLogin()) {
                        withAnimation(.snappy) { hasPassedLogin = true }
                    }
                    .transition(.move(edge: .leading))
                }
            }
        }
    }
}
