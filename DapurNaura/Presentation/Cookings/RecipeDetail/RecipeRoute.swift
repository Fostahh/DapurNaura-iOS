//
//  RecipeRoute.swift
//  DapurNaura
//
//  DN-015 — routes are owned by their destination feature (ARCHITECTURE §4).
//

import Foundation

/// Ways to navigate *into* the recipe feature.
///
/// Lives beside the recipe screen it opens, not beside the class detail that
/// pushes it — see `ClassRoute` for why destination-ownership is the rule.
///
/// Both ids travel, because a recipe is only reachable through the class that
/// teaches it — and the destination needs the class to resolve the recipe.
enum RecipeRoute: Hashable {
    case detail(classId: String, recipeId: String)
}
