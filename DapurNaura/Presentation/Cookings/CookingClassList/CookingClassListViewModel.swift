//
//  CookingClassListViewModel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
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

    private(set) var selectedCategory: CookingClassCategory?

    private let getCookingClasses: GetCookingClassesUseCase

    init(getCookingClasses: GetCookingClassesUseCase) {
        self.getCookingClasses = getCookingClasses
    }

    func select(_ category: CookingClassCategory?) async {
        guard category != selectedCategory else { return }
        selectedCategory = category
        await load()
    }

    func load() async {
        state = .loading
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
        } catch {
            guard requested == selectedCategory else { return }
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
