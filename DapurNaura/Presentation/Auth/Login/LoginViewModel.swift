//
//  LoginViewModel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import Foundation

@MainActor
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""

    func attemptLogin() -> String? {
        emptyFieldComplaint
    }

    private var emptyFieldComplaint: String? {
        let hasEmail = !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPassword = !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        switch (hasEmail, hasPassword) {
        case (true, true): return nil
        case (false, false): return "Email dan password harus diisi."
        case (false, true): return "Email harus diisi."
        case (true, false): return "Password harus diisi."
        }
    }
}
