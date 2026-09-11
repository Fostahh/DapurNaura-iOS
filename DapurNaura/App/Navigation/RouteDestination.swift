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

        case .payment(.destination(let classId, let className, let price)):
            PaymentDestinationView(
                viewModel: factory.makePaymentDestination(),
                classId: classId,
                className: className,
                price: price
            )

        case .payment(.proof(_, let className, let price, let bank, let accountNumber)):
            PaymentProofView(
                className: className,
                price: price,
                bank: bank,
                accountNumber: accountNumber
            )
        }
    }
}
