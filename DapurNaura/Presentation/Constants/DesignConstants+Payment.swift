//
//  DesignConstants+Payment.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI

extension DesignConstants {

    // MARK: - The bank cards

    static let bankMandiriCard = Color(hex: 0x10365F)
    static let bankMandiriAccent = Color(hex: 0xF0C674)
    static let bankMandiriSubdued = Color(hex: 0xC3D2E4)

    static let bankBsiCard = Color(hex: 0x00726C)
    static let bankBsiAccent = Color(hex: 0xE9C784)
    static let bankBsiSubdued = Color(hex: 0xB5D8D5)

    static let bankCardCornerRadius: CGFloat = 20
    static let bankCardPadding: CGFloat = 20
    static let bankCardButtonSize: CGFloat = 44
    static let bankCardButtonCornerRadius: CGFloat = 12

    // MARK: - The proof screen

    static let proofDropzoneCornerRadius: CGFloat = 20
    static let proofDropzoneDash: CGFloat = 2
    static let proofDropzoneMinHeight: CGFloat = 220
    static let proofDropzoneIconSize: CGFloat = 64
    static let proofDropzoneTextSpacing: CGFloat = 6

    static let proofBankStripeWidth: CGFloat = 4
    static let proofBankStripeHeight: CGFloat = 28
    static let proofBankStripeCornerRadius: CGFloat = 2
    static let proofSummaryLabelSpacing: CGFloat = 2

    static let paymentSummaryLabelSpacing: CGFloat = 6

    nonisolated static let proofMaxLongEdge: CGFloat = 1600
    nonisolated static let proofJpegQuality: CGFloat = 0.8
}
