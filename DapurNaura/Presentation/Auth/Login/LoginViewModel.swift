//
//  LoginViewModel.swift
//  DapurNaura
//
//  DN-040 — the login screen's validation. Owner's instruction, 2026-08-10.
//

import Foundation

/// Holds what has been typed and decides whether it is enough to go in.
///
/// **There is no `State` enum**, which §2 otherwise requires one of. Loading, loaded and failed are
/// the three outcomes of *fetching something*, and this screen fetches nothing — DN-033 recorded
/// the same absence for the same reason. The enum arrives with real authentication, along with the
/// use case this class does not yet have.
///
/// **It decides; it does not navigate.** `attemptLogin()` answers a question and the View acts on
/// the answer — a ViewModel has no business knowing screens exist (§4).
///
/// **On §10 and the Indonesian strings below.** The rule is that wording *derived from data* — a
/// status, a price, a library error — belongs in DNLibrary, which is what DN-026 enforced when it
/// took status labels out of `PurchaseStatusBadge`. These are not that: they are static screen copy
/// selected by which box the user left empty, and DNLibrary has no notion of a login form to
/// derive them from. They move to the library on the day it does — when credential rules become
/// real, Android will need the identical ones.
@MainActor
@Observable
final class LoginViewModel {
    /// **Not `private(set)`, where `toast` below is** — and the difference is the direction of
    /// travel. §2's rule governs state the ViewModel *derives* and publishes outward; these two are
    /// input flowing the other way, and a `TextField` has to have somewhere to put it.
    var email = ""
    var password = ""

    /// The message at the top of the screen, or `nil` when there is none. Derived, so only this
    /// class sets it (§2).
    private(set) var toast: ToastMessage?

    /// Whether the screen may be left.
    ///
    /// **`true` means both boxes are filled and nothing more.** No credential was checked, because
    /// there is nothing to check against — owner's instruction, 2026-08-10: *"a screen, no API
    /// call."* When it is `false` the message naming the empty box is published as a side effect,
    /// which is the whole of what the owner called *"login validation"*.
    func attemptLogin() -> Bool {
        guard let complaint = emptyFieldComplaint else {
            toast = nil
            return true
        }

        // A fresh `ToastMessage` every time, including for an identical complaint: its `id` is what
        // lets the banner restart its three seconds rather than stack a second one.
        toast = ToastMessage(kind: .error, text: complaint)
        return false
    }

    /// The banner has been up long enough. **The View owns the clock, this owns the state** — which
    /// is what lets `toast` stay `private(set)`.
    func dismissToast() {
        toast = nil
    }

    /// `nil` when both boxes have something in them. The three messages are the owner's, and each
    /// names the box that is empty — *"if one of them empty, just follow the previous sentence but
    /// which field is empty."*
    ///
    /// Whitespace counts as empty: a space bar pressed by accident is not a password, and letting
    /// it through would be the one case where the screen's only rule quietly does not hold.
    private var emptyFieldComplaint: String? {
        let hasEmail = !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPassword = !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        switch (hasEmail, hasPassword) {
        case (true, true): return nil
        case (false, false): return "Email dan password harus diisi."
        case (false, true): return "Email harus diisi."
        case (true, false): return "Password harus diisi."
        }
    }
}
