//
//  ToastMessage.swift
//  DapurNaura
//
//  DN-040 — what a caller hands to `Toast`.
//

import Foundation

/// One thing to say, and how to say it.
///
/// **`Identifiable`, and that is the whole reason this type exists** rather than the caller
/// passing a kind and a string beside a `Bool`. The owner asked for a toast that restarts its
/// three seconds when it is triggered again instead of stacking a second one (2026-08-10) — and
/// pressing *Login* twice on the same empty field produces the *same* message, so the text cannot
/// tell the two presses apart. A fresh `id` can, which is what lets `Toast` restart its countdown.
///
/// It is the shape `.sheet(item:)` and `.alert(item:)` already use: an optional payload is both
/// the content and the presented/absent state, so the two cannot disagree.
struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let kind: ToastKind
    let text: String

    init(kind: ToastKind, text: String) {
        self.kind = kind
        self.text = text
    }
}

extension ToastKind: Equatable {}
