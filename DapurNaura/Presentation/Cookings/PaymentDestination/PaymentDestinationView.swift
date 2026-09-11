//
//  PaymentDestinationView.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI
import DNLibrary

struct PaymentDestinationView: View {
    @Environment(DapurNauraAppRouter.self) private var router
    @Environment(ToastCenter.self) private var toasts

    @State private var viewModel: PaymentDestinationViewModel

    private let classId: String
    private let className: String
    private let price: Int64

    init(viewModel: PaymentDestinationViewModel, classId: String, className: String, price: Int64) {
        _viewModel = State(initialValue: viewModel)
        self.classId = classId
        self.className = className
        self.price = price
    }

    var body: some View {
        PaymentDestinationContent(
            state: viewModel.state,
            className: className,
            price: price,
            onCopy: copy,
            onRetry: { Task { await viewModel.load() } }
        )
        .navigationTitle("Pilih Rekening")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func copy(_ destination: PaymentDestination) {
        UIPasteboard.general.string = destination.accountNumber
        toasts.show(.success, "Nomor rekening tersalin")
        router.path.append(.payment(.proof(
            classId: classId,
            className: className,
            price: price,
            bank: BankBrand(destination),
            accountNumber: destination.accountNumber
        )))
    }
}
