//
//  RouteDestination.swift
//  DapurNaura
//
//  DN-015 — turns a Route value into a screen (ARCHITECTURE §4).
//

import SwiftUI

/// The single place a `Route` becomes a view.
///
/// A `View` struct rather than a `@ViewBuilder` helper, per §3 — a struct can be
/// constructed and previewed on its own; an inlined helper property cannot.
struct RouteDestination: View {
    let route: Route
    let factory: ViewModelFactory

    var body: some View {
        switch route {
        case .classes(.detail(let classId)):
            CookingClassDetailView(
                viewModel: factory.makeCookingClassDetail(classId: classId)
            )

        case .recipes(.detail(let classId, let recipeId)):
            RecipePlaceholderView(
                viewModel: factory.makeRecipePlaceholder(classId: classId, recipeId: recipeId)
            )
        }
    }
}
