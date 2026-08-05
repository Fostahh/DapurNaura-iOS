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
                state = .failed(Self.message(for: failure.error))
            }
        } catch {
            // The use case returns sealed results and never throws — only task
            // cancellation lands here, and a cancelled screen has nothing to show.
        }
    }

    private static func message(for error: DNError) -> String {
        switch onEnum(of: error) {
        case .network:
            return "Tidak dapat terhubung. Periksa koneksi internet Anda."
        case .http(let http):
            return "Server sedang bermasalah (kode \(http.status)). Coba lagi nanti."
        case .contract:
            return "Data dari server tidak sesuai. Coba lagi nanti."
        case .unknown:
            return "Terjadi kesalahan. Silakan coba lagi."
        }
    }
}
