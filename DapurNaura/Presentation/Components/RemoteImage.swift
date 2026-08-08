//
//  RemoteImage.swift
//  DapurNaura
//
//  DN-015 — the AsyncImage block was written out four times across three files.
//

import SwiftUI

/// One loading treatment for every remote image in the app.
///
/// The caller supplies the frame; this owns only what the picture looks like
/// while it is arriving.
struct RemoteImage: View {
    let urlString: String
    var showsProgress: Bool = true

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(.quaternary)
                .overlay {
                    if showsProgress {
                        ProgressView()
                    }
                }
        }
        .clipped()
    }
}
