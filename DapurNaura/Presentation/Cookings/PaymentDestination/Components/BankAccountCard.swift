//
//  BankAccountCard.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI
import DNLibrary

struct BankAccountCard: View {
    let destination: PaymentDestination
    let onCopy: () -> Void

    private var brand: BankBrand { BankBrand(destination) }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.sectionSpacing - 2) {
            HStack(spacing: DesignConstants.rowGutter) {
                Text(BankAppearance.name(brand).uppercased())
                    .font(.caption)
                    .bold()
                    .kerning(1.2)
                    .foregroundStyle(BankAppearance.accent(brand))
                    .frame(maxWidth: .infinity, alignment: .leading)
                copyButton
            }

            VStack(alignment: .leading, spacing: DesignConstants.rowSpacing - 2) {
                Text(destination.accountNumber)
                    .font(.title2)
                    .bold()
                    .kerning(0.8)
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("a.n. \(destination.accountHolderName)")
                    .font(.subheadline)
                    .foregroundStyle(BankAppearance.subdued(brand))
            }
        }
        .padding(DesignConstants.bankCardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            BankAppearance.card(brand),
            in: .rect(cornerRadius: DesignConstants.bankCardCornerRadius)
        )
    }

    private var copyButton: some View {
        Button(action: onCopy) {
            Image(systemName: "doc.on.doc")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(
                    width: DesignConstants.bankCardButtonSize,
                    height: DesignConstants.bankCardButtonSize
                )
                .background(
                    .white.opacity(0.14),
                    in: .rect(cornerRadius: DesignConstants.bankCardButtonCornerRadius)
                )
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Salin nomor rekening \(BankAppearance.name(brand))")
    }
}
