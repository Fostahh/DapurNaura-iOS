//
//  PaymentProofView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI
import PhotosUI
import AVFoundation
import DNLibrary

struct PaymentProofView: View {
    @Environment(DapurNauraAppRouter.self) private var router
    @Environment(ToastCenter.self) private var toasts

    @State private var viewModel = PaymentProofViewModel()
    @State private var galleryItem: PhotosPickerItem?
    @State private var galleryShown = false
    @State private var cameraShown = false

    private let className: String
    private let price: Int64
    private let bank: BankBrand
    private let accountNumber: String

    init(className: String, price: Int64, bank: BankBrand, accountNumber: String) {
        self.className = className
        self.price = price
        self.bank = bank
        self.accountNumber = accountNumber
    }

    var body: some View {
        PaymentProofContent(
            className: className,
            price: price,
            bank: bank,
            accountNumber: accountNumber,
            proof: viewModel.proof,
            canSend: viewModel.canSend,
            isPreparing: viewModel.isPreparing,
            onPickGallery: { galleryShown = true },
            onPickCamera: { Task { await openCamera() } },
            onSend: send
        )
        .navigationTitle("Bukti Pembayaran")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(isPresented: $galleryShown, selection: $galleryItem, matching: .images)
        .fullScreenCover(isPresented: $cameraShown) {
            CameraPicker(
                onPicked: { image in
                    cameraShown = false
                    Task { await choose(image) }
                },
                onCancelled: { cameraShown = false }
            )
            .ignoresSafeArea()
        }
        .task(id: galleryItem) { await loadFromGallery() }
    }

    private func loadFromGallery() async {
        guard let galleryItem else { return }
        defer { self.galleryItem = nil }

        guard
            let data = try? await galleryItem.loadTransferable(type: Data.self),
            let image = UIImage(data: data)
        else {
            toasts.show(.error, "Gambar gagal dimuat. Silakan pilih ulang.")
            return
        }

        await choose(image)
    }

    private func choose(_ image: UIImage) async {
        if let complaint = await viewModel.choose(image) {
            toasts.show(.error, complaint)
        }
    }

    private func openCamera() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            refuseCamera()
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraShown = true

        case .notDetermined:
            if await AVCaptureDevice.requestAccess(for: .video) {
                cameraShown = true
            } else {
                refuseCamera()
            }

        default:
            refuseCamera()
        }
    }

    private func refuseCamera() {
        toasts.show(
            .information,
            "Akses kamera tidak diizinkan. Anda masih bisa memilih dari galeri."
        )
    }

    private func send() {
        guard viewModel.canSend else { return }

        toasts.show(.success, "Bukti pembayaran terkirim. Menunggu verifikasi.")

        while let last = router.path.last, case .payment = last {
            router.path.removeLast()
        }
    }
}
