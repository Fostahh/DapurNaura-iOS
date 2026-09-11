//
//  ToastMessage.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import Foundation

/// One thing to say, and how to say it.
///
/// **An optional payload is both the content and the presented state** — the shape `.sheet(item:)`
/// and `.alert(item:)` already use — so the two cannot disagree: there is no `Bool` beside a string
/// that could claim a toast is showing while the text is empty.
///
/// **It carried a `UUID` until 2026-09-12**, from when `Toast` ran the countdown and `.task(id:)`
/// needed a value that changed in order to restart it. `ToastCenter` owns the clock now and
/// restarts it inside `show`, so nothing read the id any more.
struct ToastMessage: Equatable {
    let kind: ToastKind
    let text: String
}
