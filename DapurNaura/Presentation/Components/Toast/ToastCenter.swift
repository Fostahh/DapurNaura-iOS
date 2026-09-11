//
//  ToastCenter.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import Foundation

/// The one place a toast is raised from, and the one place its state lives.
///
/// **A toast has to outlive the screen that raises it** (DN-048). Copying an account number says so
/// *and* pushes; sending proof says so *and* pops two levels. Held inside either screen the message
/// dies with the navigation that caused it, and `Toast`'s countdown — a `.task` — is cancelled with
/// the view before it can finish. `RootView` hosts the only `Toast` in the app, above both flows, so
/// a push, a pop and a flow swap all leave it standing.
///
/// **Owner's design, 2026-09-12**, carried over from their UIKit apps: a shared object any screen
/// can call, with the root observing it. In SwiftUI the observing half writes itself — reading
/// `message` inside a `body` *is* the subscription, so there is no emit, no registration and
/// nothing to tear down. That read lives in `ToastHost`, the one view the root overlays, so a toast
/// invalidates that view and not the whole app.
///
/// **It is owned by `DapurNauraApp` and reached through the environment**, the way
/// `DapurNauraAppRouter` is — one way to reach shared state in this app, not two. It was a
/// singleton until the owner's decision of 2026-09-12: a `static let shared` is reachable from
/// anywhere, leaves no seam to substitute one, and made the type the exception to §5's composition
/// root. Injecting it at the App level also costs nothing at render time — that body never reads
/// `message`, so the environment value is written once and never churns.
///
/// **`show` builds the message rather than taking one**, and restarts the clock as it does. That is
/// what makes a second call restart the three seconds instead of stacking a second banner — a rule
/// a caller could otherwise defeat by passing a value it had kept.
///
/// **The clock lives here rather than in the banner.** Owner's decision, 2026-09-12. One timer with
/// one owner: `show` cancels the previous one before starting the next, and `cancel()` sets
/// `isCancelled` synchronously, so even a timer whose sleep has just elapsed sees it before it can
/// touch `message`. A countdown owned by the view could not be called off once elapsed — it had to
/// report *which* message it was clearing, to be checked against what was on screen, and that whole
/// round trip is gone. A message no longer depends on a `Toast` being mounted in order to expire.
///
/// > **Views call this. ViewModels never do**, and `no_toast_in_viewmodel` in `.swiftlint.yml`
/// > enforces it rather than trusting anyone to remember. A ViewModel publishes *what happened* —
/// > usually a string it computed, from validation or from a server — and the View decides that a
/// > toast is how it gets said. Owner's rule, 2026-09-12.
@MainActor
@Observable
final class ToastCenter {

    private(set) var message: ToastMessage?

    private var timer: Task<Void, Never>?

    func show(_ kind: ToastKind, _ text: String) {
        message = ToastMessage(kind: kind, text: text)

        timer?.cancel()
        timer = Task {
            do {
                try await Task.sleep(for: DesignConstants.toastDuration)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }
            message = nil
        }
    }

    /// Takes the message off the screen now, for a caller that knows it is already wrong — as the
    /// login screen does once the fields it complained about are filled.
    func clear() {
        timer?.cancel()
        message = nil
    }
}
