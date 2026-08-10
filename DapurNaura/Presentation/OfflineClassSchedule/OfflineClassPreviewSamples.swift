//
//  OfflineClassPreviewSamples.swift
//  DapurNaura
//
//  DN-036 — sample data for #Preview only (ARCHITECTURE §3: every state must be previewable).
//

import Foundation
import DNLibrary

/// Offline classes for previews, and nothing else.
///
/// §3 requires every state of a screen to be previewable, and `DNDataLayer.stub()` cannot answer
/// that here: it never fails, and its dates are fixed to one window — so *failed*, *empty* and
/// *a month where every class is full* are all unreachable through it. Building the models by hand
/// is what makes those visible before a device.
///
/// A type rather than a bare extension so the file obeys §3's *file name equals type name*.
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

    /// One month holding all three availability states, which is the row set worth looking at.
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

    /// A month where nothing can be joined — the case whose section shows no number at all.
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
