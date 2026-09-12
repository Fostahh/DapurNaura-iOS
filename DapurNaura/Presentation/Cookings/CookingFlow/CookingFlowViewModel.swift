//
//  CookingFlowViewModel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import Foundation
import DNLibrary

@MainActor
@Observable
final class CookingFlowViewModel {

    enum State {
        case loading
        case loaded(Recipe)
        case failed(String)
    }

    static let pageCount = 3

    private(set) var state: State = .loading
    private(set) var pageIndex = 0
    private(set) var ticked: Set<TickKey> = []

    private let recipeId: String
    private let getRecipe: GetRecipeUseCase
    private let getProgress: GetRecipeProgressUseCase
    private let saveProgress: SaveRecipeProgressUseCase
    private let clearProgress: ClearRecipeProgressUseCase

    init(
        recipeId: String,
        getRecipe: GetRecipeUseCase,
        getProgress: GetRecipeProgressUseCase,
        saveProgress: SaveRecipeProgressUseCase,
        clearProgress: ClearRecipeProgressUseCase
    ) {
        self.recipeId = recipeId
        self.getRecipe = getRecipe
        self.getProgress = getProgress
        self.saveProgress = saveProgress
        self.clearProgress = clearProgress
    }

    struct TickKey: Hashable {
        let componentIndex: Int
        let ingredientName: String
    }

    func load() async {
        state = .loading
        do {
            let result = try await getRecipe.invoke(recipeId: recipeId)
            switch onEnum(of: result) {
            case .success(let success):
                state = .loaded(success.recipe)
                await restoreProgress()
            case .failure(let failure):
                state = .failed(DNErrorKt.userMessage(failure.error))
            }
        } catch is CancellationError {
        } catch {
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }

    func isTicked(componentIndex: Int, ingredientName: String) -> Bool {
        ticked.contains(TickKey(componentIndex: componentIndex, ingredientName: ingredientName))
    }

    func toggle(componentIndex: Int, ingredientName: String) {
        let key = TickKey(componentIndex: componentIndex, ingredientName: ingredientName)
        if ticked.contains(key) {
            ticked.remove(key)
        } else {
            ticked.insert(key)
        }
        persist()
    }

    func advance() {
        guard pageIndex < Self.pageCount - 1 else { return }
        pageIndex += 1
        persist()
    }

    func goBack() {
        guard pageIndex > 0 else { return }
        pageIndex -= 1
        persist()
    }

    /// Forgets the stored progress. The visible reset is [resetToFirstPage], so the caller can
    /// animate the page swap without wrapping an `await`.
    func clearStoredProgress() async {
        _ = try? await clearProgress.invoke(recipeId: recipeId)
    }

    func resetToFirstPage() {
        ticked = []
        pageIndex = 0
    }

    private func restoreProgress() async {
        guard let result = try? await getProgress.invoke(recipeId: recipeId) else { return }
        guard case .success(let success) = onEnum(of: result) else { return }

        ticked = Set(
            success.progress.tickedIngredients.map {
                TickKey(
                    componentIndex: Int($0.componentIndex),
                    ingredientName: $0.ingredientName
                )
            }
        )
        pageIndex = min(Int(success.progress.pageIndex), Self.pageCount - 1)
    }

    private func persist() {
        let progress = RecipeProgress(
            tickedIngredients: Set(
                ticked.map {
                    RecipeIngredientRef(
                        componentIndex: Int32($0.componentIndex),
                        ingredientName: $0.ingredientName
                    )
                }
            ),
            pageIndex: Int32(pageIndex)
        )
        Task { _ = try? await saveProgress.invoke(recipeId: recipeId, progress: progress) }
    }
}
