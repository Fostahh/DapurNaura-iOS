//
//  BankAppearance.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import SwiftUI

enum BankAppearance {
    static func card(_ bank: BankBrand) -> Color {
        switch bank {
        case .mandiri: DesignConstants.bankMandiriCard
        case .bsi: DesignConstants.bankBsiCard
        }
    }

    static func accent(_ bank: BankBrand) -> Color {
        switch bank {
        case .mandiri: DesignConstants.bankMandiriAccent
        case .bsi: DesignConstants.bankBsiAccent
        }
    }

    static func subdued(_ bank: BankBrand) -> Color {
        switch bank {
        case .mandiri: DesignConstants.bankMandiriSubdued
        case .bsi: DesignConstants.bankBsiSubdued
        }
    }

    static func name(_ bank: BankBrand) -> String {
        switch bank {
        case .mandiri: "Bank Mandiri"
        case .bsi: "Bank Syariah Indonesia"
        }
    }
}
