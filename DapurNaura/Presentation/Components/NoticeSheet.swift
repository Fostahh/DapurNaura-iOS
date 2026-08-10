//
//  NoticeSheet.swift
//  DapurNaura
//
//  DN-033 — one way to say "this part is not built yet", for every screen that has to.
//

import SwiftUI

/// A bottom sheet that shows a picture, a heading and a message, and closes by an X
/// floating above it.
///
/// Shared scope on the owner's instruction (2026-08-09), and §3's *"a component moves up
/// on its second consumer"* is satisfied rather than waived: `PurchaseSection` already
/// tells the user that buying in the app is unavailable. It is deliberately not converted
/// here, but it is why this is not built for one caller.
///
/// **Built by hand, not on `.sheet`** — owner's instruction, 2026-08-09. Two things follow
/// that were fought for while it was a `.sheet`: the X can float *above* the card, because
/// nothing drawn inside a `.sheet` escapes its background; and the height follows the
/// content, because a `VStack` is already as tall as what is in it, where
/// `.presentationDetents` needs a number and so needed the content measured and fed back.
///
/// **The cost:** the system behaviours `.sheet` supplied are ours to write now.
/// Drag-to-dismiss is below, behind `allowsDragToDismiss`; anything else found missing has
/// to be added here rather than inherited.
///
/// **Not generic over its content, deliberately** — no `content:` closure. Both callers in
/// sight want the same shape: a picture, a heading, a line of explanation. Split the chrome
/// into its own view when something needs different content, not before.
///
/// The caller presents it as an overlay, not through a modifier:
///
/// ```swift
/// .overlay { NoticeSheet(isPresented: $shown, imageURL: …, title: …, message: …) }
/// ```
///
/// Full reasoning: `docs/tickets/DN-033-product-cooking-class-selection-entry.md`.
struct NoticeSheet: View {
    @Binding var isPresented: Bool

    let imageURL: String
    let title: String
    let message: String

    /// The button at the foot of the sheet. **Both nil means no button at all** — which is how a
    /// full class is drawn: being full removes the way in, not the way to look.
    var actionTitle: String?
    var action: (() -> Void)?

    /// Whether dragging the card down dismisses it. **Defaults to on, and the one caller
    /// today turns it off** (owner's decision, 2026-08-09 — not needed yet). That direction
    /// is deliberate: dragging a sheet down is what iOS users expect, so the next screen
    /// gets it without knowing the flag exists, and opting out is visible at the call site.
    var allowsDragToDismiss: Bool = true

    /// DN-038. SwiftUI does not gate an author-written `.transition` on this setting — it has to be
    /// read. **The animation is not removed, only its travel**: a full-height card crossing the
    /// screen is what Reduce Motion is about, while snapping the sheet in with no animation at all
    /// would lose the cue that tells the reader what just changed.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                scrim
                sheet
            }
        }
        // Nothing is drawn when it is closed, but an overlay that is present and empty
        // still sits over the screen. This guarantees it cannot swallow a tap.
        .allowsHitTesting(isPresented)
        .animation(.snappy, value: isPresented)
    }

    private var scrim: some View {
        Color.black
            .opacity(DesignConstants.noticeScrimOpacity)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture { isPresented = false }
    }

    private var sheet: some View {
        VStack(spacing: DesignConstants.sectionSpacing) {
            SheetCloseButton { isPresented = false }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, DesignConstants.sectionSpacing)

            card
        }
        // Downwards only: dragging up must not peel the sheet off the bottom edge.
        .offset(y: max(dragOffset, 0))
        // `.subviews` rather than `.none` when it is off. `.none` disables every gesture in
        // the subtree, which includes the close button's tap — the one way out of a sheet
        // that can no longer be dragged away.
        .gesture(dragToDismiss, including: allowsDragToDismiss ? .all : .subviews)
        // The scrim above is already a fade and needs no equivalent.
        .transition(reduceMotion ? .opacity : .move(edge: .bottom))
    }

    private var card: some View {
        VStack(spacing: DesignConstants.sectionSpacing) {
            RemoteImage(urlString: imageURL)
                .frame(maxWidth: .infinity)
                .frame(height: DesignConstants.noticeImageHeight)
                .clipShape(.rect(cornerRadius: DesignConstants.cornerRadius))

            Text(title)
                .font(.title3)
                .bold()

            // Leading, not centred. A single sentence reads fine centred; a bulleted list built
            // upstream does not — ragged on both edges is hard to scan down.
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(DesignConstants.sectionSpacing)
        .frame(maxWidth: .infinity)
        // Full width, top corners only, fill carried through the home indicator — owner's
        // reference, 2026-08-09. Only the paint ignores the safe area, never the content:
        // nothing sits under the indicator, and no strip of scrim shows beneath the card.
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: DesignConstants.noticeSheetCornerRadius,
                topTrailingRadius: DesignConstants.noticeSheetCornerRadius,
                style: .continuous
            )
            .fill(.background)
            .ignoresSafeArea(edges: .bottom)
        }
    }

    /// Attached always, enabled by `allowsDragToDismiss`. Gating the mask rather than
    /// building the gesture conditionally keeps one code path: a `some Gesture` that
    /// sometimes exists would have to be erased or duplicated to type-check.
    private var dragToDismiss: some Gesture {
        DragGesture()
            .onChanged { drag in
                dragOffset = drag.translation.height
            }
            .onEnded { drag in
                if drag.translation.height > DesignConstants.noticeDismissDragDistance {
                    isPresented = false
                }
                withAnimation(.snappy) { dragOffset = 0 }
            }
    }
}

/// Matches the live call site: drag off, so the X is the only way out.
#Preview("Kelas Offline") {
    Color(.systemGroupedBackground)
        .overlay {
            NoticeSheet(
                isPresented: .constant(true),
                imageURL: "https://placehold.co/600x400/png?text=Kelas+Offline",
                title: "Segera Hadir",
                message: "Kelas Offline sedang kami siapkan. Mohon ditunggu, ya.",
                allowsDragToDismiss: false
            )
        }
}

/// Long message, and `allowsDragToDismiss` left at its default — so this preview covers
/// both the growing height and the other half of the flag. Drag it past 120pt to close.
#Preview("Pesan panjang") {
    Color(.systemGroupedBackground)
        .overlay {
            NoticeSheet(
                isPresented: .constant(true),
                imageURL: "",
                title: "Segera Hadir",
                message: """
                Kelas Offline sedang kami siapkan. Mohon ditunggu, ya. Pesan yang panjang \
                harus menambah tinggi sheet-nya, bukan terpotong — tinggi mengikuti isi.
                """
            )
        }
}
