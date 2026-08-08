# CLAUDE.md

Guidance for Claude Code working in the DapurNaura iOS app.

This repo is one project inside the **Dapur Naura platform** workspace. The workflow, ticket
process, autonomy rules and release flow are defined in the umbrella repo — read
`../../CLAUDE.md` and `../../docs/ARCHITECTURE-AND-WORKFLOW.md` before starting a ticket.

## What this app is

A cooking app for **Dapur Naura**, digitalising the paid cooking classes the owner's family teaches.
Browse **cooking classes** (*kelas*) → open one to see its **recipes** → open a recipe for its
ingredients (*bahan-bahan*), the step-by-step method, and a how-to video. Content is Bahasa
Indonesia. Audience is people learning to cook.

**None of that is built yet.** The app is the stock Xcode template plus the build-variant plumbing,
with **no data layer at all** and no UI design. Everything except `AppConfig` and the xcconfig
system is scaffolding to be replaced.

## Project shape

SwiftUI, an Xcode project (not an SPM package). Three source files today:

- **`DapurNaura/DapurNauraApp.swift`** — `@main` entry point. Back to the stock template: it shows
  `ContentView` and nothing else. It no longer initialises `DNNetworkManager`.
- **`DapurNaura/ContentView.swift`** — the stock template "Hello, world!" view.
- **`DapurNaura/AppConfig.swift`** — reads build-variant values out of `Info.plist`, see
  [Build variants](#build-variants). **Nothing calls it yet**, so its fail-loud guard is currently
  unexercised — the first caller is also the first real test of it.

Tests: `DapurNauraTests/` (Swift Testing, `@Test` / `#expect`) and `DapurNauraUITests/` (XCTest).
Both are empty scaffolding.

**UI work is not automatically tested.** Per the platform Definition of Done, unit tests are
required for the data layer only; UI is verified manually by the human. Do not add Swift tests
unless a ticket explicitly asks for them.

## Build & test

Schemes are **per variant**. There is no scheme called plain `DapurNaura` — the four are
`DapurNaura Dev`, `DapurNaura Alpha`, `DapurNaura Beta` and `DapurNaura Release`, and the space in
the name means they must be quoted.

```sh
xcodebuild -list -project DapurNaura.xcodeproj          # schemes + configurations

xcodebuild -project DapurNaura.xcodeproj -scheme "DapurNaura Dev" \
  -destination 'platform=iOS Simulator,name=iPad (A16)' build

xcodebuild -project DapurNaura.xcodeproj -scheme "DapurNaura Dev" \
  -destination 'platform=iOS Simulator,name=iPad (A16)' test

# What a variant actually resolves to — use this to check an xcconfig took effect
xcodebuild -project DapurNaura.xcodeproj -scheme "DapurNaura Beta" -configuration Beta \
  -showBuildSettings | grep -E "PRODUCT_BUNDLE_IDENTIFIER|API_BASE_URL|ENABLE_NETWORK_LOGGING"
```

⚠️ `-showBuildSettings` proves what the *build* resolves, not what *ships*. To prove nothing leaked
into the bundle, inspect the built product: `find <path>/DapurNaura.app -name "*.xcconfig"` must
return nothing.

## Build variants

Four build configurations, each driven by one xcconfig in `DapurNaura/Config/`:

| Variant | Backend | Logging | Audience | Distribution |
|---|---|---|---|---|
| **Development** | staging | on | developers, QA | Xcode only — never uploaded |
| **Alpha** | staging | on | family members | TestFlight → "Alpha" group |
| **Beta** | production | off | family + selected users | TestFlight → "Beta" group |
| **Release** | production | off | public | App Store |

**Alpha is the earlier, less stable tier; Beta comes after it.** Conventional order — do not swap.

Alpha, Beta and Release share **one bundle id** (`id.dn.fostah.DapurNaura`) because they are one
App Store Connect record separated by TestFlight groups, not by identity. Only Development differs
(`.dev`), so a developer build can sit alongside an installed TestFlight build.

**How a value reaches code:** `DapurNaura/Config/<Variant>.xcconfig` → `$(VAR)` placeholder in
`DapurNaura/Info.plist` → `AppConfig.swift` reads it via
`Bundle.main.object(forInfoDictionaryKey:)`. Never read Info.plist directly elsewhere; add an
accessor to `AppConfig` instead.

`AppConfig` **fails loudly** on a missing value, including the case where the substitution never
happened and the literal `$(API_KEY)` is left in the plist — otherwise a missing config surfaces as
a confusing 401 rather than a clear error.

### The layout is deliberately flat

Five files, one level of `#include`:

```
Development.xcconfig ┐
Alpha.xcconfig       │  committed, self-contained
Beta.xcconfig        │  #include "Secrets.xcconfig"
Release.xcconfig     ┘
Secrets.xcconfig        gitignored, two lines
```

Each variant file is **complete on its own** — URL, bundle id, display name, logging flag, all
literal. There is no `Base.xcconfig` and no `$(BASE_BUNDLE_ID)`-style variable indirection: to
answer *"what does Beta point at?"* you open `Beta.xcconfig` and read it, with no hops.

That duplicates `INFOPLIST_FILE` and the bundle id across four files. Accepted on purpose — three
repeated lines are cheaper to understand than an inheritance chain. **Do not re-introduce a shared
base file** to remove the duplication.

### Secrets

`Config/Secrets.xcconfig` is **gitignored** and holds *only* `STAGING_API_KEY` and `PROD_API_KEY`.
Create it by hand with those two lines; `AppConfig` prints exactly that if it is missing.

Everything else stays **committed** — URLs, bundle ids and flags belong in review, so a variant
silently changing environment shows up in the diff.

⚠️ Gitignoring keeps keys out of git; it does **not** make them secret. Everything in Info.plist
ships readable inside the `.ipa`. Only low-privilege, publishable keys belong here — a Midtrans
**server** key, or anything that can move money, must never be in the app at all.

⚠️ `DapurNaura/` is a **synchronized folder**: every file added under it joins the target
automatically and gets copied into the `.app`. Anything in `Config/` must therefore be listed in
the target's `membershipExceptions` (Xcode: File Inspector → untick Target Membership). This was
missed once and shipped all seven xcconfigs, `Secrets.xcconfig` included, inside the bundle —
**adding a file to `Config/` means unticking its target membership.**

## Data layer — planned, not wired

**This is a standalone SwiftUI app.** It has no data layer: no package dependency, no networking,
and nothing imports DNLibrary. That wiring was removed deliberately — treat this repo as a new
SwiftUI project.

**Do not add DNLibrary imports, package references or product dependencies until a ticket asks for
it.** If you need data for UI work, use local mock data in Swift.

Everything below is **context for later**, not a description of the code:

The data/networking layer will not be native Swift. It will come from **DNLibrary**, a Kotlin
Multiplatform library built in `../../DNLibrary`, delivered as a binary XCFramework and consumed
through the `SPMDNLibrary` Swift package. When it changes, it changes there — not here.

### The rules that switch on when it is wired

They are inert today. Read them before the ticket that reinstates the dependency, not before.

| | Where | Committed? |
|---|---|---|
| **Remote** | `SPMDNLibrary` git tag (semver, e.g. `0.3.0`) | ✅ always this |
| **Local** | `../DNLibraryLocal` — a build artifact in no repo | ❌ **never** |

Development builds against the local package, generated by `../../DNLibrary/scripts/publish-spm.sh`
in `local` mode. Switching to it dirties `DapurNaura.xcodeproj/project.pbxproj` and
`Package.resolved`. **Revert both before committing.**

- **Never run `git add -A` or `git commit -a` in this repo.** Xcode rewrites `project.pbxproj`
  constantly, so a blanket add sweeps the local wiring into history. Stage files explicitly.
- The committed dependency is a **version range**, so `Package.resolved` must be committed — it is
  the only thing making a build reproducible.
- Adding a package via Xcode creates a **new** product dependency rather than reusing an existing
  one. Duplicates produce `Missing package product 'DNLibrary'`; this repo carried three such
  orphans until they were removed.

**Grep before every commit.** The local wiring is one line inside a 400-line pbxproj diff:

```sh
git show :DapurNaura.xcodeproj/project.pbxproj | grep -n "DNLibraryLocal\|XCLocalSwiftPackageReference"
```

Anything returned must not be committed.

Expected consequence, once wired: while a ticket is in flight the committed state **does not
compile**, because the Swift code calls library APIs not yet published. It becomes valid again in a
final commit that bumps to the new version after release. By design, not a bug to fix.

## Known issues in this repo

1. **There is no DNLibrary dependency.** `packageReferences` and every
   `packageProductDependencies` list are empty, and the old orphan product dependencies and
   Frameworks entries are gone. The project builds clean in this state — it simply has no data
   layer.

   Re-adding it is the first step of the next data-layer ticket: **Add Local** →
   `../DNLibraryLocal` for development (never committed), or a published SPMDNLibrary version once
   one matches the app's code. Before that existed, this project failed with
   `Missing package product 'DNLibrary'`; if that error returns, the cause is a product dependency
   without a matching package reference.

2. **No `Package.resolved` exists**, because there is no package dependency to resolve. It comes
   back with the remote dependency, and must be committed once it does.

3. **This repo has no git remote yet**, so the push/PR half of the platform flow cannot run here.
   Commits stay local until a repo is created.

4. **Nothing consumes `AppConfig`.** The variant plumbing is verified end to end (xcconfig →
   Info.plist → built bundle), but no Swift code reads it yet, so a regression in it would be
   silent. The first caller should be the code that reinstates `DNNetworkManager.initialize`.
