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
        case .classList(.list):
            // DN-033: the list used to be the root and owned the stack. It is now
            // pushed from the Kelas Online / Kelas Offline choice like any other screen.
            CookingClassListView(viewModel: factory.makeCookingClassList())

        case .classes(.detail(let classId)):
            CookingClassDetailView(
                viewModel: factory.makeCookingClassDetail(classId: classId)
            )

        case .recipes(.detail(_, let recipeId)):
            // DN-021: the recipe is fetched by its own id. classId still travels in the route
            // because a recipe is only reachable through the class that teaches it, and a deep
            // link has to be able to prove that path.
            RecipeDetailView(viewModel: factory.makeRecipeDetail(recipeId: recipeId))
        }
    }
}
