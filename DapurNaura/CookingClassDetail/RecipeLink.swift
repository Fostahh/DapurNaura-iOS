//
//  RecipeLink.swift
//  DapurNaura
//
//  DN-015 — extracted out of CookingClassDetailView (ARCHITECTURE §3, §4).
//

import SwiftUI
import DNLibrary

/// Recipes open only in a class the user has bought. In every other state the row
/// is inert — and the ingredients, method and video are not merely hidden here,
/// they were never sent by the server.
struct RecipeLink: View {
    let recipe: RecipeSummary
    let classId: String
    let openable: Bool

    var body: some View {
        if openable {
            // DN-015: value-based, matching the list screen. This was a closure-based
            // NavigationLink, which cannot share a NavigationStack with value-based
            // links — SwiftUI loses destinations when both are present.
            NavigationLink(
                value: Route.recipes(.detail(classId: classId, recipeId: recipe.id))
            ) {
                RecipeRow(recipe: recipe, openable: true)
            }
            .buttonStyle(.plain)
        } else {
            RecipeRow(recipe: recipe, openable: false)
        }
    }
}
