# Prayer Rules — project guide for Claude

The 150 Psalms of David in **Serbian (Cyrillic)** and **English**, for Orthodox liturgical use: numbering and verse divisions follow the Septuagint (LXX) tradition.

**Naming**: the *project/repo* is `prayer-rules` (`marko-ciric/prayer-rules-ios`); the *app* still presents itself to users as **Псалтир / Psalter**, because its content is the Psalter. Keep that split — rename project identifiers freely, but don't touch `AppStrings.title`, `CFBundleDisplayName`, or the word "Psalter"/"Псалтир" where it names the liturgical book. If the app's scope later broadens beyond the Psalter (morning/evening prayers, canons, akathists), that's when the user-facing name should change too.

**Identifiers are English-only.** Type, property, function and file names use English (`Kathisma`, `number`, `range`, `psalms`, `openingLines`, `notes`, `fullText`, `verse`). Serbian and Church Slavonic appear **only inside string literals** — the psalm text and the `AppStrings.sr` UI copy. Don't reintroduce Serbian identifiers, and equally don't "translate" content strings: the Serbian text is Cyrillic and stays exactly as it is.

**This is a native SwiftUI, iPhone-only app** — no Capacitor, no WebView, no Android, no third-party dependencies. Everything ships from `ios/App/App/`. It began as a React/Vite/Capacitor web app; that tree was removed once the native app was merged and building, so any reference you find to `src/`, `android/`, Vite or Capacitor is describing history, not the current repo. The pre-conversion code remains in git history and in the original `marko-ciric/Psalter-Serbian-` repository.

## Native iOS app (`ios/App/App/`)

| | |
|---|---|
| Stack | Swift, SwiftUI, iOS 15+. No third-party deps, no Capacitor, no WebView. iPhone only (`TARGETED_DEVICE_FAMILY = 1`). |
| Entry point | `PrayerRulesApp.swift` (`@main`) → `ContentView` |
| State shape | `ContentView` holds `@State selected: Int?` (psalm number or nil) and `@State fontSize: CGFloat`. When `selected == nil` show `PsalmListView`, otherwise `PsalmReaderView`. Same shape as the old `App.jsx`. |
| i18n | `LanguageManager` (`ObservableObject`, injected as an `@EnvironmentObject`). `language` is `.sr` or `.en`, persisted to `UserDefaults` under key `"psalter-lang"` (same key the web app used for `localStorage`, unrelated storage). Exposes `t` (`AppStrings`), `openingLines`, `notes`, `fullText` — same shape as the old `useLanguage()`. |
| Build | Open `ios/App/App.xcodeproj` in Xcode and run. The project file was hand-authored as text in a sandbox with no macOS/Xcode toolchain, but **it has since been compiled**: CodeQL's Swift `autobuild` ran `xcodebuild` against it on a macOS runner twice, extracting 17/17 Swift files with 0 unresolved AST nodes (~464k nodes). So the pbxproj drives `xcodebuild` and every source type-checks. Not yet covered: linking, asset catalog compilation, code signing, and anything only visible at runtime. |

### Data model

Psalm content lives in plain Swift dictionaries under `ios/App/App/Data/`:

```
ios/App/App/Data/
├── Kathismata.swift     # 20 kathisma groupings — [Kathisma(number:range:psalms:)]
├── OpeningLinesSr.swift # SR opening lines, [Int: String], all 150
├── OpeningLinesEn.swift # EN opening lines, [Int: String], all 150 — Brenton, LXX-native
├── NotesSr.swift        # SR liturgical notes, [Int: String], ~30 entries
├── NotesEn.swift        # EN liturgical notes, [Int: String], ~30 entries (parity with SR)
├── FullTextSr.swift     # SR full verse-by-verse text, [Int: [String]], 23 psalms
└── FullTextEn.swift     # EN full text — Brenton's Septuagint, [Int: [String]], 23 psalms
```

These were generated mechanically rather than hand-typed, to avoid transcription errors across ~1700 lines of Cyrillic and English verse. Keep that discipline: script any future additions and verify them against the source (for the English side, cross-check each opening line against verse 1 of the corresponding full text). **Do not hand-retype verse text.**

Each `FullText*.swift` is `[Int: [String]]`: one verse per array entry, position = verse number − 1, no inscription (see "Decision history" below).

### Views (`ios/App/App/Views/`)

