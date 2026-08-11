//
//  LoginView.swift
//  DapurNaura
//
//  DN-040 — the app's entry screen, taken over from the Kelas Online / Kelas Offline choice.
//

import SwiftUI

/// The first screen the app shows.
///
/// **It authenticates nobody.** Owner's instruction, 2026-08-10: *"a screen, no API call."* Nothing
/// is sent, checked or stored — any email and any password get in, and the only gate is that
/// neither box is empty. The platform's standing blocker of 2026-08-06 is untouched: there is still
/// no session, no user, no token and no backend, and **nothing here is the beginning of one.**
///
/// **It is not in the navigation stack.** The requirement is that login cannot be returned to
/// (2026-08-10), so `DapurNauraApp` swaps its root rather than pushing — there is no route here, no
/// back button and nothing to suppress. `CookingClassSelectionView` keeps the `NavigationStack` and
/// the app's single `navigationDestination` exactly as DN-033 left them.
///
/// The view holds the notice sheet and hands the toast its clock; everything else it asks
/// `LoginViewModel`. Sheets are not routes and stay `@State` here (§4).
struct LoginView: View {
    @State private var viewModel: LoginViewModel

    /// Called once both boxes are filled and Login is pressed. Nothing is verified first.
    private let onLogin: () -> Void

    @State private var noticeShown = false

    init(viewModel: LoginViewModel, onLogin: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onLogin = onLogin
    }

    var body: some View {
        LoginContent(
            email: $viewModel.email,
            password: $viewModel.password,
            onLogin: { if viewModel.attemptLogin() { onLogin() } },
            onForgotPassword: { noticeShown = true },
            onGoogle: { noticeShown = true },
            onSignUp: { noticeShown = true }
        )
        .overlay(alignment: .top) {
            Toast(message: viewModel.toast, onDismiss: viewModel.dismissToast)
        }
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
}

#Preview {
    LoginView(viewModel: LoginViewModel(), onLogin: {})
}
