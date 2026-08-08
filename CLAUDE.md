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

**Two screens exist:** the cooking-class list (DN-009) and the class detail (DN-012), both fed by
`DNLibrary`'s `DNDataLayer.stub()` (contract replay; no backend exists yet). The recipe screen is a
placeholder. Everything else — the real recipe screen, video, payment, any notion of a signed-in
user — is still to build.

## Project shape

SwiftUI, an Xcode project (not an SPM package). **How the code is organised, and the rules it must
follow, live in [`docs/CODEBASE-ARCHITECTURE.md`](docs/CODEBASE-ARCHITECTURE.md)** — §3 owns the
folder layout, §4 navigation, §5 the composition root. Read it before adding a file; it is not
repeated here.

The entry points worth naming:

- **`DapurNaura/App/DapurNauraApp.swift`** — `@main` and the **composition root**: builds
  `DNDataLayer.stub()`, constructs the `ViewModelFactory` and owns the `DapurNauraAppRouter`.
  Swapping stub → live `DNDataLayer(config:)` happens here, and only here, when a backend exists.
- **`DapurNaura/App/DapurNauraAppConfig.swift`** — reads build-variant values out of `Info.plist`, see
  [Build variants](#build-variants). **Still uncalled** — the stub path needs no URL or key. Its
  first caller is the live-backend switch, which must also replace the stale RAWG `API_BASE_URL`
  in the xcconfigs.

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
`DapurNaura/Info.plist` → `DapurNauraAppConfig.swift` reads it via
`Bundle.main.object(forInfoDictionaryKey:)`. Never read Info.plist directly elsewhere; add an
accessor to `DapurNauraAppConfig` instead.

`DapurNauraAppConfig` **fails loudly** on a missing value, including the case where the substitution never
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
Create it by hand with those two lines; `DapurNauraAppConfig` prints exactly that if it is missing.

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

## Data layer — wired locally (DN-009); no published version yet

The app consumes **DNLibrary** (KMP, built in `../../DNLibrary`) as a binary. Since DN-009 the
working tree points at the **local package** `../DNLibraryLocal`; that wiring lives only in the
uncommitted `project.pbxproj` diff. The **committed** state has no package dependency at all and
therefore does not compile — expected under the local package rule, and it stays that way until
the first `publish-spm.sh publish` produces a remote version to pin.

Swift-side bridging notes (SKIE): Kotlin `description` surfaces as `description_`; sealed results
switch exhaustively via `onEnum(of:)`; the suspend use case is `try await useCase.invoke()`;
companion functions read `DNDataLayer.companion.stub()`.

### The rules below are ACTIVE

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

1. **The committed state does not compile** — the Swift code imports DNLibrary but the committed
   `project.pbxproj` names no package dependency. Expected (local package rule) until the first
   published SPMDNLibrary version is pinned in a final commit, together with `Package.resolved`.
   If `Missing package product 'DNLibrary'` appears, the cause is a product dependency without a
   matching package reference.

2. **`DNLibrary.xcframework` carries no x86_64 simulator slice** — it is built for `iosArm64` and
   `iosSimulatorArm64` only. A build aimed at `-destination 'generic/platform=iOS Simulator'`
   therefore fails on the x86_64 pass with *"is missing architecture(s) required by this target
   (x86_64)"*, even though the arm64 pass compiles and links cleanly. **Name a concrete
   Apple-silicon simulator** in `-destination` instead of the generic one.

   *(The former known issue 2 — a 26.2 deployment target with no matching simulator runtime — is
   gone: DN-013 lowered the target to 17.0, and an iOS 26.3 runtime was installed in the meantime.)*

3. **Nothing is merged.** The remote is `github.com/Fostahh/DapurNaura-iOS`, and the ticket branches
   are stacked on each other rather than on `main` — `DN-003 → DN-009 → DN-013 → DN-012 → DN-014 →
   DN-015`. Merge their PRs in that order. On `main` the app is still a SwiftUI shell with build
   variants and no data layer.

4. **Nothing consumes `DapurNauraAppConfig`.** The variant plumbing is verified end to end, but the stub
   data path needs no URL or key, so `DapurNauraAppConfig` stays uncalled until the live-backend switch —
   a regression in it would currently be silent.
