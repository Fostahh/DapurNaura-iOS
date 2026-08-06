# DapurNaura iOS — Codebase Architecture

**Read this before changing code in this repository.** Every rule here traces to a decision taken
for this project, not to generic SwiftUI advice. If a change breaks a rule, either fix the change or
raise a ticket to change the rule — do not silently diverge.

Rules say **must**. Guidance says **should**.

Sibling document:
[`DNLibrary/docs/CODEBASE-STANDARD.md`](../../../DNLibrary/docs/CODEBASE-STANDARD.md), which governs
the data layer. Companion: [`../CLAUDE.md`](../CLAUDE.md), which covers build variants, secrets, the
local package rule and known issues. **Nothing in those two files is repeated here.**

> Established by DN-014 (2026-08-06). The decisions behind every section are recorded in
> `docs/tickets/DN-014-technical-ios-codebase-architecture.md` in the umbrella repo.

---

## 1. Layering

```
View  →  ViewModel  →  DNLibrary use case
```

- Dependencies point **inward only**. A ViewModel must not know a View exists.
- **There is no repository or use-case layer in Swift, and there must never be one.** DNLibrary
  already is that layer. Rebuilding it on this side is the standard KMP duplication mistake: two
  places to change, one of them untested.
- A View **must not** call a DNLibrary use case directly. It renders `state` and forwards events.
- A ViewModel **must not** `import SwiftUI`.

The app is a rendering layer over a tested library. That is the whole design, and every rule below
is a consequence of it.

## 2. The ViewModel contract

```swift
@MainActor
@Observable
final class CookingClassListViewModel {
    enum State {
        case loading
        case loaded([CookingClass])
        case failed(String)
    }

    private(set) var state: State = .loading
}
```

- **`@MainActor` and `@Observable`, always.** `@MainActor` is not optional — this project does not
  use Main Actor default isolation, so an unannotated observable class is a data race waiting for a
  background callback.
- **`final class`.** Never a struct — `@Observable` needs reference semantics.
- **State is `private(set)`.** Only the ViewModel mutates it.
- **One `State` enum per screen**, nested in the ViewModel. Loading, loaded and failed are three
  cases, not a `Bool` plus an optional.
- **Must not `import SwiftUI`.** This is the mechanical check that no view logic has leaked in. If a
  ViewModel needs that import, something belongs in the View instead.
- **Must not navigate** (§4) and **must not compute or format** (§10).

## 3. Views — structure and composition

- **One type per file. Must.** A `CookingClassRow` living at the bottom of `CookingClassListView.swift`
  is a violation, not a convenience.
- **Break views up with `View` structs, not computed properties or methods that return `some View`.**
  `@ViewBuilder` on a property does not give you what a real struct does — SwiftUI diffs and
  re-renders at struct boundaries, and a helper property is inlined into the parent's body.
- **Folder per feature**, not per pattern. `CookingClassDetail/` holds the view, the view model and
  its route; there is no `Views/` or `ViewModels/` directory.
- `#Preview`, never `PreviewProvider`.
- Business logic must not sit inline in `task()`, `onAppear()` or a button action. Call a ViewModel
  method.

## 4. Navigation

**One registration, value-based links, per-feature route enums.**

```swift
// CookingClassList/ClassRoute.swift — the feature owns its own routes
enum ClassRoute: Hashable {
    case detail(id: String)
}

// Navigation/Route.swift — the only type the root registers
enum Route: Hashable {
    case classes(ClassRoute)
    case recipes(RecipeRoute)
}
```

- **Exactly one `navigationDestination(for: Route.self)` in the app**, attached to content that is
  **always rendered** — never inside a `switch` over view state. A destination registered inside a
  conditional branch deregisters when that branch disappears, and any pushed screen is torn down.
  This is a defect that has already occurred here.
- **`NavigationLink(value:)` is the only permitted form.** `NavigationLink { destination } label: {}`
  is forbidden. Mixing the two in one `NavigationStack` causes SwiftUI to lose destinations. This is
  also a defect that has already occurred here.
- **Routes carry identifiers, never model objects.** A path of ids is `Codable` for deep links and
  state restoration; a path of SKIE-bridged Kotlin objects is neither.
- **Route enums are split per feature**, each in its feature folder, wrapped by the thin top-level
  `Route`. The wrapper keeps the path homogeneous — `[Route]` stays inspectable and encodable.
- **Drop the wrapper only when features become separate Swift packages**, at which point each package
  registers its own destination and the path becomes `NavigationPath`. **Not** when the enum "gets
  long." Screen count is not the trigger; module boundaries are.

**No Coordinator object, and no protocol-registration router.** A Coordinator in SwiftUI degenerates
into methods wrapping `Array` operations, because the path already *is* the coordinator's state.
Protocol registration protects module boundaries that do not exist in a single-target app, and tends
to force `AnyView`.

### Who owns the path

