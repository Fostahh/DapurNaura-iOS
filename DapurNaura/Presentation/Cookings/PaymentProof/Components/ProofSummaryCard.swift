//
//  ProofSummaryCard.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct ProofSummaryCard: View {
    let className: String
    let price: Int64
    let bank: BankBrand
    let accountNumber: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
                Text(className)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(DNFormat.shared.rupiah(value: price))
                    .font(.headline)
            }
            .padding(.horizontal, DesignConstants.sectionSpacing)
            .padding(.vertical, DesignConstants.rowGutter + 2)

            Divider()

            HStack(spacing: DesignConstants.rowSpacing + 2) {
                RoundedRectangle(cornerRadius: DesignConstants.proofBankStripeCornerRadius)
                    .fill(BankAppearance.card(bank))
                    .frame(
                        width: DesignConstants.proofBankStripeWidth,
                        height: DesignConstants.proofBankStripeHeight
                    )

                VStack(alignment: .leading, spacing: DesignConstants.proofSummaryLabelSpacing) {
                    Text("Rekening tujuan")
                        .font(.caption)
                        .foregroundStyle(DesignConstants.mutedText)
                    Text("\(BankAppearance.name(bank)) · \(accountNumber)")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DesignConstants.sectionSpacing)
            .padding(.vertical, DesignConstants.rowGutter)
        }
        .background(
            DesignConstants.fieldBackground,
            in: .rect(cornerRadius: DesignConstants.loginFieldCornerRadius)
        )
    }
}
