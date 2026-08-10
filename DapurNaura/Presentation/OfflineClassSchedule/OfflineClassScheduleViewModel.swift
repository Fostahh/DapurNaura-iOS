//
//  OfflineClassScheduleViewModel.swift
//  DapurNaura
//
//  DN-036 — MVVM: the view renders `state`, and nothing here imports SwiftUI.
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

    /// Which month sections the reader has closed.
    ///
    /// **Held here rather than as `@State` on each section**, so it survives a reload: the screen
    /// refetches on `.task`, and per-section state would silently reopen every section the reader
    /// had just closed.
    ///
    /// Empty is the default, and the requirement wants every section open on arrival — so the
    /// default costs no code.
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

    /// The materials as one string, one bullet to a line, ready for `NoticeSheet.message`.
    ///
    /// **Formatted here rather than inside the sheet** — owner's decision, 2026-08-10: a shared
    /// component should not grow a parameter every time a screen wants to say something in a new
    /// shape. `NoticeSheet` takes a picture and a message, and this screen decides what its message
    /// looks like.
    ///
    /// Built from the list, never from a joined string that is split again: the list is what the
    /// contract sends, and a material containing a comma would not survive a round trip.
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
            // The screen is going away; leave state untouched.
        } catch {
            // The use case returns sealed results, so this should be unreachable. But `state` is
            // already .loading by this point: swallowing the error would strand the screen on a
            // spinner with no retry, which is a worse failure than an honest message.
            state = .failed(DNErrorKt.userMessage(DNErrorUnknown(message: nil)))
        }
    }
}
