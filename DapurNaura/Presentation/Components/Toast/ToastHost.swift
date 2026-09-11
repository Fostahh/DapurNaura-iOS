//
//  ToastHost.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI

/// The one view that reads `ToastCenter`, and the only thing the root overlays.
///
/// **It exists to keep the observation where the drawing is.** With `@Observable`, reading
/// `message` inside a `body` registers that body as a dependency — so reading it in `RootView` made
/// every toast invalidate the app's root, and with it the flow view and the navigation stack
/// underneath. A toast raised while navigating, which is what the payment flow does twice,
/// re-rendered the stack it was navigating.
///
/// One view deep, the same read invalidates one view.
struct ToastHost: View {
    @Environment(ToastCenter.self) private var toasts

    var body: some View {
        Toast(message: toasts.message)
    }
}
