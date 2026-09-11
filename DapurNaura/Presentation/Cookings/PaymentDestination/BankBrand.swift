//
//  BankBrand.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import Foundation
import DNLibrary

enum BankBrand: String, Hashable, Codable {
    case mandiri
    case bsi

    init(_ destination: PaymentDestination) {
        switch destination.bank {
        case .mandiri: self = .mandiri
        case .bsi: self = .bsi
        }
    }
}
