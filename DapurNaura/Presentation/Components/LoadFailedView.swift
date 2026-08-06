//
//  LoadFailedView.swift
//  DapurNaura
//
//  DN-015 — every screen fails the same way (ARCHITECTURE §7).
//

import SwiftUI

/// The failure state, written once.
///
/// Three screens had their own copy of this; the same network problem must not
/// describe itself differently depending on where the user is standing.
struct LoadFailedView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Gagal Memuat", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Coba Lagi", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}
