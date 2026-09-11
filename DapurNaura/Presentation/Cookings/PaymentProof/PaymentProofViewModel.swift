//
//  PaymentProofViewModel.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import Foundation
import UIKit

@MainActor
@Observable
final class PaymentProofViewModel {

    private(set) var proof: UIImage?

    private(set) var compressedProof: Data?

    var canSend: Bool { compressedProof != nil }

    var isPreparing: Bool { proof != nil && compressedProof == nil }

    func choose(_ image: UIImage) async -> String? {
        proof = image
        compressedProof = nil

        let data = await Self.compress(image)

        guard proof === image else { return nil }

        guard let data else {
            proof = nil
            return "Gambar gagal diproses. Silakan pilih ulang."
        }

        compressedProof = data
        return nil
    }

    nonisolated private static func compress(_ image: UIImage) async -> Data? {
        await Task.detached(priority: .userInitiated) {
            let longEdge = max(image.size.width, image.size.height)
            let scale = min(1, DesignConstants.proofMaxLongEdge / max(longEdge, 1))

            let target = CGSize(
                width: (image.size.width * scale).rounded(),
                height: (image.size.height * scale).rounded()
            )

            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1
            let resized = UIGraphicsImageRenderer(size: target, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: target))
            }

            return resized.jpegData(compressionQuality: DesignConstants.proofJpegQuality)
        }.value
    }
}
