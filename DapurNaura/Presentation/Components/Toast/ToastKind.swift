//
//  ToastKind.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import Foundation

/// What a toast is telling you. Owner's instruction, 2026-08-10: *"it has 3 state, error,
/// information, and succeed."*
///
/// **The case is `success` where the owner said "succeed".** This is an identifier, not app
/// content — §8 and §10 govern what the user reads, and the user never reads this. Recorded so it
/// does not look like a deviation from the requirement's vocabulary.
///
/// It carries no colour of its own: the palette lives in `DesignConstants`, reached through
/// `toastTint(for:)` and its two companions, for the reason §10 gives — the kind is the
/// vocabulary, the tint is view context.
enum ToastKind {
    case information
    case success
    case error
}
