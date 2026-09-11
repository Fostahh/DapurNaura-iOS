//
//  CookingClassListViewModel.swift
//  DapurNaura
//
//  DN-009 — MVVM: the view renders `state`, and nothing here imports SwiftUI.
//

import Foundation
import DNLibrary

@MainActor
@Observable
final class CookingClassListViewModel {

    enum State {
        case loading
        case loaded([CookingClass])
        case failed(String)
    }

    private(set) var state: State = .loading

    /// The active filter chip. `nil` is *Semua* — every class, in every category — and is
    /// what the screen opens on. Not a fourth `State`: it is what the next load asks for,
    /// and it outlives the load's result.
    private(set) var selectedCategory: CookingClassCategory?

    private let getCookingClasses: GetCookingClassesUseCase

    init(getCookingClasses: GetCookingClassesUseCase) {
        self.getCookingClasses = getCookingClasses
    }

    /// DN-025: the server filters, so choosing a chip is a new request rather than a
    /// predicate over what is already on screen.
    func select(_ category: CookingClassCategory?) async {
        // Owner's revision, 2026-08-08: tapping the chip that is already active costs
        // nothing. What is on screen is already that category's answer, and re-requesting
        // it would replace it with a spinner to arrive at the same list. A failed load has
        // its own Coba Lagi, so this is not the only way back from one.
        guard category != selectedCategory else { return }
        selectedCategory = category
        await load()
    }

    func load() async {
        state = .loading
        // Tapping a second chip mid-flight leaves two requests running. Whichever answers
        // last must not win — only the one the user is still waiting for may write `state`.
        let requested = selectedCategory
        do {
            let result = try await getCookingClasses.invoke(category: requested)
            guard requested == selectedCategory else { return }
            switch onEnum(of: result) {
            case .success(let success):
                state = .loaded(success.classes)
            case .failure(let failure):
                state = .failed(DNErrorKt.userMessage(failure.error))
            }
        } catch is CancellationError {
            // The screen is going away; leave state untouched.
        } catch {
            // The use case returns sealed results, so this should be unreachable.
            // But `state` is already .loading by this point: swallowing the error
            // would strand the screen on a spinner with no retry, which is a worse
            // failure than an honest message.
            guard requested == selectedCategory else { return }
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
