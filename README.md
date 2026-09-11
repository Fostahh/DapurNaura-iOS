# DapurNaura — iOS

The iPhone app for **Dapur Naura**, built so the owner's family can teach their paid cooking classes
(*kelas*) online. Browse classes → open one to see its recipes → open a recipe for its ingredients
(*bahan-bahan*), the step-by-step method and a how-to video.

SwiftUI, MVVM over a Kotlin Multiplatform data layer. All content is Bahasa Indonesia and there is
no localisation planned.

> One repository in the [Dapur Naura platform](https://github.com/Fostahh/DapurNaura-Platform)
> workspace, which is **not** a monorepo. Workflow, tickets and the release flow are defined there.

> **Source of truth.** For *what was asked for*, `../../docs/requirements/` wins — over the code, over any other
> document, over a commit message. Where no requirement exists, **the ticket is the source of truth**
> and its `## Rationale` carries the why.
>
> This governs **intent**, not facts. For *what the code does today*, believe the code. When intent
> and implementation disagree, the implementation is what is wrong: record the correction in the
> **ticket**, never by editing the requirement.

## Features

What runs today, against stub data, in the order a user meets it:

- **Login** (DN-040) — **it authenticates nobody.** Any email and any password get in; the only gate
  is that neither box is empty. There is no session and nothing survives a relaunch
- **Kelas Online / Kelas Offline** (DN-033) — the choice the app opens onto once past login
- **Class list** (DN-009) — image, name, description, price in rupiah, recipe count, purchase-status
  badge, and a category filter applied **by the server** rather than over the list on screen (DN-025)
- **Class detail** (DN-012) — the class and the recipes it teaches, with a buy button whose
  behaviour follows the purchase state
- **Recipe** (DN-021) — ingredients, method and video, modelled as a list of components so each part
  of a recipe can be prepared separately
- **Offline class schedule** (DN-036) — upcoming in-person classes out to the end of next month,
  by month, with availability shown as a phrase and a colour rather than colour alone
- **Three purchase states, not two** — bought, awaiting verification, not bought. The middle one
  deliberately shows *no* buy button: someone who has already transferred money and is shown one may
  conclude the transfer failed and send it twice
- **Locked recipes are inert rather than hidden** — and their ingredients, method and video were
  never sent by the server, so `purchaseStatus` is a hint, never a gate

Not built yet: video playback, payment, and **any notion of a signed-in user** — the login screen
above is the visible half of that gap and closes none of it.

**Light mode and portrait only** (DN-039), enforced in all four build configurations. A screen
designed for dark mode is wasted work, and nothing rotates.

*Screens are listed with the ticket that built them and no count, deliberately — a number here goes
stale on the next merge and nothing forces anyone to update it.*

**There is no backend.** The app runs on `DNDataLayer.stub()`, which replays the approved contract
fixtures through the library's real decoding path.

## Tech stack

| | |
| --- | --- |
| Language | Swift |
| UI | SwiftUI, iOS 17.0+ |
| Pattern | MVVM — `@Observable` view models, `private(set)` state |
| Concurrency | Swift Concurrency (`async`/`await`, `.task`) |
| Data | [DNLibrary](https://github.com/Fostahh/DNLibrary) — Kotlin Multiplatform, consumed as a binary via [SPMDNLibrary](https://github.com/Fostahh/SPMDNLibrary) |
| Navigation | One `NavigationStack` per flow, bound to an owned path; flows swapped at the root |
| Configuration | `.xcconfig` per build variant |
| Linting | SwiftLint, with custom rules enforcing this repo's architecture document |

## Architecture

```
View  →  ViewModel  →  DNLibrary use case  →  (stub | HTTP)
```

Dependencies point inward only. The app is a **rendering layer over a tested library** — that is the
whole design, and the rules follow from it:

- **No repository or use-case layer in Swift, ever.** DNLibrary already is that layer; rebuilding it
  here is the standard KMP duplication mistake — two places to change, one of them untested.
- **A ViewModel consumes; it does not compute or format.** Anything derived from data — prices,
  error wording — lives in DNLibrary, so Android inherits the same answers instead of rewording them.
- **`DapurNauraApp` is the only place that knows `DNDataLayer` exists.** Screens receive a
  `ViewModelFactory`, never the data layer.
- **Navigation is decided at screen level.** Nothing below it may name a `Route`.

**The folder layout, and the reason behind every rule, is in
[`docs/CODEBASE-ARCHITECTURE.md`](docs/CODEBASE-ARCHITECTURE.md) §3.** It is not repeated here — one
description of the structure, in the document that governs it. Build variants, secrets, the local
package rule and known issues: [`CLAUDE.md`](CLAUDE.md).

## Build & run

Schemes are **per variant** — there is no plain `DapurNaura` scheme, and the space in the name means
they must be quoted:

```sh
xcodebuild -list -project DapurNaura.xcodeproj
xcrun simctl list devices available          # get the simulator's id

xcodebuild -project DapurNaura.xcodeproj -scheme "DapurNaura Dev" \
  -destination 'platform=iOS Simulator,id=<simulator-uuid>' build
```

**Every change to this project is built before it is offered for review** — build only, no simulator
run, and `** BUILD SUCCEEDED **` or it is not finished (DN-034).

| Variant | Backend | Logging | Audience |
| --- | --- | --- | --- |
| Development | staging | on | developers — Xcode only |
| Alpha | staging | on | family, via TestFlight |
| Beta | production | off | family and selected users, via TestFlight |
| Release | production | off | App Store |

Alpha is the earlier, less stable tier; Beta comes after it.

⚠️ **Pass the simulator's `id`, never a bare device name.** The XCFramework has no x86_64 slice, so
`generic/platform=iOS Simulator` fails on the x86_64 pass even though arm64 builds cleanly — and
several runtimes publish the same device *name* for both architectures, so `name=iPhone 16 Pro` is
ambiguous and makes `xcodebuild` print the device list instead of building. See known issue 2 in
[`CLAUDE.md`](CLAUDE.md).

## Requirements

- Xcode, with an Apple-silicon iOS simulator runtime
- **`DapurNaura/Config/Secrets.xcconfig`**, which is gitignored and must be created by hand with
  `STAGING_API_KEY` and `PROD_API_KEY`. The app fails loudly with those exact instructions if it is
  missing.
- A local build of DNLibrary. During development the app builds against `../DNLibraryLocal`,
  produced by `DNLibrary/scripts/publish-spm.sh local`. **That wiring is never committed** — see
  [`CLAUDE.md`](CLAUDE.md), which also explains why the committed state does not compile between a
  library change and its release.
