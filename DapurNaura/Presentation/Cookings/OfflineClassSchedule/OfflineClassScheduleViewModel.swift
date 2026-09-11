//
//  OfflineClassScheduleViewModel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/08/26.
//

import Foundation
import DNLibrary

@MainActor
@Observable
final class OfflineClassScheduleViewModel {

    enum State {
        case loading
        case loaded([OfflineClassMonth])
        case failed(String)
    }

    private(set) var state: State = .loading

    private(set) var collapsedMonths: Set<String> = []

    private let getOfflineClassSchedule: GetOfflineClassScheduleUseCase

    init(getOfflineClassSchedule: GetOfflineClassScheduleUseCase) {
        self.getOfflineClassSchedule = getOfflineClassSchedule
    }

    func isCollapsed(_ monthID: String) -> Bool {
        collapsedMonths.contains(monthID)
    }

    func toggle(_ monthID: String) {
        if collapsedMonths.contains(monthID) {
            collapsedMonths.remove(monthID)
        } else {
            collapsedMonths.insert(monthID)
        }
    }

    func materialsText(for offlineClass: OfflineClass) -> String {
        offlineClass.materials
            .map { "• \($0)" }
            .joined(separator: "\n")
    }

    func load() async {
        state = .loading
        do {
            let result = try await getOfflineClassSchedule.invoke()
            switch onEnum(of: result) {
            case .success(let success):
                state = .loaded(success.months)
            case .failure(let failure):
                state = .failed(DNErrorKt.userMessage(failure.error))
            }
        } catch is CancellationError {
        } catch {
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
