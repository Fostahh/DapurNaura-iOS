//
//  CookingClassSelectionContent.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 09/08/26.
//

import SwiftUI

struct CookingClassSelectionContent: View {
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

                NavigationLink(value: Route.offlineClasses(.schedule)) {
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
        CookingClassSelectionContent()
            .navigationTitle("Dapur Naura")
    }
}
