//
//  ViewModelFactory.swift
//  DapurNaura
//
//  DN-015 — the single hand-wired object graph (ARCHITECTURE §5).
//

import Foundation
import DNLibrary

/// Builds every screen's view model.
///
/// `DapurNauraApp` constructs this once and hands it down, so it remains the only
/// place that knows a `DNDataLayer` exists. Views receive the factory, never the
/// data layer and never a use case.
///
/// This replaces the per-screen closures DN-012 introduced. One closure worked;
/// three threaded through intermediate views did not.
@MainActor
struct ViewModelFactory {
    private let dataLayer: DNDataLayer

    init(dataLayer: DNDataLayer) {
        self.dataLayer = dataLayer
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

    func makeOfflineClassSchedule() -> OfflineClassScheduleViewModel {
        OfflineClassScheduleViewModel(
            getOfflineClassSchedule: dataLayer.getOfflineClassSchedule
        )
    }
}
