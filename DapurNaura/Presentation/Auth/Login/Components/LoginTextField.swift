//
//  LoginTextField.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import SwiftUI

struct LoginTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var isSecure = false

    var textContentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    @ScaledMetric private var iconSize: CGFloat = DesignConstants.loginFieldIconSize

    var body: some View {
        HStack(spacing: DesignConstants.rowGutter) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(DesignConstants.fieldPlaceholder)

            field

            if isSecure {
                revealButton
            }
        }
        .padding(.horizontal, DesignConstants.sectionSpacing)
        .padding(.vertical, DesignConstants.rowSpacing)
        .frame(minHeight: DesignConstants.loginFieldMinHeight)
        .background(fill)
    }

    private var fill: some View {
        RoundedRectangle(cornerRadius: DesignConstants.loginFieldCornerRadius, style: .continuous)
            .fill(DesignConstants.fieldBackground)
            .onTapGesture { isFocused = true }
    }

    @ViewBuilder
    private var field: some View {
        let prompt = Text(placeholder).foregroundStyle(DesignConstants.fieldPlaceholder)

        if isSecure && !isRevealed {
            SecureField("", text: $text, prompt: prompt)
                .textContentType(textContentType)
                .focused($isFocused)
        } else {
            TextField("", text: $text, prompt: prompt)
                .textContentType(textContentType)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isFocused)
        }
    }

    private var revealButton: some View {
        Button(action: toggleReveal) {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
                .foregroundStyle(DesignConstants.fieldPlaceholder)
                .frame(width: DesignConstants.minimumTapTarget)
                .frame(maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func toggleReveal() {
        let wasFocused = isFocused
        isRevealed.toggle()

        if wasFocused {
            Task { isFocused = true }
        }
    }
}

#Preview("Email") {
    @Previewable @State var email = ""

    LoginTextField(
        icon: "envelope.fill",
        placeholder: "email@gmail.com",
        text: $email,
        textContentType: .emailAddress,
        keyboardType: .emailAddress
    )
    .padding()
}

#Preview("Password") {
    @Previewable @State var password = "rahasia"

    LoginTextField(
        icon: "lock.fill",
        placeholder: "Password",
        text: $password,
        isSecure: true,
        textContentType: .password
    )
    .padding()
}
