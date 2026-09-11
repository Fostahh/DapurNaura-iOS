//
//  CookingClassDetailViewModel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
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
        } catch {
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
