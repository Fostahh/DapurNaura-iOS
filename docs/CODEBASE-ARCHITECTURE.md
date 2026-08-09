# DapurNaura iOS — Codebase Architecture

**Read this before changing code in this repository.** Every rule here traces to a decision taken
for this project, not to generic SwiftUI advice. If a change breaks a rule, either fix the change or
raise a ticket to change the rule — do not silently diverge.

Rules say **must**. Guidance says **should**.

Sibling document:
[`DNLibrary/docs/CODEBASE-ARCHITECTURE.md`](../../../DNLibrary/docs/CODEBASE-ARCHITECTURE.md), which governs
the data layer. Companion: [`../CLAUDE.md`](../CLAUDE.md), which covers build variants, secrets, the
local package rule and known issues. **Nothing in those two files is repeated here.**

> Established by DN-014 (2026-08-06). The decisions behind every section are recorded in
> `docs/tickets/DN-014-technical-ios-codebase-architecture.md` in the umbrella repo.

---

> **Source of truth.** For *what was asked for*, `../../../docs/requirements/` wins — over the code, over any other
> document, over a commit message. Where no requirement exists, **the ticket is the source of truth**
> and its `## Rationale` carries the why.
>
> This governs **intent**, not facts. For *what the code does today*, believe the code. When intent
> and implementation disagree, the implementation is what is wrong: record the correction in the
> **ticket**, never by editing the requirement.

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
- **A view that renders state must be constructible from that state alone. Must.** Not from a
  ViewModel — from the plain values it draws. A screen therefore splits in two: `<Feature>View`
  owns the ViewModel, the `.task` and the navigation modifiers; `<Feature>Content` takes `state`
  plus any callbacks and does the drawing.

  **The reason is previews, and only previews.** The test is mechanical: *can you `#Preview` it in
  every state?* If it needs a ViewModel, no — the ViewModel needs a use case, which needs a
  `DNDataLayer`. `DNDataLayer.companion.stub()` makes the happy path previewable, but **the stub
  never fails**, so `.failed` is unreachable, and so is `.loaded` with the awkward data — the long
  class name beside the widest badge, the recipe with `loyang` but no `portions`. Those are exactly
  the cases worth looking at before a device.

  **This rule is stricter than general SwiftUI practice, deliberately.** Apple's own samples use
  `@ViewBuilder private var content` freely, and there is nothing wrong with it — the earlier
  version of this rule justified the ban by SwiftUI diffing at struct boundaries, which is true in
  general but **buys nothing here**: the input that changed is the state the property switches on,
  so an extracted struct re-renders too. A rule defended by a reason that does not survive checking
  teaches people to stop trusting the document. The reason is previewability. Nothing else.

  A screen's `Content` view is still **screen level** for §4's purposes — it may name `Route`. The
  rule there is about components under `Components/`, not about this split.
- **Folder per feature**, not per pattern. `CookingClassDetail/` holds the view, the view model and
  its route; there is no `Views/` or `ViewModels/` directory.

### Folder layout

```
DapurNaura/
├── App/                    # @main, config, and the composition root
│   └── Navigation/         # Route, RouteDestination, DapurNauraAppRouter, ViewModelFactory
├── Config/                 # xcconfig — target membership OFF, see CLAUDE.md
└── Presentation/
    ├── Components/         # used by more than one feature
    ├── DesignConstants.swift
    └── <Feature>/          # one folder per screen
        ├── <Feature>View.swift
        ├── <Feature>ViewModel.swift
        ├── <Destination>Route.swift
        └── Components/     # used by this feature only
```

- **A component folder is named `Components/` at both scopes**, and the two are told apart by
  *where they sit*, not by what they are called. **Do not introduce atomic-design tiers**
  (`Atom/`, `Molecule/`, `Organism/`). "Which folder does this go in" must have a factual answer —
  how many features use it — rather than a judgement call about whether a row is an atom or a
  molecule. Tiers earn their keep in a design system with many consumers; this is one app, one
  target.
- **A component moves up to `Presentation/Components/` on its second consumer**, not in
  anticipation of one.
- **File name must equal the type name.** SwiftLint's `file_name` rule is not enabled — this one is
  on review, and three files had drifted before DN-015.
- **No junk-drawer folder.** A folder named for what its contents are *not* — `Helper/`, `Utils/`,
  `Misc/` — attracts everything nobody classified. `Helper/` existed here until DN-016 emptied it,
  and is not to come back. Anything that would go in one either belongs to a feature, is shared and
  belongs in `Presentation/Components/`, or is logic and belongs in DNLibrary (§10).
