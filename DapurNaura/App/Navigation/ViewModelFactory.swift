//
//  ViewModelFactory.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import Foundation
import DNLibrary

@MainActor
struct ViewModelFactory {
    private let dataLayer: DNDataLayer

    init(dataLayer: DNDataLayer) {
        self.dataLayer = dataLayer
    }

    func makeLogin() -> LoginViewModel {
        LoginViewModel()
    }

    func makeCookingClassList() -> CookingClassListViewModel {
        CookingClassListViewModel(getCookingClasses: dataLayer.getCookingClasses)
    }

    func makeCookingClassDetail(classId: String) -> CookingClassDetailViewModel {
        CookingClassDetailViewModel(
            classId: classId,
            getCookingClassDetail: dataLayer.getCookingClassDetail
        )
    }

    func makeRecipeDetail(recipeId: String) -> RecipeDetailViewModel {
        RecipeDetailViewModel(recipeId: recipeId, getRecipe: dataLayer.getRecipe)
    }

    func makePaymentDestination() -> PaymentDestinationViewModel {
        PaymentDestinationViewModel(getPaymentDestinations: dataLayer.getPaymentDestinations)
    }

    func makeOfflineClassSchedule() -> OfflineClassScheduleViewModel {
        OfflineClassScheduleViewModel(
            getOfflineClassSchedule: dataLayer.getOfflineClassSchedule
        )
    }
}
