//
//  ProofDropzone.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI

struct ProofDropzone: View {
    let proof: UIImage?
    let onPickGallery: () -> Void
    let onPickCamera: () -> Void

    @State private var sourceChoiceShown = false

    @ScaledMetric private var iconSize = DesignConstants.proofDropzoneIconSize

    var body: some View {
        if let proof {
            filled(proof)
        } else {
            empty
        }
    }

    private func filled(_ proof: UIImage) -> some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignConstants.proofDropzoneMinHeight)
            .overlay {
                Image(uiImage: proof)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(.rect(cornerRadius: DesignConstants.proofDropzoneCornerRadius))
            .overlay(alignment: .topTrailing) {
                Button(action: chooseSource) {
                    Label("Ganti", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignConstants.rowGutter + 2)
                        .frame(minHeight: DesignConstants.minimumTapTarget)
                        .background(.black.opacity(0.72), in: .capsule)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .padding(DesignConstants.rowGutter)
                .confirmationDialog(
                    "Ganti bukti transfer",
                    isPresented: $sourceChoiceShown,
                    titleVisibility: .visible
                ) {
                    sourceOptions
                }
            }
    }

    private var empty: some View {
        VStack(spacing: DesignConstants.sectionSpacing - 2) {
            Button(action: chooseSource) {
                VStack(spacing: DesignConstants.sectionSpacing - 2) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle.weight(.light))
                        .foregroundStyle(DesignConstants.mutedText)
                        .frame(width: iconSize, height: iconSize)
                        .background(
                            DesignConstants.fieldBackground,
                            in: .rect(cornerRadius: DesignConstants.loginFieldCornerRadius)
                        )

                    VStack(spacing: DesignConstants.proofDropzoneTextSpacing) {
                        Text("Ketuk untuk pilih bukti transfer")
                            .font(.headline)
                        Text("Galeri atau kamera")
                            .font(.footnote)
                            .foregroundStyle(DesignConstants.mutedText)
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .confirmationDialog(
                "Pilih sumber bukti",
                isPresented: $sourceChoiceShown,
                titleVisibility: .visible
            ) {
                sourceOptions
            }

            HStack(spacing: DesignConstants.rowSpacing) {
                sourceButton("Galeri", systemImage: "photo.on.rectangle", action: onPickGallery)
                sourceButton("Kamera", systemImage: "camera", action: onPickCamera)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: DesignConstants.proofDropzoneMinHeight)
        .padding(DesignConstants.sectionSpacing + 8)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.proofDropzoneCornerRadius, style: .continuous)
                .strokeBorder(
                    DesignConstants.dividerLine,
                    style: StrokeStyle(lineWidth: DesignConstants.proofDropzoneDash, dash: [6, 5])
                )
        )
    }

    @ViewBuilder
    private var sourceOptions: some View {
        Button("Galeri", action: onPickGallery)
        Button("Kamera", action: onPickCamera)
        Button("Batal", role: .cancel) {}
    }

    private func sourceButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.footnote.weight(.medium))
                .foregroundStyle(DesignConstants.mutedText)
                .padding(.horizontal, DesignConstants.chipHorizontalPadding)
                .frame(minHeight: DesignConstants.minimumTapTarget)
                .background(DesignConstants.fieldBackground, in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
    }

    private func chooseSource() {
        sourceChoiceShown = true
    }
}
