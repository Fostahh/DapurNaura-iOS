//
//  CookingFlowControls.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI

struct CookingFlowControls: View {
    let canGoBack: Bool
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: DesignConstants.rowSpacing) {
            Button(action: onNext) {
                Text("Lanjut").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if canGoBack {
                Button(action: onBack) {
                    Text("Kembali").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(.horizontal, DesignConstants.sectionSpacing)
        .padding(.vertical, DesignConstants.rowGutter)
        .background(.bar)
    }
}

#Preview {
    VStack(spacing: 0) {
        Spacer()
        CookingFlowControls(canGoBack: false, onNext: {}, onBack: {})
    }
}
