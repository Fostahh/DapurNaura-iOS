#!/usr/bin/env bash
#
# repin.sh — move the app onto a published SPMDNLibrary version, and prove that it moved.
#
# DN-037. Run this after a release, from anywhere:
#
#     scripts/repin.sh 0.8.0
#
# It does the mechanical half of the repin. It does not decide that a repin should happen, and it
# does not commit — both stay with whoever ran the release (DN-027).
#
# ---------------------------------------------------------------------------------------------
# Why this exists, in one paragraph.
#
# `xcodebuild -resolvePackageDependencies` honours Package.resolved and will not move past it, and
# xcodebuild has no update flag — Xcode's *Update to Latest Package Versions* is the supported way
# to move a range forward, and an agent cannot use a menu. Deleting Package.resolved and resolving
# looks like the command-line equivalent, and mostly is, except that SPM may answer out of a cached
# clone that never fetched the new tag. When it does, **the resolve succeeds on the old version**:
# no error, a well-formed Package.resolved, exit 0. And because the file then matches what was
# already committed, `git status` comes back clean — which reads as "nothing to do", one short
# inference away from DN-030's true statement that a repin needs no project-file edit.
#
# That happened on the 0.8.0 repin (2026-08-10). What caught it was luck: the release added API the
# new screen called, so a stale 0.7.0 failed to compile. A behaviour-only release has no such net.
#
# **The assertion below is the point of this script.** Clearing caches is something a person has to
# remember; checking the number afterwards needs no memory at all.
# ---------------------------------------------------------------------------------------------

set -euo pipefail

readonly SCHEME="DapurNaura Dev"
readonly PACKAGE_NAME="SPMDNLibrary"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly repo_root
readonly PROJECT="$repo_root/DapurNaura.xcodeproj"
readonly RESOLVED="$PROJECT/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

die() { printf '\n\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
step() { printf '\n\033[1m▶ %s\033[0m\n' "$*"; }

wanted="${1:-}"
[[ -n "$wanted" ]] || die "Usage: scripts/repin.sh <version>   e.g. scripts/repin.sh 0.8.0"
[[ -d "$PROJECT" ]] || die "No Xcode project at $PROJECT"

# The range the project declares. Printed only when the assertion fails, where it is the most
# likely explanation — a version outside it can never be resolved to, however clean the caches are.
declared_range() {
    awk '/XCRemoteSwiftPackageReference/,/};/' "$PROJECT/project.pbxproj" \
        | grep -E 'kind|minimumVersion|maximumVersion|version' \
        | sed 's/^[[:space:]]*/    /' || true
}

# ------------------------------------------------------------------ 1. clear the stale answers --
# **Four** places can hold one, and the fourth is the one that actually decided the answer the first
# time this script was run: DerivedData/SourcePackages/workspace-state.json records the resolved
# version, and xcodebuild restores from it even with Package.resolved deleted and every
# org.swift.swiftpm cache cleared. The script was written without it, asked for 0.8.0, resolved to
# 0.7.0 — and the assertion below is what caught that. Known issue 5 listed SourcePackages only
# under a *missing symbol* symptom; it decides versions too.
step "Clearing every cache that can answer with a stale version"
spm_cache="$HOME/Library/Caches/org.swift.swiftpm"
rm -rf "$spm_cache/repositories/${PACKAGE_NAME}-"* 2>/dev/null || true
rm -rf "$spm_cache/artifacts/"*"$PACKAGE_NAME"* 2>/dev/null || true
rm -rf "$HOME/Library/Developer/Xcode/DerivedData/DapurNaura-"*/SourcePackages 2>/dev/null || true
rm -f "$RESOLVED"
echo "   cached clone, downloaded artifact, DerivedData/SourcePackages and Package.resolved removed"

# --------------------------------------------------------------------------------- 2. resolve --
step "Resolving package dependencies"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -resolvePackageDependencies >/dev/null \
    || die "Resolve failed. If it mentions a 404, the release asset is missing or the repository is private."

[[ -f "$RESOLVED" ]] || die "Resolve produced no Package.resolved"

# --------------------------------------------------------------------------------- 3. the point --
# Read the pin back out rather than trusting that the resolve did what was asked.
got_version="$(grep -A3 '"version"' "$RESOLVED" | grep -m1 -o '"version" : "[^"]*"' | sed 's/.*: "//; s/"//')"
got_revision="$(grep -m1 -o '"revision" : "[^"]*"' "$RESOLVED" | sed 's/.*: "//; s/"//')"

step "Verifying the resolved version"
if [[ "$got_version" != "$wanted" ]]; then
    printf '   asked for : %s\n   resolved  : %s\n\n   The project declares:\n%s\n' \
        "$wanted" "${got_version:-<none>}" "$(declared_range)" >&2
    die "Resolved to the wrong version. A resolve that succeeds is not a repin that worked."
fi
echo "   version  : $got_version"
echo "   revision : $got_revision"
echo "   ↳ this must be the commit the ${wanted} tag points at. A tag and a commit came apart once"
echo "     before (0.5.0, 2026-08-08); confirm it with:"
echo "     git -C ../SPMDNLibrary rev-list -n1 ${wanted}"

# ----------------------------------------------------------------------------------- 4. build --
# A resolve proves the version is available. Only a build proves the app compiles against it.
step "Building against $wanted"
simulator_id="${SIMULATOR_ID:-$(xcrun simctl list devices available | grep -m1 -oE '\(([0-9A-F-]{36})\)' | tr -d '()')}"
[[ -n "$simulator_id" ]] || die "No available simulator found. Set SIMULATOR_ID to one from 'xcrun simctl list devices available'."

# By id **and** arch. Known issue 2 is that several 18.3.1 runtimes publish one device as both
# arm64 and x86_64, and the XCFramework has no x86_64 slice — an id alone still leaves xcodebuild
# choosing between two destinations and merely warning about it.
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$simulator_id,arch=arm64" build >/dev/null \
    || die "Build failed against $wanted."

printf '\n\033[32m✅ Repinned to %s and building.\033[0m\n' "$wanted"
echo "   Package.resolved is the only file that changed — project.pbxproj declares a range and"
echo "   needs no edit while $wanted falls inside it (DN-030)."
echo
echo "   xcodebuild may also have normalised project.pbxproj cosmetically — it strips empty"
echo "   'exceptions = ()' blocks. That is churn, not a repin: revert it before committing."
echo
echo "   Not committed. Review the diff and commit it yourself:"
echo "     git -C \"$repo_root\" diff -- DapurNaura.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
