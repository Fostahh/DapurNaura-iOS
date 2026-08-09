//
//  ClassKindCard.swift
//  DapurNaura
//
//  DN-033 — one of the two cards the app now opens on.
//

import SwiftUI

/// A tinted card with its picture hanging over the top edge, a title and one line
/// beneath it.
///
/// Takes plain values and names no `Route` (§4) — it does not know whether pressing
/// it pushes a screen or raises a sheet, which is exactly why the same card can do
/// both. The caller wraps it in a `NavigationLink(value:)` or a `Button`.
struct ClassKindCard: View {
    let imageURL: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        VStack(spacing: DesignConstants.rowSpacing) {
            Text(title)
                .font(.title2)
                .bold()

            Text(subtitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(DesignConstants.classCardPadding)
        // Clears the part of the circle hanging into the card, so the title starts
        // below the picture rather than behind it.
        .padding(.top, DesignConstants.classCardImageHeadRoom)
        .background(tint, in: .rect(cornerRadius: DesignConstants.classCardCornerRadius))
        .overlay(alignment: .top) {
            RemoteImage(urlString: imageURL, showsProgress: false)
                .frame(
                    width: DesignConstants.classCardImageSize,
                    height: DesignConstants.classCardImageSize
                )
                .clipShape(.circle)
                .offset(y: -DesignConstants.classCardImageOverlap)
        }
        // The offset picture draws outside the card, so the row has to reserve the
        // space itself — layout does not grow to fit an offset view.
        .padding(.top, DesignConstants.classCardImageOverlap)
    }
}

#Preview("Dua kartu") {
    VStack(spacing: DesignConstants.classCardSpacing) {
        ClassKindCard(
            imageURL: "https://placehold.co/300x300/png?text=Kelas+Online",
            title: "Kelas Online",
            subtitle: "Belajar masak dari rumah lewat video dan resep",
            tint: DesignConstants.classCardOnlineTint
        )

        ClassKindCard(
            imageURL: "https://placehold.co/300x300/png?text=Kelas+Offline",
            title: "Kelas Offline",
            subtitle: "Belajar langsung bersama di Dapur Naura",
            tint: DesignConstants.classCardOfflineTint
        )
    }
    .padding()
}