```swift
@MainActor
@Observable
final class AppRouter {
    var path: [Route] = []
}
```

Held as `@State` at the root, injected with `.environment(router)`. A **View** may push. A
**ViewModel must not** — it has no business knowing screens exist. Where navigation must follow async
work, the View observes the ViewModel's state and pushes; the ViewModel does not reach for the
router.

**Sheets and alerts are not routes.** They are local presentation state and stay as `@State` on the
view that triggers them.

## 5. Composition root

**`DapurNauraApp` is the only place that knows `DNDataLayer` exists.** That rule predates this
document — it was established by DN-012 and lived only in a commit message until now.

- The object graph is hand-wired in **`ViewModelFactory`**. **No DI framework**, matching the data
  layer's §1.
- Views receive a factory, never the data layer and never a repository.
- Swapping `DNDataLayer.stub()` for the live `DNDataLayer(config:)` happens here and nowhere else.

## 6. Crossing the SKIE boundary

DNLibrary is Kotlin. SKIE generates its Swift face, and that face has sharp edges worth naming:

| Kotlin | Swift |
|---|---|
| `description` | **`description_`** — collides with `CustomStringConvertible` |
| sealed result | `switch onEnum(of: result)` — exhaustive, no `default:` |
| `companion object` | `DNDataLayer.companion.stub()` |
| `suspend fun` | `try await useCase.invoke()` |

- **Never write `default:` when switching a sealed Kotlin type.** The exhaustive switch is the point:
  when the library adds an error case, this app must stop compiling until it is handled. A `default:`
  throws that away silently.
- **Kotlin nullability carries meaning — read the contract before treating a `nil` as "absent."**
  `RecipeSummary.portions == nil` means the class is **locked**, not that the recipe has no portions.
  The server omits the field entirely for unpurchased classes. Coalescing it to `""` destroys
  information the UI needs.
- `portions` and `loyang` are separate concepts and **must never be merged** into one string.

## 7. Errors, loading and empty states

- Every screen handles **three** states. A screen with only loaded and loading has forgotten failure.
- **`ContentUnavailableView`** for failures and empty results — do not hand-roll one.
- **One error vocabulary for the whole app.** The same failure must never be worded two different
  ways depending on which screen the user is standing on.
- **Cancellation is not a failure, and must be distinguished from one:**

  ```swift
  } catch is CancellationError {
      // The screen is going away; leave state untouched.
  } catch {
      state = .failed(...)   // never leave the screen on a spinner
  }
  ```

  An empty `catch` after `state = .loading` strands the screen on a spinner forever with no retry.

## 8. Language and content

- **Code, comments, types, commit messages: English.** No exceptions.
- **Every user-facing string: Bahasa Indonesia.** `kelas`, `bahan-bahan`, `loyang`, class and recipe
  names, button titles, error messages.
- **No `Localizable.xcstrings` and no string catalog.** There is no localisation and none is planned;
  a catalog would add ceremony for a second language that does not exist.

## 9. Design system

- **Semantic fonts only — never `.system(size:)`.** `.headline`, `.subheadline`, `.caption`. Text
  then scales with the user's chosen text size at no cost. SwiftLint enforces this (see below).
- **`bold()`, not `fontWeight(.bold)`.** Reserve other weights for a stated reason; scattered
  `.weight(.medium)` is noise.
- **Spacing, corner radii and colours come from shared constants**, not literals repeated across
  files.
- **44×44pt minimum for anything tappable.**
- `.caption2` should be avoided; it is very small even at default text size.
- Prefer hierarchical styles (`.secondary`, `.tertiary`) over manual `.opacity()`.

**Out of scope by decision: VoiceOver.** This app does not support it, and rules for it must not be
added here. Dynamic Type above is a font-choice rule, not an accessibility feature — it costs nothing
because semantic fonts are what you would write anyway.

## 10. Where logic belongs

**The load-bearing rule. The one that explains the rest of this document.**

The platform's Definition of Done requires tests for the data layer only. Read as architecture rather
than process, that means: **any logic written in Swift is logic that nothing will ever check.**

> **A ViewModel consumes. It does not compute, and it does not format.**

Business rules — prices, eligibility, what a user may open, what a status means — **must** live in
DNLibrary, where they are tested. So must **display formatting derived from data**: currency, counts,
error wording. Those become public, tested KMP functions that both platforms call.

```swift
// ❌ Must not exist in Swift — a rule nothing tests
if daysSincePurchase > 30 { hideRecipes() }

// ❌ Must not exist in Swift — formatting Android would have to reimplement
let label = "Rp" + formatter.string(from: value)

// ✅ Swift's job
Text(cookingClass.priceLabel)
```

**Why formatting too, and not just business rules.** An Android app is planned. A formatter written
in Swift is a formatter Android must reimplement, and the same price or the same error will
eventually read two different ways on two platforms.

