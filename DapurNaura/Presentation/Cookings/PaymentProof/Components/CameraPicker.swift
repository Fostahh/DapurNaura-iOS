//
//  CameraPicker.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI
import UIKit

/// The camera, wrapped for SwiftUI.
///
/// **It exists because a paper receipt cannot be screenshotted.** Owner's reason, 2026-09-11: a
/// transfer made in a banking app produces a screenshot, one made at a counter produces paper, and
/// paper has to be photographed.
///
/// SwiftUI has no native camera capture, so this is the one `UIViewControllerRepresentable` in the
/// app. `PhotosPicker` covers the gallery natively and needs no permission; this one needs
/// `NSCameraUsageDescription`, which DN-046 added to all four build configurations. **Without that
/// key iOS terminates the process here** rather than refusing politely.
struct CameraPicker: UIViewControllerRepresentable {
    let onPicked: (UIImage) -> Void
    let onCancelled: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked, onCancelled: onCancelled)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onPicked: (UIImage) -> Void
        private let onCancelled: () -> Void

        init(onPicked: @escaping (UIImage) -> Void, onCancelled: @escaping () -> Void) {
            self.onPicked = onPicked
            self.onCancelled = onCancelled
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            // `.originalImage` rather than `.editedImage`: nothing is cropped, and a receipt the
            // user framed themselves is the proof they meant to send.
            if let image = info[.originalImage] as? UIImage {
                onPicked(image)
            } else {
                onCancelled()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancelled()
        }
    }
}
