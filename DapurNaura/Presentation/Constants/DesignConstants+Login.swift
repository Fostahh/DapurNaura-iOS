//
//  DesignConstants+Login.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import SwiftUI

extension DesignConstants {

    // MARK: - The palette

    static let loginBackground = Color(hex: 0xFFFFFF)
    static let primaryButton = Color(hex: 0xE3A32E)
    static let primaryButtonLabel = Color(hex: 0xFFFFFF)
    static let fieldBackground = Color(hex: 0xEBEBEF)
    static let fieldPlaceholder = Color(hex: 0xA9A9AE)
    static let mutedText = Color(hex: 0x67768A)
    static let emphasisText = Color(hex: 0x1A1A1A)
    static let dividerLine = Color(hex: 0xDCDCE0)

    // MARK: - The login screen

    static let loginHeadingTopFraction: CGFloat = 0.2

    static let loginHorizontalPadding: CGFloat = 24
    static let loginSubtitleTopPadding: CGFloat = 5
    static let loginSubtitleHorizontalPadding: CGFloat = 32
    static let loginFieldsTopPadding: CGFloat = 40
    static let loginFieldSpacing: CGFloat = 16
    static let loginForgotTopPadding: CGFloat = 12
    static let loginForgotBottomPadding: CGFloat = 24
    static let loginFieldCornerRadius: CGFloat = 20

    static let loginFieldIconSize: CGFloat = 20

    static let loginFieldMinHeight: CGFloat = 56

    static let loginDividerTopPadding: CGFloat = 28
    static let loginDividerSpacing: CGFloat = 12
    static let loginSignUpTopPadding: CGFloat = 24
    static let loginBottomPadding: CGFloat = 32

    // MARK: - The toast

    static let toastInset: CGFloat = 8
    static let toastCornerRadius: CGFloat = 12
    static let toastPadding: CGFloat = 16
    static let toastBorderWidth: CGFloat = 1
    static let toastDuration: Duration = .seconds(3)

    static let toastLineHeight: CGFloat = 48

    static func toastTint(for kind: ToastKind) -> Color {
        switch kind {
        case .information: Color(hex: 0xFFFFFF)
        case .success: Color(hex: 0x2E7D32)
        case .error: Color(hex: 0xD32F2F)
        }
    }

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
