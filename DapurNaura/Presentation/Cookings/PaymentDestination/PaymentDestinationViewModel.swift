//
//  PaymentDestinationViewModel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import Foundation
import DNLibrary

@MainActor
@Observable
final class PaymentDestinationViewModel {

    enum State {
        case loading
        case loaded([PaymentDestination])
        case failed(String)
    }

    private(set) var state: State = .loading

    private let getPaymentDestinations: GetPaymentDestinationsUseCase

    init(getPaymentDestinations: GetPaymentDestinationsUseCase) {
        self.getPaymentDestinations = getPaymentDestinations
    }

    func load() async {
        state = .loading
        do {
            let result = try await getPaymentDestinations.invoke()
            switch onEnum(of: result) {
            case .success(let success):
                state = .loaded(success.destinations)
            case .failure(let failure):
                state = .failed(DNErrorKt.userMessage(failure.error))
            }
        } catch is CancellationError {
        } catch {
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
