//
//  ClassRoute.swift
//  DapurNaura
//
//  DN-015 — the cooking-class feature owns its own routes (ARCHITECTURE §4).
//

import Foundation

/// Where the cooking-class feature can navigate to.
///
/// Carries an id rather than a `CookingClass`: a path of ids stays `Codable`,
/// which is what makes deep links and state restoration possible later.
enum ClassRoute: Hashable {
    case detail(classId: String)
}
