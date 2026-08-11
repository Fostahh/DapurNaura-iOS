//
//  LoginContent.swift
//  DapurNaura
//
//  DN-040 — the login screen's drawing, from plain values (ARCHITECTURE §3).
//

import SwiftUI

/// Everything the login screen shows, built from two bindings and four closures — so it previews
/// without a ViewModel, a use case or a `DNDataLayer` (§3).
///
/// **The spacing down to the Login button is the owner's (2026-08-10); below it is the agent's** —
/// *"the other below, do as you wish."* All provisional, all in `DesignConstants` (§9).
///
/// The column sits in a `ScrollView`: the heading is placed as a fraction of the screen height, and
/// this is the app's first screen with a keyboard, so a fixed layout would put the password field
/// under it on a small phone. The resting appearance is unchanged.
struct LoginContent: View {
    @Binding var email: String
    @Binding var password: String

    let onLogin: () -> Void
    let onForgotPassword: () -> Void
    let onGoogle: () -> Void
    let onSignUp: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    header
                    fields
                    forgotPassword
                    loginButton
                    divider
                    googleButton
                    signUp
                }
                .frame(maxWidth: .infinity)
                .padding(.top, proxy.size.height * DesignConstants.loginHeadingTopFraction)
                .padding(.bottom, DesignConstants.loginBottomPadding)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(DesignConstants.loginBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 0) {
            Text("Login")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(DesignConstants.emphasisText)

            Text("Baking dan Cooking menjadi mudah dengan belajar di Dapur Naura!")
                .font(.subheadline)
                .foregroundStyle(DesignConstants.mutedText)
                .multilineTextAlignment(.center)
                .padding(.top, DesignConstants.loginSubtitleTopPadding)
                .padding(.horizontal, DesignConstants.loginSubtitleHorizontalPadding)
        }
    }

    private var fields: some View {
        VStack(spacing: DesignConstants.loginFieldSpacing) {
            LoginTextField(
                icon: "envelope.fill",
                placeholder: "email@gmail.com",
                text: $email,
                textContentType: .emailAddress,
                keyboardType: .emailAddress
            )

            LoginTextField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                isSecure: true,
                textContentType: .password
            )
        }
        .padding(.horizontal, DesignConstants.loginHorizontalPadding)
        .padding(.top, DesignConstants.loginFieldsTopPadding)
    }

    /// Trailing-aligned as the design draws it — the owner's *"leading follows the password
    /// textfield"* read as the two sharing margins, not as moving the text left.
    private var forgotPassword: some View {
        Button(action: onForgotPassword) {
            Text("Lupa Password?")
                .font(.subheadline)
                .foregroundStyle(DesignConstants.mutedText)
                .frame(maxWidth: .infinity, minHeight: DesignConstants.minimumTapTarget, alignment: .trailing)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignConstants.loginHorizontalPadding)
        .padding(.top, DesignConstants.loginForgotTopPadding)
        .padding(.bottom, DesignConstants.loginForgotBottomPadding)
    }

    private var loginButton: some View {
        Button(action: onLogin) {
            filledLabel("Login", fill: DesignConstants.primaryButton, tint: DesignConstants.primaryButtonLabel)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignConstants.loginHorizontalPadding)
    }

    /// **No Google mark** — the owner supplies the asset later, so the label is text alone.
    private var googleButton: some View {
        Button(action: onGoogle) {
            filledLabel(
                "Lanjutkan dengan Google",
                fill: DesignConstants.fieldBackground,
                tint: DesignConstants.emphasisText
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignConstants.loginHorizontalPadding)
        .padding(.top, DesignConstants.loginDividerTopPadding)
    }

    private func filledLabel(_ title: String, fill: Color, tint: Color) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(tint)
            .padding(.vertical, DesignConstants.rowSpacing)
            // Same height as the two fields, from the same constant.
            .frame(maxWidth: .infinity, minHeight: DesignConstants.loginFieldMinHeight)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.loginFieldCornerRadius, style: .continuous)
                    .fill(fill)
            )
            .contentShape(.rect)
    }

    private var divider: some View {
        HStack(spacing: DesignConstants.loginDividerSpacing) {
            rule
            Text("Atau")
                .font(.subheadline)
                .foregroundStyle(DesignConstants.mutedText)
            rule
        }
        .padding(.horizontal, DesignConstants.loginHorizontalPadding)
        .padding(.top, DesignConstants.loginDividerTopPadding)
    }

    private var rule: some View {
        Rectangle().fill(DesignConstants.dividerLine).frame(height: 1)
    }

    private var signUp: some View {
        HStack(spacing: DesignConstants.rowSpacing / 2) {
            Text("Belum bikin akun?")
                .foregroundStyle(DesignConstants.mutedText)

            Button(action: onSignUp) {
                Text("Sign up")
                    .bold()
                    .foregroundStyle(DesignConstants.emphasisText)
                    .frame(minHeight: DesignConstants.minimumTapTarget)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .font(.subheadline)
        .padding(.top, DesignConstants.loginSignUpTopPadding)
    }
}

#Preview("Kosong") {
    @Previewable @State var email = ""
    @Previewable @State var password = ""

    LoginContent(
        email: $email,
        password: $password,
        onLogin: {},
        onForgotPassword: {},
        onGoogle: {},
        onSignUp: {}
    )
}

#Preview("Terisi") {
    @Previewable @State var email = "ibu.naura@gmail.com"
    @Previewable @State var password = "rahasia"

    LoginContent(
        email: $email,
        password: $password,
        onLogin: {},
        onForgotPassword: {},
        onGoogle: {},
        onSignUp: {}
    )
}
