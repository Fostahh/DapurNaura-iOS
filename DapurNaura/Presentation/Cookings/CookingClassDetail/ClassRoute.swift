//
//  ClassRoute.swift
//  DapurNaura
//
//  DN-015 — routes are owned by their destination feature (ARCHITECTURE §4).
//

import Foundation

/// Ways to navigate *into* the cooking-class feature.
///
/// It lives beside `CookingClassDetailView`, the screen it opens — not beside the
/// list that happens to push it today. A route names a destination, so the feature
/// able to satisfy it owns it. Under source-ownership the second screen to push a
/// class detail would have to import the list's vocabulary to do it.
///
/// Carries an id rather than a `CookingClass`: a path of ids stays `Codable`,
/// which is what makes deep links and state restoration possible later.
enum ClassRoute: Hashable {
    case detail(classId: String)
}
