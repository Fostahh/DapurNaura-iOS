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

    private let getCookingClasses: GetCookingClassesUseCase

    init(getCookingClasses: GetCookingClassesUseCase) {
        self.getCookingClasses = getCookingClasses
    }

    func load() async {
        state = .loading
        do {
            let result = try await getCookingClasses.invoke()
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
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
