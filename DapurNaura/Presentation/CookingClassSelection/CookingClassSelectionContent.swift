//
//  CookingClassSelectionContent.swift
//  DapurNaura
//
//  DN-033 — the two choices, buildable from nothing (ARCHITECTURE §3).
//

import SwiftUI

/// The Kelas Online / Kelas Offline choice.
///
/// **The two cards are written out, not iterated.** A `ClassKind` enum carrying
/// Indonesian labels would be a domain enum worded in Swift, which is what DN-026
/// took out of `PurchaseStatusBadge`. These are not two values of one type — they
/// are two things that do two different things, and a two-element array plus a
/// `switch` to decide which is longer than both branches written plainly.
///
/// Screen level, so it may name `Route` (§3). `ClassKindCard` may not.
struct CookingClassSelectionContent: View {
    let onSelectOffline: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DesignConstants.classCardSpacing) {
                NavigationLink(value: Route.classList(.list)) {
                    ClassKindCard(
                        imageURL: "https://placehold.co/300x300/png?text=Kelas+Online",
                        title: "Kelas Online",
                        subtitle: "Belajar masak dari rumah lewat video dan resep",
                        tint: DesignConstants.classCardOnlineTint
                    )
                }
                .buttonStyle(.plain)

                // Kelas Offline is not dimmed, disabled or badged "coming soon" —
                // owner's decision, 2026-08-09. Pressing it is answered by the sheet.
                Button(action: onSelectOffline) {
                    ClassKindCard(
                        imageURL: "https://placehold.co/300x300/png?text=Kelas+Offline",
                        title: "Kelas Offline",
                        subtitle: "Belajar langsung bersama di Dapur Naura",
                        tint: DesignConstants.classCardOfflineTint
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DesignConstants.sectionSpacing)
            .padding(.bottom, DesignConstants.sectionSpacing)
        }
    }
}

#Preview {
    NavigationStack {
        CookingClassSelectionContent(onSelectOffline: {})
            .navigationTitle("Dapur Naura")
    }
}
