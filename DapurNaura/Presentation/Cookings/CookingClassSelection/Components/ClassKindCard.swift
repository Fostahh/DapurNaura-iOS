//
//  ClassKindCard.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 09/08/26.
//

import SwiftUI

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
