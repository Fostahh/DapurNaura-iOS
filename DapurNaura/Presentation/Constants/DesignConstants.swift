//
//  DesignConstants.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import SwiftUI
import DNLibrary

enum DesignConstants {
    static let sectionSpacing: CGFloat = 16
    static let rowSpacing: CGFloat = 8
    static let rowGutter: CGFloat = 12

    static let cornerRadius: CGFloat = 12
    static let thumbnailCornerRadius: CGFloat = 8

    static let listImageHeight: CGFloat = 160
    static let detailImageHeight: CGFloat = 200
    static let thumbnailSize: CGFloat = 72

    static let quantityColumnWidth: CGFloat = 72
    static let stepNumberWidth: CGFloat = 22

    static let badgeHorizontalPadding: CGFloat = 8
    static let badgeVerticalPadding: CGFloat = 4
    static let badgeTintOpacity: Double = 0.15

    static let chipHorizontalPadding: CGFloat = 14
    static let chipTintOpacity: Double = 0.12
    static let minimumTapTarget: CGFloat = 44

    static let noticePadding: CGFloat = 12
    static let noticeTintOpacity: Double = 0.12
    static let noticeCornerRadius: CGFloat = 10

    static let classCardCornerRadius: CGFloat = 24
    static let classCardImageSize: CGFloat = 130
    static let classCardImageOverlap: CGFloat = 44
    static let classCardSpacing: CGFloat = 32
    static let classCardPadding: CGFloat = 20

    static var classCardImageHeadRoom: CGFloat {
        classCardImageSize - classCardImageOverlap + rowSpacing
    }

    static let classCardOnlineTint = Color(red: 0.91, green: 0.63, blue: 0.59)
    static let classCardOfflineTint = Color(red: 0.90, green: 0.50, blue: 0.67)

    static let noticeImageHeight: CGFloat = 180
    static let noticeSheetCornerRadius: CGFloat = 24
    static let noticeScrimOpacity: Double = 0.35

    static let noticeCloseCornerRadius: CGFloat = 12
    static let noticeCloseShadowRadius: CGFloat = 8
    static let noticeCloseShadowOpacity: Double = 0.15
    static let noticeCloseShadowOffsetY: CGFloat = 2

    static let noticeDismissDragDistance: CGFloat = 120

    static let ticketImageSize: CGFloat = 88
    static let ticketDateColumnWidth: CGFloat = 56
    static let ticketBorderWidth: CGFloat = 1.5
    static let ticketCornerRadius: CGFloat = 16
    static let sectionHeaderSpacing: CGFloat = 6
    static let bulletColumnWidth: CGFloat = 14

    static func availabilityTint(for availability: OfflineClassAvailability) -> Color {
        switch availability {
        case .available: .green
        case .nearlyFull: .orange
        case .full: .red
        }
    }
}
