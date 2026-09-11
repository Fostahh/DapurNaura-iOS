//
//  OfflineClassRoute.swift
//  DapurNaura
//
//  DN-036 — routes are owned by their destination feature (ARCHITECTURE §4).
//

import Foundation

/// Ways to navigate *into* the offline class schedule.
///
/// One case, for the same reason `CookingClassListRoute` has one: the wrapper is dropped at module
/// boundaries, not when a case looks small. A deep link into a single class — `case detail(id:)` —
/// would be added here without touching `Route`.
enum OfflineClassRoute: Hashable {
    case schedule
}
