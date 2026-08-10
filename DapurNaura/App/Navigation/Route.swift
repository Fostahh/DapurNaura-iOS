//
//  Route.swift
//  DapurNaura
//
//  DN-015 — every destination in the app, as one value type (ARCHITECTURE §4).
//

import Foundation

/// The only type the app registers a `navigationDestination` for.
///
/// Per-feature route enums live in their feature folders and are wrapped here.
/// That keeps each feature owning its own destinations while the navigation path
/// stays a single homogeneous `[Route]` — inspectable, testable and `Codable`.
///
/// Drop this wrapper only when features become separate Swift packages, at which
/// point each package registers its own destination and the path becomes
/// `NavigationPath`. Not when the enum gets long.
enum Route: Hashable {
    case classList(CookingClassListRoute)
    case classes(ClassRoute)
    case recipes(RecipeRoute)
    case offlineClasses(OfflineClassRoute)
}
