//
//  RecipeRoute.swift
//  DapurNaura
//
//  DN-015 — the recipe feature owns its own routes (ARCHITECTURE §4).
//

import Foundation

/// Where the recipe feature can navigate to.
///
/// Both ids travel, because a recipe is only reachable through the class that
/// teaches it — and the destination needs the class to resolve the recipe.
enum RecipeRoute: Hashable {
    case detail(classId: String, recipeId: String)
}
