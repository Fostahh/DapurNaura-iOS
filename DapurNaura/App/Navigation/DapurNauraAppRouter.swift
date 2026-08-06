//
//  DapurNauraAppRouter.swift
//  DapurNaura
//
//  DN-015 — the app's navigation path, owned in one place (ARCHITECTURE §4).
//

import Foundation

/// Owns the navigation path for the whole app.
///
/// Held as `@State` on `DapurNauraApp` and injected with `.environment(_:)`, so
/// exactly one stack exists and any view can reach it without threading bindings
/// through intermediate screens.
///
/// The path is `[Route]` rather than `NavigationPath`: a concrete array stays
/// inspectable and `Codable`, which is what makes deep links and state
/// restoration possible later. Swap to `NavigationPath` only when features become
/// separate Swift packages and each registers its own destination.
///
/// **Deliberately just the array.** `NavigationLink(value:)` appends and the back
/// button removes, so wrapper methods would have no callers — and a `push(_:)`
/// nothing calls is worse than none, because the next screen copies it. Add
/// methods when a caller exists: the purchase flow will need pop-to-root once a
/// completed payment has to unwind however deep the user has gone.
///
/// **A View may push. A ViewModel must not** — a ViewModel has no business knowing
/// screens exist. Where navigation has to follow async work, the View observes the
/// ViewModel's state and pushes; the ViewModel never reaches for the router.
///
/// Sheets and alerts are not routes. They stay `@State` on the view that presents
/// them — see `PurchaseSection`.
///
/// **This is `@Environment(DapurNauraAppRouter.self)`, which is non-optional and
/// traps when absent.** A `#Preview` of any view reading it must inject one:
/// `.environment(DapurNauraAppRouter())`. Previewing the screen's `Content` view
/// instead sidesteps it — see §3.
///
/// **What it earns today is nothing**, and that is recorded rather than hidden:
/// `NavigationLink(value:)` drives navigation and only `NavigationStack` reads
/// `path`. It is here for deep links, state restoration and pop-to-root after
/// payment — scheduled work, cheaper to carry across two screens than to retrofit
/// across five. Not a precedent for adding structure ahead of need.
@MainActor
@Observable
final class DapurNauraAppRouter {
    var path: [Route] = []
}
