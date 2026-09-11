//
//  PaymentProofContent.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI
import UIKit

struct PaymentProofContent: View {
    let className: String
    let price: Int64
    let bank: BankBrand
    let accountNumber: String
    let proof: UIImage?
    let canSend: Bool
    let isPreparing: Bool

    let onPickGallery: () -> Void
    let onPickCamera: () -> Void
    let onSend: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: DesignConstants.sectionSpacing) {
                    ProofSummaryCard(
                        className: className,
                        price: price,
                        bank: bank,
                        accountNumber: accountNumber
                    )

                    ProofDropzone(
                        proof: proof,
                        onPickGallery: onPickGallery,
                        onPickCamera: onPickCamera
                    )
                    .frame(maxHeight: .infinity)

                    guidance
                    sendButton
                }
                .padding(.horizontal, DesignConstants.loginHorizontalPadding)
                .padding(.vertical, DesignConstants.sectionSpacing)
                .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var guidance: some View {
        VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
            Text("Pastikan terlihat jelas")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DesignConstants.mutedText)

            ViewThatFits {
                HStack(spacing: DesignConstants.rowSpacing) { guidanceItems }
                VStack(spacing: DesignConstants.rowSpacing) { guidanceItems }
            }
        }
    }

    @ViewBuilder
    private var guidanceItems: some View {
        ForEach(["Nominal", "Tanggal", "Penerima"], id: \.self) { item in
            Label(item, systemImage: "checkmark")
                .font(.caption)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignConstants.rowSpacing)
                .background(
                    DesignConstants.fieldBackground,
                    in: .rect(cornerRadius: DesignConstants.noticeCornerRadius)
                )
        }
    }

    private var sendButton: some View {
        Button(action: onSend) {
            HStack(spacing: DesignConstants.rowSpacing) {
                if isPreparing {
                    ProgressView()
                        .tint(DesignConstants.fieldPlaceholder)
                }

                Text(isPreparing ? "Menyiapkan gambar…" : "Kirim Bukti Pembayaran")
            }
            .font(.headline)
            .foregroundStyle(canSend ? DesignConstants.primaryButtonLabel : DesignConstants.fieldPlaceholder)
            .frame(maxWidth: .infinity, minHeight: DesignConstants.loginFieldMinHeight)
            .background(
                canSend ? DesignConstants.primaryButton : DesignConstants.fieldBackground,
                in: .rect(cornerRadius: DesignConstants.loginFieldCornerRadius)
            )
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .animation(.snappy, value: isPreparing)
    }
}

private extension UIImage {
    static func previewProof(_ width: CGFloat, _ height: CGFloat, _ colour: UIColor) -> UIImage {
        let size = CGSize(width: width, height: height)
        return UIGraphicsImageRenderer(size: size).image { context in
            colour.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

#Preview("Kosong") {
    PaymentProofContent(
        className: "Jajanan Pasar",
        price: 125_000,
        bank: .mandiri,
        accountNumber: "1370012345678",
        proof: nil,
        canSend: false,
        isPreparing: false,
        onPickGallery: {},
        onPickCamera: {},
        onSend: {}
    )
}

#Preview("Bukti lanskap") {
    PaymentProofContent(
        className: "Jajanan Pasar",
        price: 125_000,
        bank: .mandiri,
        accountNumber: "1370012345678",
        proof: .previewProof(1200, 900, .systemPink),
        canSend: true,
        isPreparing: false,
        onPickGallery: {},
        onPickCamera: {},
        onSend: {}
    )
}

#Preview("Menyiapkan") {
    PaymentProofContent(
        className: "Jajanan Pasar",
        price: 125_000,
        bank: .bsi,
        accountNumber: "7201234567",
        proof: .previewProof(900, 1200, .systemTeal),
        canSend: false,
        isPreparing: true,
        onPickGallery: {},
        onPickCamera: {},
        onSend: {}
    )
}

#Preview("Teks aksesibilitas") {
    PaymentProofContent(
        className: "Jajanan Pasar",
        price: 125_000,
        bank: .mandiri,
        accountNumber: "1370012345678",
        proof: nil,
        canSend: false,
        isPreparing: false,
        onPickGallery: {},
        onPickCamera: {},
        onSend: {}
    )
    .environment(\.dynamicTypeSize, .accessibility3)
}