```
OrnamentView.swift        # decorative diamond ornament, drawn with Canvas/Path (ports the inline SVG)
DividerView.swift         # horizontal divider with center ornament
PsalmListItemView.swift   # single row in the list view
PsalmListView.swift       # search + kathisma filter + scrollable list + header/footer + language toggle
PsalmReaderView.swift     # full-text reader with drop cap, font controls, prev/next navigation
ContentView.swift         # root view, holds `selected` and `fontSize`
```

`PsalmListView` builds its `allPsalms` array fresh from `lang.openingLines`/`lang.fullText` (computed property, not cached) — recomputed on each access. `PsalmReaderView` falls back to a "not yet available" panel when `lang.fullText[number]` is nil.

`Theme.swift` (`ios/App/App/Extensions/`) holds hardcoded Color constants approximating the web app's Tailwind amber/stone/red palette, plus `Theme.display()`/`Theme.serif()` font helpers. **Those font helpers currently return system serif-design fonts, not the actual Cormorant Garamond / EB Garamond faces** the web app used — see Open work below.

### Known simplifications

- **Fonts**: using `.system(design: .serif)` instead of the real Cormorant Garamond (display) / EB Garamond (body) faces. The web app loaded these from Google Fonts; the native app needs the actual `.ttf`/`.otf` files bundled and registered via `Info.plist`'s `UIAppFonts` key. Not done yet.
- **Drop cap**: the web reader used a CSS float so body text wrapped around the oversized first letter. SwiftUI has no direct equivalent, so `PsalmReaderView` renders the drop cap and the rest of verse 1 side-by-side in an `HStack` instead — visually close but not a true wrap.
- **App Icon / Splash**: still the original Capacitor default placeholders (blue ✕ on grid), untouched by this conversion. Must be replaced before any TestFlight/App Store submission.
- **No router**: `selected` is transient `@State`, so backgrounding/relaunching the app returns to the list. That's intentional, matching the original no-router decision.

## The psalm texts

### The two translations, and LXX vs MT numbering

**Serbian** is Bishop Atanasije (Jevtić)'s translation from Church Slavonic and Greek (Septuagint). Sourced from molitvenik.in.rs.

**English** is **Brenton's English Septuagint (1851, public domain)**, sourced from `https://ebible.org/eng-Brenton/PSAnnn.htm`.

Both translations use **LXX/Orthodox numbering**:

| LXX (this app) | KJV/MT |
|---|---|
| Ps 1–8 | Ps 1–8 |
| Ps 9 | Ps 9 + Ps 10 (LXX keeps one acrostic; MT splits it) |
| Ps 10–112 | Ps 11–113 (off by one through the middle) |
| Ps 113 | Ps 114 + Ps 115 (LXX merges) |
| Ps 114 + Ps 115 | Ps 116 (LXX splits) |
| Ps 116–145 | Ps 117–146 (off by one again) |
| Ps 146 + Ps 147 | Ps 147 (LXX splits) |
| Ps 148–150 | Ps 148–150 |

If you ever need to reference a KJV Bible, this matters. Brenton handles it natively; KJV does not.

Inscriptions ("A Psalm of David…") are **not numbered** in the data files. Brenton numbers them as verses 1 (or 1–2) in the source; the fetcher script strips them so the body starts at array index 0 = verse 1 in display. This convention carries over unchanged into the native `FullText*.swift` files.

### Tooling: Brenton fetcher

`/tmp/brenton_fetch.py` (not checked into the repo) is the script that fetched and parsed Brenton's psalms from ebible.org. Notable quirks it handles:

- Verse markers can sit in `<div class='d'>` (inscription) but the body continues in the following `<div class='p'>`. The parser tracks `current_verse` across div boundaries but only buffers text while inside a 'p' div, then drops verses with empty body (pure inscriptions).
- Footnote anchors (`<a class="notemark">`) have nested `<span class="popup">` tooltip text that must be skipped along with the asterisk marker.
- Italicized translator additions (`<span class='add'>`) and small-caps spans are unwrapped (text kept, markup dropped).

To re-run for additional psalms, edit the `PSALMS` list at the top of the script and re-run. It used to emit a JS module for the old web tree; with that gone, have it emit Swift dictionary literals straight into `FullTextEn.swift`.

## Open work