**Formatters are shared functions, not fields on domain models.** `CookingClass.price` stays a
`Long`. Returning display strings from use cases would turn domain models into view models and
contradict `DNLibrary/docs/CODEBASE-STANDARD.md` §2.

**The boundary is the view.** Formatting derived only from data belongs in DNLibrary. Formatting that
depends on **view context** — truncating to fit two lines, choosing a short label because a card is
narrow — stays in Swift, because only the view knows.

**The accepted cost.** A copy change is now a library release: edit Kotlin, test, publish, tag,
release, bump the app. This was accepted deliberately in exchange for one tested source of truth
across both platforms. **Do not reintroduce a Swift-side formatter to avoid the release cycle.**

---

## Before submitting a change

- [ ] No ViewModel imports SwiftUI
- [ ] No new type shares a file with another type
- [ ] Navigation uses `NavigationLink(value:)`, and the single destination registration is untouched
- [ ] No business rule or data-derived formatting was added in Swift (§10)
- [ ] No `default:` in a switch over a sealed Kotlin type
- [ ] User-facing strings are Bahasa Indonesia; everything else is English
- [ ] `swiftlint` reports no violations in changed files
- [ ] **`project.pbxproj` carries no local package reference** — see [`../CLAUDE.md`](../CLAUDE.md).
      Files added under `DapurNaura/` need no project edit; it is a synchronized folder.

## What the build enforces for you

**SwiftLint, and nothing else.** There is no compiler equivalent of the data layer's `explicitApi()`
on this side.

`.swiftlint.yml` is tuned to this document rather than pulled in wholesale, including two custom
rules that enforce §9 and §4 directly:

| Rule | Enforces |
|---|---|
| `no_system_font` | §9 — `.system(size:)` is forbidden |
| `no_navigation_link_closure` | §4 — closure-based `NavigationLink` is forbidden |
| `no_default_in_onenum` | §6 — no `default:` in a sealed Kotlin switch |
| `no_swift_number_formatter` | §10 — data-derived formatting belongs in DNLibrary |
| `file_length`, `type_body_length` | §3 — pressure toward extracted `View` structs |
| `force_unwrapping`, `force_try` | general safety |

**§2 is deliberately not linted.** "A ViewModel must not import SwiftUI" needs *"this file contains
both X and Y"*, which regex expresses badly, and a rule that misfires trains people to ignore the
linter. It is enforced by review. Do not add a fragile approximation.

**A linter checks shape, not meaning.** It cannot see a price calculation that drifted into a
ViewModel, or a destination registered in the wrong branch of a switch. The most important rules here
— §4's single registration and §10 — are review rules, which is why they are written down this
precisely.

**Running it.** `.swiftlint.yml` lives at the repo root; run `swiftlint lint` from there.

Verified against SwiftLint 0.65.0 on 2026-08-06: 5 violations across 12 files, 1 of them an error.
Every one is a *Known violation* below — the linter found nothing this document had not already
predicted, which is the result you want on the first run. `unused_declaration` and `unused_import`
are analyzer rules and need `swiftlint analyze` with a compiler log; plain `lint` skips them.

The run-script build phase is **not yet wired** into the Xcode project. Doing so means editing
`project.pbxproj`, the file that carries the local-package reference that must never be committed —
see [`../CLAUDE.md`](../CLAUDE.md). Until it is wired, run the linter from the command line.

SwiftLint is configured for **`ios/DapurNaura` only** — not `DNLibrary`, which has no Swift sources,
and not `ios/SPMDNLibrary`, which is a single manifest file.

## Known violations

The current code does not yet comply. These are real, found by review on 2026-08-06, and each needs
its own ticket — **DN-014 wrote these rules; it did not apply them.**

| Rule | Violation |
|---|---|
| §4 | `CookingClassListView` registers `navigationDestination` inside the `.loaded` branch — it deregisters on retry |
| §4 | `CookingClassDetailView` pushes recipes with a closure-based `NavigationLink`, mixed with the list's value-based one |
| §4 | Routes are registered `for: String.self` — a universal type, not a route type |
| §7 | Both ViewModels have an empty `catch` that can strand a screen on a permanent spinner |
| §10 | `Rupiah.swift` and `DNError+Message.swift` format in Swift; both must move to DNLibrary |
| §3 | `CookingClassListView.swift` and `CookingClassDetailView.swift` each contain two types |
| §3 | `CookingClassDetailView` uses four `@ViewBuilder` helpers instead of extracted structs |
| §5 | Screens are wired with per-screen closures rather than a `ViewModelFactory` |
| §9 | Spacing, corner radii and `.caption2` appear as literals across three files |

SwiftLint currently reports 5 of these: the closure-based `NavigationLink` (error), the
`NumberFormatter` in `Rupiah.swift`, trailing whitespace, a vertical-whitespace violation, and
`static_over_final_class` in the UI-test scaffolding. **DN-015** fixes the behavioural ones,
**DN-016** moves the formatters.
