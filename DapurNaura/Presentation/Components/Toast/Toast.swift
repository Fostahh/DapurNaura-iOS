//
//  Toast.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 11/08/26.
//

import SwiftUI

/// A short message that appears at the top of the screen and clears itself after three seconds.
///
/// Shared scope with one caller today, the same position `NoticeSheet` was in: the owner asked for
/// it to be reusable and named three kinds (2026-08-10), two of which the login screen cannot show.
/// §3's *"a component moves up on its second consumer"* is answered by the instruction rather than
/// waived.
///
/// The caller presents it as an overlay, and the optional message is both the content and the
/// presented state — so the two cannot disagree:
///
/// ```swift
/// .overlay(alignment: .top) { ToastHost() }
/// ```
///
/// **It takes a value and draws it. That is all it does.** No binding, no clock, no callback — the
/// three seconds belong to `ToastCenter`, the only thing that can call off a countdown it started.
/// What that leaves is a view previewable in every state from a literal.
///
/// **Triggering it again restarts the three seconds; it never stacks a second toast.** Owner's
/// requirement, 2026-08-10 — `ToastCenter.show` restarts its timer, and the banner it is already
/// drawing simply stays.
///
/// **It never intercepts a tap.** There is nothing on it to press, and a banner that swallows
/// touches near the top of the screen reads as a frozen app.
struct Toast: View {
    let message: ToastMessage?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// One line of banner — what a single-line toast measures, text and inset together. It scales
    /// with the user's text size because the text inside it does.
    @ScaledMetric(relativeTo: .subheadline) private var lineHeight = DesignConstants.toastLineHeight

    /// What sits above and below the text, so that **one line of text plus this inset is exactly
    /// one line of banner**. Derived rather than chosen: `lineHeight` is what a one-line banner
    /// stands at and the text is measured in `UIFont`'s, so half the difference is the space, and
    /// it follows both when they scale.
    private var textInset: CGFloat {
        max(0, (lineHeight - Self.oneLineHeight) / 2)
    }

    var body: some View {
        ZStack(alignment: .top) {
            if let message {
                banner(message)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        // The insets sit here rather than on the banner, so the banner spans the screen less them
        // and the text wraps at the width it is actually drawn at.
        .padding(.top, DesignConstants.toastInset)
        .padding(.horizontal, DesignConstants.toastInset)
        .allowsHitTesting(false)
        .animation(.snappy, value: message)
    }

    /// **The banner is the text plus its inset, and nothing else decides its height.** Owner's
    /// decision, 2026-09-12, **superseding the multiple-of-one-line rule of 2026-08-10**: a
    /// two-line message in a box built for two lines of 48 stood 96 tall for 41pt of text, and the
    /// quantised height was visible as a gap under the last line.
    ///
    /// **What the old rule was for survives anyway.** It existed so two toasts wrapping to the same
    /// number of lines are the same size — and they are, because the same font at the same width
    /// wraps to the same height. What is gone is only the rounding up to whole lines.
    ///
    /// **A single-line toast is unchanged at `lineHeight` tall**, since its inset is derived to
    /// make it so. Nothing is measured any more: no `GeometryReader`, no line count, no fixed
    /// height to truncate against.
    private func banner(_ message: ToastMessage) -> some View {
        Text(message.text)
            .font(.subheadline)
            .multilineTextAlignment(.leading)
            .foregroundStyle(DesignConstants.toastLabelTint(for: message.kind))
            .padding(.horizontal, DesignConstants.toastPadding)
            .padding(.vertical, textInset)
            // `alignment` is what puts the text on the leading edge. `multilineTextAlignment`
            // above only rags the lines *within* the text block; without this the block itself is
            // centred, because that is what `.frame` does when no alignment is given. There is no
            // vertical alignment to set: the banner is exactly as tall as what is in it.
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DesignConstants.toastCornerRadius, style: .continuous)
                    .fill(DesignConstants.toastTint(for: message.kind))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignConstants.toastCornerRadius, style: .continuous)
                    .stroke(
                        DesignConstants.toastBorderTint(for: message.kind),
                        lineWidth: DesignConstants.toastBorderWidth
                    )
            )
            .transition(reduceMotion ? AnyTransition.opacity : .move(edge: .top).combined(with: .opacity))
    }

    private static var oneLineHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
    }
}

#Preview("Error") {
    DesignConstants.loginBackground
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Toast(message: ToastMessage(kind: .error, text: "Email dan password harus diisi."))
        }
}

/// White on white — the case the outline exists for. Owner's decision, 2026-08-10.
#Preview("Information") {
    DesignConstants.loginBackground
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Toast(
                message: ToastMessage(kind: .information, text: "Kelas ini sedang kami siapkan.")
            )
        }
}

#Preview("Success") {
    DesignConstants.loginBackground
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Toast(message: ToastMessage(kind: .success, text: "Berhasil disimpan."))
        }
}

/// Long enough to wrap, so the banner grows rather than clipping.
#Preview("Pesan panjang") {
    DesignConstants.loginBackground
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Toast(
                message: ToastMessage(
                    kind: .error,
                    text: "Email dan password harus diisi sebelum masuk ke aplikasi Dapur Naura."
                )
            )
        }
}
