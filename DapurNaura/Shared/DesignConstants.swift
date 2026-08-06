//
//  DesignConstants.swift
//  DapurNaura
//
//  DN-015 — one place for spacing, rounding and tints (ARCHITECTURE §9).
//

import Foundation

/// Shared layout values, so two screens cannot drift apart and a third does not
/// have to guess. Fonts are deliberately absent: §9 requires semantic fonts
/// (`.headline`, `.subheadline`, `.caption`), which are named, not numbers.
enum DesignConstants {
    static let sectionSpacing: CGFloat = 16
    static let rowSpacing: CGFloat = 8
    static let rowGutter: CGFloat = 12

    static let cornerRadius: CGFloat = 12
    static let thumbnailCornerRadius: CGFloat = 8

    static let listImageHeight: CGFloat = 160
    static let detailImageHeight: CGFloat = 200
    static let thumbnailSize: CGFloat = 72

    static let badgeHorizontalPadding: CGFloat = 8
    static let badgeVerticalPadding: CGFloat = 4
    static let badgeTintOpacity: Double = 0.15

    static let noticePadding: CGFloat = 12
    static let noticeTintOpacity: Double = 0.12
    static let noticeCornerRadius: CGFloat = 10
}
