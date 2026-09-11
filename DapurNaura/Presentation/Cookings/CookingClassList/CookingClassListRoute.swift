//
//  CookingClassListRoute.swift
//  DapurNaura
//
//  DN-033 — the class list stopped being the root, so it needed a route of its own.
//

import Foundation

/// Ways to navigate *into* the cooking-class list.
///
/// It lives here rather than beside `ClassRoute` because a route is owned by the
/// feature it opens (ARCHITECTURE §4), and `ClassRoute` sits in
/// `CookingClassDetail/` — the folder for the screen it opens, not this one.
///
/// **One case, and that is not an accident.** §4 splits routes per feature and
/// wraps them in `Route`; the wrapper is dropped at module boundaries, not when a
/// case looks small. There is also a concrete second case waiting: the list already
/// filters by category, so a deep link into *Kelas Online, Baking* is
/// `case list(category:)` here, added without touching `Route`.
enum CookingClassListRoute: Hashable {
    case list
}
