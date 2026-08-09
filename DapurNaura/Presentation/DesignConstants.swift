//
//  DesignConstants.swift
//  DapurNaura
//
//  DN-015 — one place for spacing, rounding and tints (ARCHITECTURE §9).
//

import SwiftUI

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

    // DN-033 — the Kelas Online / Kelas Offline cards. The picture is a circle straddling the
    // card's top edge: `classCardImageOverlap` of it rises above the edge, and the rest hangs
    // down inside the card.
    static let classCardCornerRadius: CGFloat = 24
    static let classCardImageSize: CGFloat = 130
    static let classCardImageOverlap: CGFloat = 44
    static let classCardSpacing: CGFloat = 32
    static let classCardPadding: CGFloat = 20

    /// Head room a card reserves above its title, so the text clears the picture.
    ///
    /// **It is the part of the circle hanging *inside* the card, not the part above it.**
    /// Reserving `classCardImageOverlap` instead was the first attempt and the title rendered
    /// underneath the picture — the two numbers are complements, and the wrong one is the
    /// smaller, so the mistake shows as overlap rather than as a gap.
    static var classCardImageHeadRoom: CGFloat {
        classCardImageSize - classCardImageOverlap + rowSpacing
    }

    /// Salmon and pink, from the reference image the owner supplied on 2026-08-09.
    /// Literals rather than an asset catalogue: there is no artwork in this app yet, and two
    /// colours do not justify starting one — §9 only requires that they live in one place.
    static let classCardOnlineTint = Color(red: 0.91, green: 0.63, blue: 0.59)
    static let classCardOfflineTint = Color(red: 0.90, green: 0.50, blue: 0.67)

    // DN-033 — NoticeSheet. The picture is a fixed height so one notice cannot be twice the
    // size of another. The close control draws a 32pt circle inside a 44pt tap target: §9's
    // minimum is about the area a finger can hit, not the size of the visible disc.
    static let noticeImageHeight: CGFloat = 180
    static let noticeSheetCornerRadius: CGFloat = 24
    static let noticeScrimOpacity: Double = 0.35

    // The close control is a rounded square, not a disc — owner's reference, 2026-08-09. It is
    // drawn at the full 44pt tap target, so the thing seen and the thing hit are the same
    // rectangle; the shadow is what lifts it off the sheet behind it.
    static let noticeCloseCornerRadius: CGFloat = 12
    static let noticeCloseShadowRadius: CGFloat = 8
    static let noticeCloseShadowOpacity: Double = 0.15
    static let noticeCloseShadowOffsetY: CGFloat = 2

    /// How far the sheet must be dragged down before letting go dismisses it. Short enough
    /// to feel willing, long enough that a scroll-like flick does not close it by accident.
    static let noticeDismissDragDistance: CGFloat = 120
}
