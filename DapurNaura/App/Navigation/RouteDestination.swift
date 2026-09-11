//
//  RouteDestination.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI

struct RouteDestination: View {
    let route: Route
    let factory: ViewModelFactory

    var body: some View {
        switch route {
        case .classList(.list):
            CookingClassListView(viewModel: factory.makeCookingClassList())

        case .classes(.detail(let classId)):
            CookingClassDetailView(
                viewModel: factory.makeCookingClassDetail(classId: classId)
            )

        case .offlineClasses(.schedule):
            OfflineClassScheduleView(viewModel: factory.makeOfflineClassSchedule())

        case .recipes(.detail(_, let recipeId)):
            RecipeDetailView(viewModel: factory.makeRecipeDetail(recipeId: recipeId))
        }
    }
}
