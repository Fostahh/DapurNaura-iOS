//
//  SheetCloseButton.swift
//  DapurNaura
//
//  DN-036 — extracted out of NoticeSheet (ARCHITECTURE §3).
//

import SwiftUI

/// The floating X that closes a sheet.
///
/// **A rounded square rather than a disc, and it floats above the sheet rather than sitting inside
/// it** — owner's direction, 2026-08-09. Drawn at the full 44pt tap target, so §9's minimum needs
/// no separate hit area behind a smaller visible control.
struct SheetCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(
                    width: DesignConstants.minimumTapTarget,
                    height: DesignConstants.minimumTapTarget
                )
                .background(
                    .background,
                    in: .rect(
                        cornerRadius: DesignConstants.noticeCloseCornerRadius,
                        style: .continuous
                    )
                )
                // What lifts it off whatever it is floating over.
                .shadow(
                    color: .black.opacity(DesignConstants.noticeCloseShadowOpacity),
                    radius: DesignConstants.noticeCloseShadowRadius,
                    y: DesignConstants.noticeCloseShadowOffsetY
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SheetCloseButton(action: {})
        .padding()
        .background(Color(.systemGroupedBackground))
}
