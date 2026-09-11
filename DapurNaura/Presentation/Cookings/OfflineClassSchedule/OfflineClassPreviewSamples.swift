//
//  OfflineClassPreviewSamples.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 10/08/26.
//

import Foundation
import DNLibrary

enum OfflineClassPreviewSamples {

    static func offlineClass(
        name: String,
        day: Int,
        month: Int = 9,
        price: Int64 = 150_000,
        remainingQuota: Int32
    ) -> OfflineClass {
        OfflineClass(
            id: "\(name)-\(month)-\(day)",
            name: name,
            imageUrl: "https://placehold.co/300x300/png?text=\(name.replacingOccurrences(of: " ", with: "+"))",
            price: price,
            date: LocalDate(year: 2026, month: Int32(month), day: Int32(day)),
            materials: [
                "Black Pizza",
                "Original Pizza",
                "Pizza mini",
                "Pizza gulung",
                "Pizza sosis bite",
                "Saus Pizza"
            ],
            remainingQuota: remainingQuota
        )
    }

    static func september() -> OfflineClassMonth {
        OfflineClassMonth(
            year: 2026,
            month: Month.september,
            classes: [
                offlineClass(name: "Kelas Pizza", day: 2, remainingQuota: 25),
                offlineClass(name: "Kelas Aneka Pie", day: 5, price: 250_000, remainingQuota: 8),
                offlineClass(name: "Kelas Cake & Brownies", day: 9, price: 250_000, remainingQuota: 0)
            ]
        )
    }

    static func august() -> OfflineClassMonth {
        OfflineClassMonth(
            year: 2026,
            month: Month.august,
            classes: [
                offlineClass(name: "Kelas Pizza", day: 12, month: 8, remainingQuota: 0),
                offlineClass(name: "Kelas Aneka Pie", day: 15, month: 8, price: 250_000, remainingQuota: 0)
            ]
        )
    }
}
