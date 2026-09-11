//
//  RecipeDetailViewModel.swift
//  DapurNaura
//
//  DN-021 — MVVM: the view renders `state`, and nothing here imports SwiftUI.
//

import Foundation
import DNLibrary

@MainActor
@Observable
final class RecipeDetailViewModel {

    enum State {
        case loading
        case loaded(Recipe)
        case failed(String)
    }

    private(set) var state: State = .loading

    private let recipeId: String
    private let getRecipe: GetRecipeUseCase

    init(recipeId: String, getRecipe: GetRecipeUseCase) {
        self.recipeId = recipeId
        self.getRecipe = getRecipe
    }

    func load() async {
        state = .loading
        do {
            let result = try await getRecipe.invoke(recipeId: recipeId)
            switch onEnum(of: result) {
            case .success(let success):
                state = .loaded(success.recipe)
            case .failure(let failure):
                state = .failed(DNErrorKt.userMessage(failure.error))
            }
        } catch is CancellationError {
            // The screen is going away; leave state untouched.
        } catch {
            // The use case returns sealed results, so this should be unreachable.
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