### Done recently
- **Converted the app to native SwiftUI, iPhone-only.** Full port of the list view, reader and i18n, plus all psalm data (150 opening lines x 2 languages, 23 full-text psalms x 2 languages, 30 liturgical notes x 2 languages, 20 kathismata). Removed the Capacitor/WebView plumbing from the Xcode project and restricted the target to iPhone.
- **Added `xcodebuild` build CI** (see Secondary polish), so build regressions surface directly rather than being inferred from CodeQL's autobuild.
- **Regenerated `OpeningLinesEn.swift` from Brenton** instead of KJV. The full text and footer had credited Brenton since the translation switch while the list view still showed KJV openings remapped onto LXX numbers -- the app credited one translation and displayed another. Verified by checking that each new opening line is an exact prefix of verse 1 of the committed full text (23/23).
- **Renamed all Serbian identifiers to English** (`Kathisma`, `number`, `openingLines`, `fullText`, ...). Verified content-safe: all 1032 quoted strings byte-identical across the rename.
- **Deleted the legacy web app** -- `src/`, `android/` and the Vite/Capacitor config files, 76 files and ~6.5k lines. It existed only as a parity reference for the port; that use is spent.
- **Corrected the README licence wording**, which had described the psalm text as "a translation of public-domain scripture" -- see Decision history.

### Highest-priority remaining work

