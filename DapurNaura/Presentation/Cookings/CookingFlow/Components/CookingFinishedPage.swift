//
//  CookingFinishedPage.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI

struct CookingFinishedPage: View {
    @ScaledMetric(relativeTo: .largeTitle) private var celebrationSize = DesignConstants.celebrationIconSize

    let recipeName: String
    let onRestart: () -> Void
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: DesignConstants.sectionSpacing) {
            Spacer(minLength: 0)

            Image(systemName: "party.popper.fill")
                .resizable()
                .scaledToFit()
                .frame(width: celebrationSize, height: celebrationSize)
                .foregroundStyle(Color.accentColor)

            VStack(spacing: DesignConstants.rowSpacing) {
                Text("Selamat!")
                    .font(.largeTitle.bold())

                Text("Anda sudah selesai membuat")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(recipeName)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 0)

            VStack(spacing: DesignConstants.rowSpacing) {
                Button(action: onFinish) {
                    Text("Selesai").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: onRestart) {
                    Text("Ulangi").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .multilineTextAlignment(.center)
        .padding(DesignConstants.sectionSpacing)
    }
}

#Preview {
    CookingFinishedPage(
        recipeName: "Brownies Red Velvet Cheese & Original Cheese",
        onRestart: {},
        onFinish: {}
    )
}
