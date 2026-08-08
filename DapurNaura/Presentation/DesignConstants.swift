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

    // DN-021 — the recipe method reads as two aligned columns: quantity beside ingredient,
    // number beside step. Fixed widths so the text lines up down the page rather than
    // stepping in and out with each row's length.
    static let quantityColumnWidth: CGFloat = 72
    static let stepNumberWidth: CGFloat = 22

    static let badgeHorizontalPadding: CGFloat = 8
    static let badgeVerticalPadding: CGFloat = 4
    static let badgeTintOpacity: Double = 0.15

    // DN-025 — the category filter chips. Height comes from §9's 44pt tap target rather than
    // from vertical padding, so a chip stays tappable at every text size.
    static let chipHorizontalPadding: CGFloat = 14
    static let chipTintOpacity: Double = 0.12
    static let minimumTapTarget: CGFloat = 44

    static let noticePadding: CGFloat = 12
    static let noticeTintOpacity: Double = 0.12
    static let noticeCornerRadius: CGFloat = 10
}