1. **Open `ios/App/App.xcodeproj` in real Xcode and run it on a simulator.** The code is known to compile (see the Build row), so what's left to confirm is runtime behaviour and layout — the drop cap, the kathisma chips, the font clamp, the SR/EN toggle — not whether it builds.
2. **Rename the Xcode target from `App` to `PrayerRules`** — do this *in Xcode* (select the target → Identity and Type → Name, and let Xcode's rename refactor update the scheme, product name, and paths), not by hand-editing the pbxproj. `App` is a leftover Capacitor-generated name; it was deliberately left alone during the prayer-rules rename because renaming a target blind, with no way to build and check, risks breaking the project for cosmetic gain. Xcode does it safely in seconds. The bundle identifier is already `rs.prayerrules.app`.
3. **Bundle the real Cormorant Garamond / EB Garamond fonts** and wire them up via `Info.plist`'s `UIAppFonts`, replacing the `Theme.display()`/`Theme.serif()` system-font stand-ins.
4. **Fill in the remaining 127 psalms** (currently 23/150 have full text). The two languages are blocked on different things, and neither is a coding problem:
   - **English** is unblocked — extend the Brenton fetcher to all 150 and emit into `FullTextEn.swift`. Watch LXX 9, 113, 114, 115, 146, 147, the LXX/MT split boundaries.
   - **Serbian** is blocked on **permission**, not availability: the Jevtić translation is most likely under copyright until ~2091 (see Decision history). Adding the remaining 127 would put the complete translated Psalter in a public repo. Get a licence from the estate or publisher first.
   - **Church Slavonic** was explored as a public-domain alternative. Encoding is *solved* — molitvenik.in.rs's psalter PDF is in the legacy UCS codepage, and the `cslavonic` Python package (MIT, from the Slavonic Computing Initiative) decodes it completely: 54 ASCII stand-ins plus 13 further characters, zero residual, genuine punctuation preserved. It is blocked on **structure**: neither that PDF nor the Initiative's `AugmentedPsalter.txt` (native Unicode) delimits all 150 psalms — 80 and 95 psalm markers respectively — and neither marks verse divisions at all. Both are continuous-reading liturgical editions. Do not infer the missing boundaries; get a per-psalm edition. azbyka.ru appears to have one but returns 403 to scripted requests.
5. **iOS App Icon and Splash** — replace the Capacitor-era placeholders before any TestFlight/App Store submission. Needs design input.

### Secondary polish
- **Code scanning runs via GitHub's CodeQL default setup**, configured in repo settings rather than in-repo. There is deliberately no `.github/workflows/codeql.yml`: an advanced-config workflow cannot upload results while default setup is enabled, so the one inherited from `Psalter-Serbian-` was removed. Don't re-add a CodeQL *workflow* without first switching the repo from default to advanced setup — note that `build.yml` is a plain build lane, not a CodeQL config, so it does not conflict. Adding it also gives default setup's `actions` language something to analyse; that scan had been failing with "CodeQL could not process any code written in GitHub Actions" from the moment the repo had no workflow files at all.
- **Build CI**: `.github/workflows/build.yml` runs `xcodebuild` against `ios/App/App.xcodeproj` on a `macos-latest` runner for every push and PR to `main`. It builds with `-alltargets` rather than `-scheme` on purpose — no scheme is checked into the project, and Xcode's auto-generated schemes don't exist on a fresh CI checkout. `-alltargets` also survives the pending rename of the `App` target (Open Work item 2) without needing an edit. Code signing is disabled (`CODE_SIGNING_ALLOWED=NO`); this checks that the app compiles and links, not that it can be distributed.
- No tests. Consider a small XCTest/XCUITest smoke test (list renders, language toggle works, font controls clamp) once the app builds.

## Conventions and small things

- Serbian display uses Cyrillic exclusively. Don't transliterate.
- Brenton uses "Pause." where KJV uses "Selah." — keep as-is.
- The reader's drop cap uses the first character of verse 1 (`verse.first`). If verse 1 starts with punctuation or a digit this will look wrong; verify when adding new psalms.
- The font-size range is clamped `[14, 28]` in `PsalmReaderView.swift`. Don't add a slider without adjusting bounds in both call sites (the two buttons).
- When you add a new UI string, add it to **both** `AppStrings.sr` and `AppStrings.en` in `Strings.swift` — there's no fallback.

## Decision history

- **2026-09**: Regenerated `OpeningLinesEn.swift` from Brenton instead of KJV. The full text and the in-app footer had said Brenton since the 2026-06 switch, but the opening lines shown in the list view were still KJV manually remapped onto LXX numbers — so the app credited one translation and displayed another, and the remap was exactly the thing the 2026-06 entry calls unfixable at the split boundaries. Verified by checking that, for all 23 psalms whose Brenton full text is already committed, each new opening line is an exact prefix of that text's verse 1 (23/23). Inscriptions stay excluded, matching `FullTextEn.swift`.
- **2026-09**: Deleted the legacy web app (`src/`, `android/`, and the Vite/Capacitor config files) — 76 files, ~6.5k lines. It had been kept only as a parity reference for the native port; with the port merged, building in CI and its data verified, the reference had no remaining use and its presence made the repo look like a live web project. The history is preserved in git and in the original `Psalter-Serbian-` repository.
- **2026-09**: Corrected the `README` licence wording, which claimed the psalm text was "a translation of public-domain scripture". That conflated two different things: the Psalms are public domain, but a translation is a separate copyrightable work. Brenton (d. 1862) is public domain; Bishop Atanasije (Jevtić) died in 2021, so the Serbian translation is most likely protected until roughly 2091 and is present without an explicit licence. Settle permission before distributing or expanding the Serbian text.
- **2026-09**: Removed the inherited CodeQL workflow. Making `prayer-rules-ios` public auto-enabled code scanning **default setup**, and GitHub refuses SARIF from an advanced-config workflow while default setup owns scanning, so `.github/workflows/codeql.yml` failed on every run. Default setup covers Swift, so deleting the workflow lost no coverage. Its `javascript-typescript` half targeted the legacy web app that is slated for deletion anyway.
- **2026-09**: Project moved to its own repository, `marko-ciric/prayer-rules-ios`, and renamed to **prayer-rules** at the project level only — `PsaltirApp` → `PrayerRulesApp`, bundle id `rs.psalter.app` → `rs.prayerrules.app`, docs retitled. The user-facing app name stayed **Псалтир/Psalter** deliberately: the content is the Psalter, so the displayed title is accurate; the broader "prayer rules" name anticipates future scope (morning/evening prayers, canons) rather than describing what ships today. The original `Psalter-Serbian-` repo still holds the pre-move history. Not a GitHub fork — forks can't target the same owner — but a new repo carrying the full history, merged with its own initial commit (MIT LICENSE + Xcode `.gitignore`).
- **2026-09**: Converted from React/Vite/Capacitor web app (wrapped for iOS + Android) to a native SwiftUI, iPhone-only app. Reason: user requested Xcode/iPhone-only distribution with no web/WebView layer. The web app and Android wrapper are kept temporarily for reference and will be deleted once the native app builds successfully.
- **2026-06**: English translation switched from KJV (with manual LXX renumber) → Brenton's Septuagint (1851). Reason: at the LXX/MT split boundaries (Ps 9, 113, 114, 115, 146, 147) the KJV remap is unfixable — KJV's verse divisions don't carve up the same way LXX does. Brenton translates directly from the Greek the Orthodox tradition uses, so verse numbers and divisions match Atanasije natively.
- **2026-06**: Confirmed inscriptions ("A Psalm of David…") are dropped from the verse arrays — matching the Atanasije source convention and avoiding awkward verse-1 content.
