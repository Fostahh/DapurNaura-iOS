//
//  LoadFailedView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
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
