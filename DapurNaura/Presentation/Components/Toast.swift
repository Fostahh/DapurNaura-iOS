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
/// .overlay(alignment: .top) { Toast(message: viewModel.toast, onDismiss: viewModel.dismissToast) }
/// ```
///
/// **It takes a value and reports back, rather than taking a `Binding`.** A ViewModel publishes its
/// state `private(set)` (§2), so a component that writes straight into it could not be used from
/// one. This owns the clock; the caller owns the state.
///
/// **Triggering it again restarts the three seconds; it never stacks a second toast.** Owner's
/// requirement, 2026-08-10. That falls out of `ToastMessage` being `Identifiable` — `.task(id:)`
/// restarts on a new `id`, and two presses on the same empty field produce identical *text*, so
/// the text alone could not have told them apart.
///
/// **It never intercepts a tap.** There is nothing on it to press, and a banner that swallows
/// touches near the top of the screen reads as a frozen app.
struct Toast: View {
    let message: ToastMessage?
    let onDismiss: () -> Void

    /// How many lines the message wraps to, measured. Drives the banner's height — see `banner`.
    @State private var lineCount = 1

    var body: some View {
        ZStack(alignment: .top) {
            if let message {
                banner(message)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        // The insets sit here rather than on the banner so the text is measured at the width it
        // will actually be drawn at. Measured 16pt wider, a message that wraps to two lines can
        // come back as one, and the height would then be 40 for a banner needing 80.
        .padding(.top, DesignConstants.toastInset)
        .padding(.horizontal, DesignConstants.toastInset)
        .allowsHitTesting(false)
        .animation(.snappy, value: message)
        .task(id: message?.id) {
            guard message != nil else { return }

            do {
                try await Task.sleep(for: DesignConstants.toastDuration)
            } catch {
                // Cancelled — either a newer message replaced this one and owns the countdown
                // now, or the view went away. Either way this one must not clear anything.
                return
            }

            onDismiss()
        }
    }

    /// **40 tall for one line, 80 for two, and so on** — owner's decision, 2026-08-10. The height
    /// is a multiple of a constant rather than whatever the text measured, so two toasts carrying
    /// the same number of lines are always the same size.
    ///
    /// That needs the *line count*, which the text does not report, so it is derived: measure the
    /// text's natural height and divide by one line of the font it is set in. `UIFont`'s
    /// `preferredFont` gives that exactly and follows the user's text size, so the division stays
    /// right when the text scales.
    private func banner(_ message: ToastMessage) -> some View {
        Text(message.text)
            .font(.subheadline)
            .multilineTextAlignment(.leading)
            .foregroundStyle(DesignConstants.toastLabelTint(for: message.kind))
            .padding(.horizontal, DesignConstants.toastPadding)
            // `alignment` is what puts the text on the leading edge. `multilineTextAlignment`
            // above only rags the lines *within* the text block; without this the block itself is
            // centred, because that is what `.frame` does when no alignment is given.
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                GeometryReader { proxy in
                    Color.clear.task(id: proxy.size.height) {
                        lineCount = Self.lineCount(forTextHeight: proxy.size.height)
                    }
                }
            }
            .frame(height: CGFloat(lineCount) * DesignConstants.toastLineHeight)
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
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    private static func lineCount(forTextHeight height: CGFloat) -> Int {
        let oneLine = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
        guard oneLine > 0 else { return 1 }

        return max(1, Int((height / oneLine).rounded()))
    }
}

#Preview("Error") {
    DesignConstants.loginBackground
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Toast(message: ToastMessage(kind: .error, text: "Email dan password harus diisi."), onDismiss: {})
        }
}

/// White on white — the case the outline exists for. Owner's decision, 2026-08-10.
#Preview("Information") {
    DesignConstants.loginBackground
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Toast(message: ToastMessage(kind: .information, text: "Kelas ini sedang kami siapkan."), onDismiss: {})
        }
}

#Preview("Success") {
    DesignConstants.loginBackground
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            Toast(message: ToastMessage(kind: .success, text: "Berhasil disimpan."), onDismiss: {})
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
                ),
                onDismiss: {}
            )
        }
}
