//
//  Rupiah.swift
//  DapurNaura
//
//  DN-012 — lifted out of the DN-009 list row now that a second screen prices things.
//

import Foundation

/// Integer rupiah exactly as the contract sends it: `150000` → `"Rp150.000"`.
/// IDR has no minor unit in practice, so nothing follows the separator.
func rupiah(_ value: Int64) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = "."
    let grouped = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    return "Rp\(grouped)"
}
