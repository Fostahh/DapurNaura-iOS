//
//  StepTimestampRow.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct StepTimestampRow: View {
    let number: Int
    let step: RecipeStep
    let onSeek: (Int) -> Void

    var body: some View {
        if let seconds = step.videoTimestampSeconds {
            Button {
                onSeek(Int(truncating: seconds))
            } label: {
                row(timestamp: Self.formatted(Int(truncating: seconds)))
            }
            .buttonStyle(.plain)
        } else {
            row(timestamp: nil)
        }
    }

    private func row(timestamp: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignConstants.rowGutter) {
            Text("\(number).")
                .font(.subheadline.bold())
                .monospacedDigit()

            Text(step.text)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let timestamp {
                Text(timestamp)
                    .font(.caption.bold())
                    .monospacedDigit()
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(.rect)
    }

    static func formatted(_ seconds: Int) -> String {
        Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
}
