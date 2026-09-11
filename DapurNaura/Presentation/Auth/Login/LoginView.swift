//
//  LoginView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(ToastCenter.self) private var toasts

    @State private var viewModel: LoginViewModel

    private let onLogin: () -> Void

    @State private var noticeShown = false

    init(viewModel: LoginViewModel, onLogin: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onLogin = onLogin
    }

    private static let keyboardDismissal = Duration.milliseconds(250)

    var body: some View {
        LoginContent(
            email: $viewModel.email,
            password: $viewModel.password,
            onLogin: submit,
            onForgotPassword: { noticeShown = true },
            onGoogle: { noticeShown = true },
            onSignUp: { noticeShown = true }
        )
        .overlay {
            NoticeSheet(
                isPresented: $noticeShown,
                imageURL: "https://placehold.co/600x400/png?text=Segera+Hadir",
                title: "Segera Hadir",
                message: "Fitur ini sedang kami siapkan. Mohon ditunggu, ya.",
                allowsDragToDismiss: false
            )
        }
    }

    private func submit() {
        if let complaint = viewModel.attemptLogin() {
            toasts.show(.error, complaint)
            return
        }

        toasts.clear()

        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )

        Task {
            try? await Task.sleep(for: Self.keyboardDismissal)
            onLogin()
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(), onLogin: {})
        .environment(ToastCenter())
}
