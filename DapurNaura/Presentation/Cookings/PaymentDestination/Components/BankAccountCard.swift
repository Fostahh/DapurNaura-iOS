//
//  BankAccountCard.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI
import DNLibrary

/// One account, in its bank's colour, with the number as the largest thing on it.
///
/// The number is the hero because it is what the user has come to read and copy; the bank's name
/// and the holder are context around it.
///
/// **There is no bank logo, and no placeholder standing in for one.** Owner's decision, 2026-09-12.
/// The bank is identified in text, which is what a transfer actually needs; drawing its mark would
/// reproduce a trademark, and Mandiri's own brand guideline forbids redrawing or recolouring it.
/// An empty box reserving the space read as a missing asset rather than as a choice.
struct BankAccountCard: View {
    let destination: PaymentDestination
    let onCopy: () -> Void

    /// Mapped here, at the one place a library `Bank` meets the screen.
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
