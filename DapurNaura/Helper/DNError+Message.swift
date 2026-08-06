//
//  DNError+Message.swift
//  DapurNaura
//
//  DN-012 — lifted out of CookingClassListViewModel now that two screens map errors.
//

import Foundation
import DNLibrary

extension DNError {
    /// One vocabulary for the whole app: the same failure must never be described
    /// two different ways depending on which screen the user happens to be on.
    var indonesianMessage: String {
        switch onEnum(of: self) {
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
