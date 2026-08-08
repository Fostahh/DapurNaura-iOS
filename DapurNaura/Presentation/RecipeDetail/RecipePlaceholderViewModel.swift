//
//  RecipePlaceholderViewModel.swift
//  DapurNaura
//
//  DN-015 — TEMPORARY, and replaced wholesale by the real recipe screen.
//

import Foundation
import DNLibrary

/// Resolves one recipe out of the class that teaches it.
///
/// This exists because §4 puts **ids** in the navigation path, never model
/// objects — so the destination receives `(classId, recipeId)` and has to look the
/// recipe up rather than being handed it. The real recipe screen will fetch its own
/// data too, so this is the shape that survives; only the rendering is throwaway.
@MainActor
@Observable
final class RecipePlaceholderViewModel {

    enum State {
        case loading
        case loaded(RecipeSummary)
        case failed(String)
    }

    private(set) var state: State = .loading

    private let classId: String
    private let recipeId: String
    private let getCookingClassDetail: GetCookingClassDetailUseCase

    init(classId: String, recipeId: String, getCookingClassDetail: GetCookingClassDetailUseCase) {
        self.classId = classId
        self.recipeId = recipeId
        self.getCookingClassDetail = getCookingClassDetail
    }

    func load() async {
        state = .loading
        do {
            let result = try await getCookingClassDetail.invoke(classId: classId)
            switch onEnum(of: result) {
            case .success(let success):
                if let recipe = success.detail.recipes.first(where: { $0.id == recipeId }) {
                    state = .loaded(recipe)
                } else {
                    // Reachable only if the class changed under us between screens.
                    state = .failed("Resep tidak ditemukan.")
                }
            case .failure(let failure):
                state = .failed(DNErrorKt.userMessage(failure.error))
            }
        } catch is CancellationError {
            // The screen is going away; leave state untouched.
        } catch {
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
