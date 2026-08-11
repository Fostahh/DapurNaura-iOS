//
//  DesignConstants+Login.swift
//  DapurNaura
//
//  DN-040 — the colour palette, and the login screen's and toast's measurements.
//

import SwiftUI

/// **The same `DesignConstants`, in a second file.** Owner's instruction, 2026-08-10, was that
/// colours live in the existing place rather than a new type — *"use the existing place to store
/// colorpallete, FOR NOW ya"* — and they do: this is an extension, so every call site still reads
/// `DesignConstants.primaryButton` and nothing was renamed or moved out of the namespace.
///
/// It is split only because DN-040 took the one file past SwiftLint's 200-line limit, which the
/// repo holds at zero violations. The alternative was cutting comments that carry the owner's
/// decisions, which is the wrong thing to spend for a line count.
extension DesignConstants {

    // MARK: - The palette

    /// **Matched by eye from the supplied design and expected to change** — *"the color, for now
    /// you decide, after i tested it later, i will decide."* The DN-033 card tints stay in the
    /// main file as literals: a reviewed decision, and rewriting them risks a change for no gain.
    static let loginBackground = Color(hex: 0xFFFFFF)
    static let primaryButton = Color(hex: 0xE3A32E)
    static let primaryButtonLabel = Color(hex: 0xFFFFFF)
    static let fieldBackground = Color(hex: 0xEBEBEF)
    static let fieldPlaceholder = Color(hex: 0xA9A9AE)
    static let mutedText = Color(hex: 0x67768A)
    static let emphasisText = Color(hex: 0x1A1A1A)
    static let dividerLine = Color(hex: 0xDCDCE0)

    // MARK: - The login screen

    /// Owner's *"0.3 from the center vertical"* — three tenths **above** the middle, so 0.2 down.
    static let loginHeadingTopFraction: CGFloat = 0.2

    static let loginHorizontalPadding: CGFloat = 24
    static let loginSubtitleTopPadding: CGFloat = 5
    static let loginSubtitleHorizontalPadding: CGFloat = 32
    static let loginFieldsTopPadding: CGFloat = 40
    static let loginFieldSpacing: CGFloat = 16
    static let loginForgotTopPadding: CGFloat = 12
    static let loginForgotBottomPadding: CGFloat = 24
    static let loginFieldCornerRadius: CGFloat = 20

    /// **The icon square — both symbols are drawn to fit it, so they are the same size and the two
    /// placeholders start at the same offset.** SF Symbols do not share a size: `envelope.fill` is
    /// wide and short, `lock.fill` is narrow and tall, so both their own widths *and* their heights
    /// differ. Fitting each into one square settles all of it at once.
    ///
    /// Applied through `@ScaledMetric`, so the icons still grow with the user's text size the way
    /// the labels beside them do (§9, DN-038).
    static let loginFieldIconSize: CGFloat = 20

    /// **Both fields and both buttons are this tall, by construction rather than by coincidence.**
    /// The password field was taller than the email field until the reveal button stopped driving
    /// the row height. A `minHeight`, not a height: at large text sizes the content still wins.
    static let loginFieldMinHeight: CGFloat = 56

    /// From the divider down these are the agent's — *"the other below, do as you wish."*
    static let loginDividerTopPadding: CGFloat = 28
    static let loginDividerSpacing: CGFloat = 12
    static let loginSignUpTopPadding: CGFloat = 24
    static let loginBottomPadding: CGFloat = 32

    // MARK: - The toast

    /// Inset from the top, leading and trailing edges — owner's number, 2026-08-10. Applied inside
    /// the safe area, so it clears the Dynamic Island where there is one and the status bar where
    /// there is not. `toastDuration` is the owner's too.
    static let toastInset: CGFloat = 8
    static let toastCornerRadius: CGFloat = 12
    static let toastPadding: CGFloat = 16
    static let toastBorderWidth: CGFloat = 1
    static let toastDuration: Duration = .seconds(3)

    /// **Height per line of message.** Owner's decision, 2026-08-10: 40 for one line, and a
    /// multiple of it for a message that wraps — so two lines is exactly 80, not "however tall the
    /// text turned out". `Toast` counts the lines and multiplies.
    static let toastLineHeight: CGFloat = 48

    /// Functions rather than loose constants for the reason `availabilityTint(for:)` gives: the
    /// mapping *is* the decision, and a tint is view context (§10).
    static func toastTint(for kind: ToastKind) -> Color {
        switch kind {
        case .information: Color(hex: 0xFFFFFF)
        case .success: Color(hex: 0x2E7D32)
        case .error: Color(hex: 0xD32F2F)
        }
    }

    /// Every kind is outlined — owner's decision, 2026-08-10. It exists because the white kind
    /// would otherwise vanish on the login screen, which is itself white; all three carry it so the
    /// three read as one component rather than as two designs.
    static func toastBorderTint(for kind: ToastKind) -> Color {
        switch kind {
        case .information: Color(hex: 0xD0D0D5)
        case .success: Color(hex: 0x1B5E20)
        case .error: Color(hex: 0x9A2020)
        }
    }

    static func toastLabelTint(for kind: ToastKind) -> Color {
        switch kind {
        case .information: Color(hex: 0x1A1A1A)
        case .success, .error: Color(hex: 0xFFFFFF)
        }
    }
}

/// **Deliberately `private` to this file.** An initialiser a view could reach is an invitation to
/// scatter hex literals through the presentation layer — the thing §9 forbids. Nothing outside this
/// file has business building a colour from a number, so the constraint costs nothing.
private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
