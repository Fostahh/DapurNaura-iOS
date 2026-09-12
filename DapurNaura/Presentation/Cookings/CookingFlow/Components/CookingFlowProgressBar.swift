//
//  CookingFlowProgressBar.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI

struct CookingFlowProgressBar: View {
    let pageIndex: Int
    let pageCount: Int

    var body: some View {
        VStack(spacing: DesignConstants.rowSpacing) {
            HStack(spacing: DesignConstants.progressSegmentGap) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= pageIndex ? Color.accentColor : Color(.systemFill))
                        .frame(height: DesignConstants.progressBarHeight)
                }
            }

            Text("\(pageIndex + 1)/\(pageCount)")
                .font(.caption.bold())
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, DesignConstants.sectionSpacing)
        .padding(.vertical, DesignConstants.rowSpacing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Langkah \(pageIndex + 1) dari \(pageCount)")
    }
}

#Preview {
    VStack(spacing: 24) {
        CookingFlowProgressBar(pageIndex: 0, pageCount: 3)
        CookingFlowProgressBar(pageIndex: 1, pageCount: 3)
        CookingFlowProgressBar(pageIndex: 2, pageCount: 3)
    }
}