- `#Preview`, never `PreviewProvider`.
- Business logic must not sit inline in `task()`, `onAppear()` or a button action. Call a ViewModel
  method.

## 4. Navigation

**One registration, value-based links, per-feature route enums.**

```swift
// CookingClassDetail/ClassRoute.swift — owned by the feature it opens
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
- **A route is owned by the feature it navigates *into*, not the one it is pushed from.**
  `ClassRoute` lives in `CookingClassDetail/`, `RecipeRoute` in `RecipeDetail/`. Source-ownership
  survives only while each screen has exactly one entry point; the second screen to push a recipe
  would otherwise have to import the class-detail feature's vocabulary to do it.
- **Nothing below screen level may name `Route`. Must.** A row, badge or section takes data and —
  where it is tappable — a closure. The screen-level view is the lowest place a `Route` may appear.
  This is the rule; `NavigationLink` vs router is a mechanism choice underneath it.
  `RecipeLink` violated it and was deleted in DN-015.
- **Inside a `List`, prefer `NavigationLink(value:)` at that screen level.** It is already hoisted —
  the child declares an intent, the parent's `navigationDestination` resolves it — and it keeps the
  disclosure chevron, row press states and selection behaviour that SwiftUI gives free. Reach for
  the router when there is no link to attach: presentation following async work, or a jump that is
  not a tap.
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
final class DapurNauraAppRouter {
    var path: [Route] = []
}
```

Held as `@State` on `DapurNauraApp`, injected with `.environment(router)`, and bound by the root
stack as `NavigationStack(path: $router.path)`. A **View** may push. A **ViewModel must not** — it
has no business knowing screens exist. Where navigation must follow async work, the View observes
the ViewModel's state and pushes; the ViewModel does not reach for the router.

**The router is the array and nothing else.** `NavigationLink(value:)` appends and the back button
removes, so `push(_:)` and `popToRoot()` would have no callers — and a convenience method nothing
calls is worse than none, because the next screen copies it. Add one when a caller exists.

**Be honest about what it earns today: nothing.** Navigation is driven by `NavigationLink(value:)`,
and only `NavigationStack` reads `path`. The router is here because deep links, state restoration and
pop-to-root after a completed payment all need an owned path, and retrofitting one across five
screens costs more than carrying it across two. That is a deliberate bet on work that is scheduled,
not an abstraction earning its keep now. **Do not cite it as precedent for adding other structure
ahead of need.**

**`.navigationDestination` must apply `.id(route)`. Must.**

```swift
.navigationDestination(for: Route.self) { route in
    RouteDestination(route: route, factory: factory)
        .id(route)
}
```

Without it, SwiftUI identifies a destination by its **position** in the path. Replace the route at a
given depth — "next recipe", a deep link landing on a different class — and the view at that position
keeps its `@State`, so the previous screen's ViewModel survives and the user sees the old class. The
screens inject their ViewModel through `init` into `@State`, and **`State(initialValue:)` is used only
on first render**; every later pass builds a ViewModel and discards it. `.id(route)` is what makes
that discard harmless instead of a stale screen.

The discarded allocation is accepted: a ViewModel here stores two references and nothing more.
**Do not "fix" it by making the ViewModel optional and building it in `.task`** — that trades a cheap
allocation for an optional unwrap in every body and a loading state that means two different things.

**Any `#Preview` of a view that reads the router must inject one** — `@Environment(DapurNauraAppRouter.self)`
is non-optional and traps when absent:

```swift
#Preview { CookingClassListView(...).environment(DapurNauraAppRouter()) }
```

Previewing the `Content` view instead avoids this entirely, which is the other reason §3 wants the
split.

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
  `RecipeSummary.portions == nil` means **no value**, and nothing more. **It is not a lock signal**
  — whether the class is locked is answered by `purchaseStatus` on the same response, and only by
  that. Owner's decision, 2026-08-07: a locked class omits portions, but so does a bought recipe
  whose portions the owner has not supplied, so the field cannot carry both meanings.
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
contradict `DNLibrary/docs/CODEBASE-ARCHITECTURE.md` §2.

**The boundary is the view.** Formatting derived only from data belongs in DNLibrary. Formatting that
depends on **view context** — truncating to fit two lines, choosing a short label because a card is
narrow — stays in Swift, because only the view knows.

**The accepted cost.** A copy change is now a library release: edit Kotlin, test, publish, tag,
release, bump the app. This was accepted deliberately in exchange for one tested source of truth
across both platforms. **Do not reintroduce a Swift-side formatter to avoid the release cycle.**

