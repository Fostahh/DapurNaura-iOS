//
//  LoginTextField.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import SwiftUI

/// A rounded grey field with an icon at its leading edge, and — for a password — a control at its
/// trailing edge that reveals what has been typed.
///
/// **The first text input this app has ever had**, so nothing here follows an existing pattern.
///
/// The reveal control is the part with a trap in it. Showing a hidden password means swapping
/// `SecureField` for `TextField`, and the two are different views: SwiftUI tears the first down and
/// builds the second, which drops the keyboard and the cursor. A single `@FocusState` shared by
/// both branches is what carries focus across the swap — and it has to be re-asserted *after* the
/// rebuild, because setting it in the same turn lands on the field that is going away.
struct LoginTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    /// Hides what is typed and adds the reveal control. Off for the email field.
    var isSecure = false

    var textContentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    /// The icon square, growing with the user's text size so the symbols keep pace with the label
    /// beside them rather than shrinking against it (§9, DN-038).
    @ScaledMetric private var iconSize: CGFloat = DesignConstants.loginFieldIconSize

    var body: some View {
        HStack(spacing: DesignConstants.rowGutter) {
            // Drawn to fit one square rather than at the symbol's own size. `envelope.fill` and
            // `lock.fill` share neither a width nor a height, so left to themselves they look like
            // two different sizes and start their placeholders at two different offsets.
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
        // Both fields end up identical because the height is stated here rather than inherited
        // from whatever the tallest child happens to be — which is what made the password field
        // taller than the email one while the reveal button was 44pt tall in its own right.
        .frame(minHeight: DesignConstants.loginFieldMinHeight)
        .background(fill)
    }

    /// The tap lives on the fill rather than on the whole field, so the empty grey either side of
    /// the text still raises the keyboard **without** competing with the reveal button for the
    /// same touch. A gesture on the container would win over the button and the eye would never
    /// fire.
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
                // §9 — the visible glyph is small; the area a finger has to hit is not. **Width is
                // stated, height is filled**: a stated 44pt height would make this the tallest
                // thing in the row and push the whole field past the email field's height. Filling
                // takes the row's own 56pt instead, which is more than 44 either way.
                .frame(width: DesignConstants.minimumTapTarget)
                .frame(maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func toggleReveal() {
        // Read it before the swap: afterwards the field this refers to no longer exists.
        let wasFocused = isFocused
        isRevealed.toggle()

        // A turn later, so the replacement field is the one that takes focus. Only when it already
        // had it — tapping the eye on an idle field should not raise the keyboard.
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
