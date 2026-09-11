//
//  PaymentDestinationContent.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI
import DNLibrary

struct PaymentDestinationContent: View {
    let state: PaymentDestinationViewModel.State
    let className: String
    let price: Int64
    let onCopy: (PaymentDestination) -> Void
    let onRetry: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignConstants.sectionSpacing + 6) {
                summary

                switch state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, DesignConstants.sectionSpacing * 2)

                case .loaded(let destinations):
                    loaded(destinations)

                case .failed(let message):
                    LoadFailedView(message: message, retry: onRetry)
                }
            }
            .padding(.horizontal, DesignConstants.loginHorizontalPadding)
            .padding(.vertical, DesignConstants.sectionSpacing)
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: DesignConstants.paymentSummaryLabelSpacing) {
            Text("Pembayaran untuk")
                .font(.footnote)
                .foregroundStyle(DesignConstants.mutedText)

            HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
                Text(className)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(DNFormat.shared.rupiah(value: price))
                    .font(.title3)
                    .bold()
            }
        }
        .padding(DesignConstants.sectionSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DesignConstants.fieldBackground,
            in: .rect(cornerRadius: DesignConstants.loginFieldCornerRadius)
        )
    }

    @ViewBuilder
    private func loaded(_ destinations: [PaymentDestination]) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.rowGutter) {
            Text(
                "Transfer tepat \(DNFormat.shared.rupiah(value: price)) ke salah satu rekening di bawah ini.")
                .font(.subheadline)
                .foregroundStyle(DesignConstants.mutedText)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(destinations, id: \.accountNumber) { destination in
                BankAccountCard(destination: destination) { onCopy(destination) }
            }
        }

        HStack(alignment: .top, spacing: DesignConstants.rowSpacing + 2) {
            Image(systemName: "info.circle")
                .foregroundStyle(DesignConstants.mutedText)
            Text("Ketuk ikon salin untuk menyalin nomor rekening. " +
                 "Anda akan langsung diarahkan ke halaman unggah bukti.")
                .font(.footnote)
                .foregroundStyle(DesignConstants.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("Terisi") {
    PaymentDestinationContent(
        state: .loaded([
            PaymentDestination(bank: .mandiri, accountNumber: "1370012345678", accountHolderName: "Dapur Naura"),
            PaymentDestination(bank: .bsi, accountNumber: "7201234567", accountHolderName: "Dapur Naura")
        ]),
        className: "Jajanan Pasar",
        price: 125_000,
        onCopy: { _ in },
        onRetry: {}
    )
}

#Preview("Gagal") {
    PaymentDestinationContent(
        state: .failed("Tidak dapat terhubung. Periksa koneksi internet Anda."),
        className: "Jajanan Pasar",
        price: 125_000,
        onCopy: { _ in },
        onRetry: {}
    )
}
