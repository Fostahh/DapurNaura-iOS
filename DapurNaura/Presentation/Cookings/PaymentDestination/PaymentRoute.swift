//
//  PaymentRoute.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/09/26.
//

import Foundation

enum PaymentRoute: Hashable {
    case destination(classId: String, className: String, price: Int64)

    case proof(classId: String, className: String, price: Int64, bank: BankBrand, accountNumber: String)
}
