//
//  CookingMethodPage.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 12/09/26.
//

import SwiftUI
import DNLibrary

struct CookingMethodPage: View {
    let recipe: Recipe
    let isActive: Bool

    private static let placeholderVideoID = "5lJ-0YS3VoM"

    @State private var player = YouTubePlayerHolder()
    @State private var seekRequest: YouTubePlayerView.SeekRequest?
    @State private var seekToken = 0

    var body: some View {
        ScrollView {
            LazyVStack(
                alignment: .leading,
                spacing: DesignConstants.sectionSpacing,
                pinnedViews: .sectionHeaders
            ) {
                Text("Cara membuat")
                    .font(.title2.bold())

                Section {
                    Text("Ketuk langkah untuk melompat ke bagian videonya.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ForEach(Array(recipe.components.enumerated()), id: \.offset) { index, component in
                        if index > 0 {
                            Divider()
                        }

                        VStack(alignment: .leading, spacing: DesignConstants.rowSpacing) {
                            if let name = component.name {
                                Text(name)
                                    .font(.title3.bold())
                            }

                            ForEach(Array(component.steps.enumerated()), id: \.offset) { stepIndex, step in
                                StepTimestampRow(
                                    number: stepIndex + 1,
                                    step: step,
                                    onSeek: seek
                                )
                            }
                        }
                    }
                } header: {
                    YouTubePlayerView(
                        holder: player,
                        videoID: Self.placeholderVideoID,
                        seekRequest: seekRequest,
                        isActive: isActive
                    )
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))
                    .padding(.bottom, DesignConstants.rowSpacing)
                    .background(Color(.systemBackground))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignConstants.sectionSpacing)
        }
    }

    private func seek(to seconds: Int) {
        seekToken += 1
        seekRequest = YouTubePlayerView.SeekRequest(seconds: seconds, token: seekToken)
    }
}