---

## Before submitting a change

- [ ] **It builds** — `xcodebuild … build` reports `** BUILD SUCCEEDED **`, with an **id-based**
      simulator destination (DN-034). SwiftLint compiles nothing, so it cannot answer this
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

**SwiftLint, and the compiler.** There is no equivalent of the data layer's `explicitApi()` on this
side — nothing here fails a build over an architecture rule.

The compiler is listed because DN-034 made running it mandatory (see *Before submitting a change*),
and because it is the only thing in this repository that answers *"does this work at all"*. It
catches nothing in the rules below; SwiftLint catches nothing the compiler does. Neither stands in
for the other.

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

Verified against SwiftLint 0.65.0. The first run, on 2026-08-06, reported 5 violations across 12
files with 1 error — every one already a *Known violation* below, which is the result you want:
the linter found nothing this document had not predicted. **DN-015 and DN-016 cleared all five, and
it now reports 0.** `unused_declaration` and `unused_import` are analyzer rules needing
`swiftlint analyze` with a compiler log; plain `lint` skips them.

The run-script build phase is **not yet wired** into the Xcode project. Doing so means editing
`project.pbxproj`, the file that carries the local-package reference that must never be committed —
see [`../CLAUDE.md`](../CLAUDE.md). Until it is wired, run the linter from the command line.

SwiftLint is configured for **`ios/DapurNaura` only** — not `DNLibrary`, which has no Swift sources,
and not `ios/SPMDNLibrary`, which is a single manifest file.

## Known violations

Found by review on 2026-08-06, when this document was written against code that predated it.
**DN-014 wrote these rules; DN-015 applied them.**

| Rule | Violation | Status |
|---|---|---|
| §4 | `CookingClassListView` registered `navigationDestination` inside the `.loaded` branch — it deregistered on retry | ✅ DN-015 |
| §4 | `CookingClassDetailView` pushed recipes with a closure-based `NavigationLink`, mixed with the list's value-based one | ✅ DN-015 |
| §4 | Routes were registered `for: String.self` — a universal type, not a route type | ✅ DN-015 |
| §7 | Both ViewModels had an empty `catch` that could strand a screen on a permanent spinner | ✅ DN-015 |
| §3 | `CookingClassListView.swift` and `CookingClassDetailView.swift` each contained two types | ✅ DN-015 |
| §3 | `CookingClassDetailView` used four `@ViewBuilder` helpers instead of extracted structs | ✅ DN-015 |
| §3 | The state switch stayed a `@ViewBuilder` property on all three screens, so no state was previewable — the app had **zero** `#Preview` | ✅ DN-015 for the two real screens, ✅ DN-021 for the third |
| §5 | Screens were wired with per-screen closures rather than a `ViewModelFactory` | ✅ DN-015 |
| §9 | Spacing, corner radii and `.caption2` appeared as literals across three files | ✅ DN-015 |
| §3 | `Atom/` folders held an atom, two molecules and an organism, duplicating `Components/` at a different scope | ✅ DN-015 |
| §3 | Three files whose names did not match the type inside them (`AppConfig`, and both route enums) | ✅ DN-015 |
| §4 | Route enums sat with the screen that pushed them rather than the screen they open | ✅ DN-015 |
| §4 | `RecipeLink`, a feature component, named `Route` and chose the destination | ✅ DN-015 |
| §4 | No router existed — the stack used SwiftUI's implicit path, though this document specified one | ✅ DN-015 |
| §10 | `Rupiah.swift` and `DNError+Message.swift` format in Swift; both must move to DNLibrary | ✅ DN-016 |
| §10 | `PurchaseStatusBadge` worded a library enum in Swift — a total function from `PurchaseStatus` to a string a user reads, which §10 puts in DNLibrary | ✅ DN-026 |

**`swiftlint lint` reports 0 violations**, as of DN-016. Every row above is struck. Keep it that way:
the value of a clean linter is that the next violation is visible the moment it appears, and a
codebase that habitually reports "3 known ones" has no such signal.

The custom rules stay even though nothing trips them — `no_swift_number_formatter` is what stops
`Rupiah.swift` growing back in a new file next time somebody needs a price on screen, which is
exactly how it appeared the first time.

**Every row above is now struck.** The last standing exemption — `RecipePlaceholderView`, which kept
its state switch as a `@ViewBuilder` property because the file was temporary — **died with the file**
when DN-021 replaced it with the real recipe screen. That is how a scoped exemption is supposed to
end: not renewed, not forgotten, but removed along with the thing it excused.
