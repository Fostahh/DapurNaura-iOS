//
//  RecipeRoute.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import Foundation

enum RecipeRoute: Hashable {
    case detail(classId: String, recipeId: String)
    case cook(recipeId: String)
}
