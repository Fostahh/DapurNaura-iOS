//
//  Color+Hex.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI

/// A colour written the way a design tool hands it over.
///
/// **Shared, so it sits here rather than beside the constants that use it.** It was private to
/// `DesignConstants+Login` until DN-048 gave it a second consumer in the payment palette, and §3's
/// rule is that `Constants/` holds `DesignConstants` and its extensions — nothing else.
///
/// The app is pinned to light mode in all four configurations, which is what makes a fixed sRGB
/// value safe here: there is no dark appearance for it to fail to answer.
extension Color {
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
