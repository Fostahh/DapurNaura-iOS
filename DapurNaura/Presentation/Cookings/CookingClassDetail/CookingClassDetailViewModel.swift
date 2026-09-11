//
//  CookingClassDetailViewModel.swift
//  DapurNaura
//
//  DN-012 — MVVM: the view renders `state`, and nothing here imports SwiftUI.
//

import Foundation
import DNLibrary

@MainActor
@Observable
final class CookingClassDetailViewModel {

    enum State {
        case loading
        case loaded(CookingClassDetail)
        case failed(String)
    }

    private(set) var state: State = .loading

    private let classId: String
    private let getCookingClassDetail: GetCookingClassDetailUseCase

    init(classId: String, getCookingClassDetail: GetCookingClassDetailUseCase) {
        self.classId = classId
        self.getCookingClassDetail = getCookingClassDetail
    }

    func load() async {
        state = .loading
        do {
            let result = try await getCookingClassDetail.invoke(classId: classId)
            switch onEnum(of: result) {
            case .success(let success):
                state = .loaded(success.detail)
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
