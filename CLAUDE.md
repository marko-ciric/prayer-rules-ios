# Prayer Rules — project guide for Claude

An Orthodox **church-calendar** app for iPhone, on the **Julian** reckoning the Serbian Orthodox Church keeps. The day is the organising unit: Today shows both dates, the tone, the fast, the commemorations, the prayer rules, the Hours, the kathismata appointed, and the space held for the day's service; the Calendar shows the fasting year as a month grid and opens any day in full. The Psalter — 150 psalms in **Serbian (Cyrillic)** and **English**, LXX numbering and verse divisions — is one of the three tabs, and the Hours and rules cite it rather than duplicating it.

**Naming**: the *project/repo* is `prayer-rules` (`marko-ciric/prayer-rules-ios`). **Псалтир / Psalter** now names the Psalter *tab* and the book, not the app — the 2026-09 calendar redesign is exactly the broadening of scope the old naming note anticipated. `AppStrings.title`/`subtitle` are the Psalter tab's own header and stay as they are; `CFBundleDisplayName` is still `Псалтир` and should be revisited with the user before release, since the app is now more than the Psalter.

**Identifiers are English-only.** Type, property, function and file names use English (`Kathisma`, `number`, `range`, `psalms`, `openingLines`, `notes`, `fullText`, `verse`). Serbian and Church Slavonic appear **only inside string literals** — the psalm text and the `AppStrings.sr` UI copy. Don't reintroduce Serbian identifiers, and equally don't "translate" content strings: the Serbian text is Cyrillic and stays exactly as it is.

**This repo is mid-conversion.** The app used to be a React/Vite/Capacitor web app wrapped for iOS. It is being converted to a **native SwiftUI, iPhone-only app** (no Capacitor, no WebView, no Android). The native app lives under `ios/App/App/` and is now the primary target — read that section first. The original web app under `src/`, `android/`, and the root Vite/Capacitor config files (`index.html`, `vite.config.js`, `tailwind.config.js`, `postcss.config.js`, `package.json`, `capacitor.config.json`) are **kept only as a reference/parity check** during the transition and are slated for deletion once the native app has been reviewed and built successfully in Xcode — don't add new features to them.

## Native iOS app (`ios/App/App/`)

| | |
|---|---|
| Stack | Swift, SwiftUI, iOS 15+. No third-party deps, no Capacitor, no WebView. iPhone only (`TARGETED_DEVICE_FAMILY = 1`). |
| Entry point | `PrayerRulesApp.swift` (`@main`) → `ContentView` |
| State shape | `ContentView` owns two `@StateObject`s injected into everything — `LanguageManager` and `ReaderSettings` (the shared, persisted reader font size) — and hands off to `RootTabView`. Each tab holds its own navigation state; full-screen readers are presented through one `ReaderRoute` cover rather than several stacked `.fullScreenCover` modifiers. |
| i18n | `LanguageManager` (`ObservableObject`, injected as an `@EnvironmentObject`). `language` is `.sr` or `.en`, persisted to `UserDefaults` under key `"psalter-lang"` (same key the web app used for `localStorage`, unrelated storage). Exposes `t` (`AppStrings`), `openingLines`, `notes`, `fullText` — same shape as the old `useLanguage()`. |
| Build | Open `ios/App/App.xcodeproj` in Xcode and run. The pbxproj is hand-authored text, but it is known to drive `xcodebuild`: CodeQL's Swift `autobuild` compiled the pre-redesign tree (17/17 files, 0 unresolved AST nodes). **The 23 files added by the calendar redesign have not been through a compiler** — this sandbox has no Swift toolchain, and `build.yml` only runs on `main` and on PRs into it, so a feature-branch push does not exercise it. Open a PR (or run `xcodebuild` locally) before trusting the branch. |

### The liturgical engine (`ios/App/App/Models/`)

Everything the calendar shows is **computed**, not tabulated — there is no per-day table to keep in step, and the whole engine is pure value types with no Foundation date maths beyond one `Date` → JDN bridge.

```
LocalizedText.swift    # { sr, en } + text(_:) — see the i18n note in Conventions
OrthodoxCalendar.swift # JDN ↔ Gregorian ↔ Julian, weekday, Paschalion
Feast.swift            # Feast + FeastRank (commemoration/major/great/pascha)
FastingRule.swift      # FastLevel + the cascade that resolves a day's fast
LiturgicalDay.swift    # LiturgicalSeason, KathismaReading, the composed day
Service.swift          # ServiceBlock/ServiceSection/Service — rules, Hours, services
ReaderSettings.swift   # shared, persisted reader font size
CalendarStrings.swift  # UI copy for the calendar surfaces, as LocalizedText
```

Points worth knowing before changing any of it:

- **All date arithmetic goes through the Julian Day Number.** The Julian ("church") date and the civil (Gregorian) date are two renderings of the same integer, so they cannot drift. `OrthodoxCalendar.weekday(fromJDN:)` derives the weekday from the JDN too, rather than from `Calendar`, for the same reason.
- **Pascha** is Meeus's Julian algorithm, which yields a *Julian* calendar date; feeding it through `jdn(julianYear:...)` makes the 13-day offset fall out for free. Verified against 2024–2028.
- **`FastingRule` is an ordered cascade**, first match wins: fast-free periods → Cheesefare → Great Lent and Holy Week → Apostles' → Dormition → Nativity → the fixed strict days → the weekly Wednesday and Friday. Then a feast's `fastRelaxation` is applied *only if it is less strict*, **floored at wine and oil inside Great Lent** (a polyeleos feast in Lent gets oil, never fish) and refused outright in Holy Week and on Clean Monday. The Annunciation and Palm Sunday get their fish from inside the cascade, which is why they bypass that floor.
- **The Apostles' Fast needs its month guard.** `sincePascha >= 57` is also true of dates in January that belong to the *previous* Paschal cycle; the `m == 5 || (m == 6 && d <= 28)` clause is what keeps February out of the fast. Don't remove it.
- **The tone** is the eight-week Octoechos cycle counted from Thomas Sunday, turning continuously (through Pentecost, through Lent) and set aside in Bright and Holy Week.
- **Kathismata** use the ordinary-time weekly distribution; Great Lent and Bright Week return nil, and the UI says why, rather than showing a reading that is not served.
- These are the **general norms of the Typikon** as published for parish use. `CalendarStrings.fastingDisclaimer` says so on every day; keep it on screen.

A Python port of the whole engine, checked against independently known dates (Pascha 2024–2028, Julian↔civil for Божић/Савиндан/Видовдан, and ~30 fasting days), lives in the session scratchpad rather than the repo. If you change the cascade, re-derive it rather than trusting the Swift by eye — there is no Swift toolchain here.

### Calendar and service data (`ios/App/App/Data/`)

```
CalendarNames.swift   # month (nominative + genitive) and weekday names, both languages
FixedFeasts.swift     # the Menaion — keyed by month*100+day on the JULIAN calendar
MovableFeasts.swift   # Triodion (days before Pascha) + Pentecostarion (days after)
CommonPrayers.swift   # the beginning, the Creed, the Theotokia, the dismissal
Hours.swift           # the four Little Hours — psalms cited, not copied
PrayerRules.swift     # the morning and evening rule
DailyServices.swift   # the space for the Menaion; keyed by Feast.id, near-empty by design
```

`FixedFeasts` is a working selection, not the whole Menaion: the Twelve Great Feasts, the days a Serbian household keeps as a slava, and the commemorations carrying their own service. **Adding an entry is the whole change** — the calendar, the fasting rule and the Service of the day all pick it up.

Content that has not been transcribed is `ServiceBlock.pending(…)` carrying the name the prayer is known by, so the app renders a *labelled gap* rather than a service that looks complete and isn't. The seeded troparia in `FixedFeasts`/`MovableFeasts` are the widely printed ones; **every liturgical text in the app should be checked against a printed molitvenik or Minej before release.**

### Psalter data

Mirrors the old `src/data/` structure, transcribed 1:1 (verse text and verse counts are unchanged) into Swift under `ios/App/App/Data/`:

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

These were generated mechanically from the JS source (via a Node script that imported the ES modules and dumped JSON, then a Python script that emitted Swift dictionary literals) rather than hand-typed, specifically to avoid transcription errors across ~1700 lines of Cyrillic/English verse text. If you need to regenerate them (e.g. after adding more psalms to the web-side data first), the same approach is the fastest safe path — do not hand-retype verse text.

Each `FullText*.swift` is `[Int: [String]]`: one verse per array entry, position = verse number − 1, no inscription (same convention as the web app — see "Decision history" below).

### Views (`ios/App/App/Views/`)

```
ContentView.swift         # root — owns LanguageManager + ReaderSettings, hands off to the tabs
RootTabView.swift         # the three tabs: Today, Calendar, Psalter
TodayView.swift           # today, plus the language toggle
CalendarMonthView.swift   # month grid banded by fast, with the selected day beneath it
LiturgicalDayView.swift   # ONE day, in full — rendered by both Today and Calendar
FastBadgeView.swift       # the day's fast, stated; plus the grid's small band
ServiceView.swift         # reader for a rule, an Hour, or a service
ReaderRoute.swift         # the single full-screen cover the day screens open through
LanguageToggleView.swift  # SR / EN, shared by Today and the Psalter list
OrnamentView.swift        # decorative diamond ornament, drawn with Canvas/Path (ports the inline SVG)
DividerView.swift         # horizontal divider with center ornament
PsalmListItemView.swift   # single row in the list view
PsalmListView.swift       # search + kathisma filter + scrollable list + header/footer
PsalmReaderView.swift     # full-text reader with drop cap, font controls, prev/next navigation
```

`LiturgicalDayView` is the point of the whole arrangement: Today and Calendar render the *same* view for a different day, so the two can never disagree about what a day contains. The month grid never signals with colour alone — every cell also carries an accessibility label naming the date, the fast and the feast, and the day view spells the rule out in words.

`PsalmListView` builds its `allPsalms` array fresh from `lang.openingLines`/`lang.fullText` (computed property, not cached) — same "always fresh" behavior as the React version's `useMemo`. `PsalmReaderView` falls back to a "not yet available" panel when `lang.fullText[number]` is nil.

`Theme.swift` (`ios/App/App/Extensions/`) holds hardcoded Color constants approximating the web app's Tailwind amber/stone/red palette, plus `Theme.display()`/`Theme.serif()` font helpers. **Those font helpers currently return system serif-design fonts, not the actual Cormorant Garamond / EB Garamond faces** the web app used — see Open work below.

### Known simplifications vs. the web app

- **Fonts**: using `.system(design: .serif)` instead of the real Cormorant Garamond (display) / EB Garamond (body) faces. The web app loaded these from Google Fonts; the native app needs the actual `.ttf`/`.otf` files bundled and registered via `Info.plist`'s `UIAppFonts` key. Not done yet.
- **Drop cap**: the web reader used a CSS float so body text wrapped around the oversized first letter. SwiftUI has no direct equivalent, so `PsalmReaderView` renders the drop cap and the rest of verse 1 side-by-side in an `HStack` instead — visually close but not a true wrap.
- **App Icon / Splash**: still the original Capacitor default placeholders (blue ✕ on grid), untouched by this conversion. Must be replaced before any TestFlight/App Store submission.
- **No router**: still transient `@State` per tab, so backgrounding and relaunching returns to Today. Intentional; the calendar always opens on the current day, which is the right place to land.
- **Menaion content**: `DailyServices.byFeast` is empty. The Today view falls back to the feast's troparion/kontakion where one is seeded and otherwise shows a labelled "in preparation" panel. This is the redesign's main open content surface.
- **The prayer rules are a frame, not a text.** The beginning, the Creed, Psalm 50, the Theotokia and the dismissal are complete; the numbered morning and evening prayers, the Hours' troparia and their closing prayers are `.pending` placeholders naming what belongs there.

## Legacy web app (`src/`, `android/`) — reference only, pending deletion

The original React 18 + Vite + Tailwind + Capacitor app. Kept temporarily so the native rewrite can be checked against it line-by-line; do not extend it. Its own historical documentation:

| | |
|---|---|
| Stack | React 18, Vite 5, Tailwind 3, lucide-react. No router. No tests. |
| Entry point | `src/main.jsx` → `<App />` (`src/App.jsx`) |
| i18n | `src/i18n/LanguageContext.jsx`, same `T` object the native `AppStrings.swift` was transcribed from. |
| Data | `src/data/*.js` + `src/data/en/*.js` — the source the native `Data/*.swift` files were generated from. |
| Components | `src/components/*.jsx` — the source the native `Views/*.swift` files were ported from. |

### The two translations and the LXX vs MT numbering question

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

To re-run for additional psalms, edit the `PSALMS` list at the top of the script and re-run. The output is a JS module that drops into `src/data/en/puniTekst.js` — and, since the native data files are generated from the JS source (see above), should be re-transcribed into `FullTextEn.swift` afterward.

## Open work

### Done in the most recent session
- **Rebuilt the app around the church calendar** (see the top of this file). Added a computed liturgical engine — Julian/Gregorian conversion, the Paschalion, the Octoechos tone, the kathisma distribution, and a fasting cascade covering the four fasting seasons, the fast-free weeks, the weekly Wednesday and Friday and the feast relaxations — plus the Menaion/Triodion/Pentecostarion data, the morning and evening rules, the four Little Hours, and three tabs (Today, Calendar, Psalter) over a shared `LiturgicalDayView`. 23 new Swift files, all registered in the pbxproj. The arithmetic was verified via a Python port against independently known dates; **the Swift itself has not been compiled** — see the Build row.
- Moved the reader font size out of `ContentView`'s `@State` into a persisted `ReaderSettings` shared by every text screen.

### Done in earlier sessions
- **Converted the app to native SwiftUI, iPhone-only** (see top of this file). Added `ios/App/App/{PrayerRulesApp,Views,Models,Data,Extensions}` with a full port of the list view, reader, i18n, and all psalm data (150 opening lines × 2 languages, 23 full-text psalms × 2 languages, 30 liturgical notes × 2 languages, 20 katizme). Removed the Capacitor/WebView plumbing from the `ios/App` Xcode project (AppDelegate, Main.storyboard, the `CapApp-SPM` Swift package dependency) and restricted the target to iPhone only.
- Left `src/`, `android/`, and the root Vite/Capacitor config files in place as a reference during the transition (see "Legacy web app" above) — **delete these once the native app has been opened and built successfully in Xcode.**
- Previously (prior session): switched English full text from KJV to **Brenton's English Septuagint** for the 23 existing psalms (1–8, 46, 50, 85, 89, 90, 101–103, 134, 136, 140, 142, 148–150).

### Highest-priority remaining work

0. **Build it.** The 23 new files have never seen a compiler. Open a PR (which runs `build.yml` on a macOS runner) or run `xcodebuild -project ios/App/App.xcodeproj -alltargets -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build` locally, and fix what falls out before anything else.
1. **Check the liturgical texts against print.** Every troparion in `FixedFeasts`/`MovableFeasts` and every prayer in `CommonPrayers` should be read against a printed molitvenik/Minej. Getting a prayer subtly wrong is worse than leaving the gap.
2. **Open `ios/App/App.xcodeproj` in real Xcode and run it on a simulator** — the month grid at small widths, the fast colours in bright light, the drop cap, the font clamp, the SR/EN toggle.
3. **Rename the Xcode target from `App` to `PrayerRules`** — do this *in Xcode* (select the target → Identity and Type → Name, and let Xcode's rename refactor update the scheme, product name, and paths), not by hand-editing the pbxproj. `App` is a leftover Capacitor-generated name; it was deliberately left alone during the prayer-rules rename because renaming a target blind, with no way to build and check, risks breaking the project for cosmetic gain. Xcode does it safely in seconds. The bundle identifier is already `rs.prayerrules.app`.
4. **Delete the legacy web app** (`src/`, `android/`, `index.html`, `vite.config.js`, `tailwind.config.js`, `postcss.config.js`, `package.json`, `package-lock.json`, `capacitor.config.json`) once the native app is confirmed working, and update `README.md` accordingly.
5. **Bundle the real Cormorant Garamond / EB Garamond fonts** and wire them up via `Info.plist`'s `UIAppFonts`, replacing the `Theme.display()`/`Theme.serif()` system-font stand-ins.
6. **Fill in the remaining 127 psalms** in both languages (currently 23/150 have full text) — same source material as before (molitvenik.in.rs for SR, extending the Brenton fetcher for EN), transcribed into `FullTextSr.swift`/`FullTextEn.swift`. Pay attention at LXX 9, 113, 114, 115, 146, 147 — the LXX/MT split boundaries.
7. **Fill in the Menaion and the prayer rules** — `DailyServices.byFeast` for services, `FixedFeasts` for more commemorations, and the `.pending` blocks in `PrayerRules`/`Hours`. This is meant to be incremental: one entry at a time, no other change.
8. **iOS App Icon and Splash** — replace the Capacitor-era placeholders before any TestFlight/App Store submission. Needs design input.

### Secondary polish
- **Code scanning runs via GitHub's CodeQL default setup**, configured in repo settings rather than in-repo. There is deliberately no `.github/workflows/codeql.yml`: an advanced-config workflow cannot upload results while default setup is enabled, so the one inherited from `Psalter-Serbian-` was removed. Don't re-add a CodeQL *workflow* without first switching the repo from default to advanced setup — note that `build.yml` is a plain build lane, not a CodeQL config, so it does not conflict. Adding it also gives default setup's `actions` language something to analyse; that scan had been failing with "CodeQL could not process any code written in GitHub Actions" from the moment the repo had no workflow files at all.
- **Build CI**: `.github/workflows/build.yml` runs `xcodebuild` against `ios/App/App.xcodeproj` on a `macos-latest` runner for every push and PR to `main`. It builds with `-alltargets` rather than `-scheme` on purpose — no scheme is checked into the project, and Xcode's auto-generated schemes don't exist on a fresh CI checkout. `-alltargets` also survives the pending rename of the `App` target (Open Work item 3) without needing an edit. Code signing is disabled (`CODE_SIGNING_ALLOWED=NO`); this checks that the app compiles and links, not that it can be distributed.
- No tests. Consider a small XCTest/XCUITest smoke test (list renders, language toggle works, font controls clamp) once the app builds.

## Conventions and small things

- Serbian display uses Cyrillic exclusively. Don't transliterate.
- Brenton uses "Pause." where KJV uses "Selah." — keep as-is.
- The reader's drop cap uses the first character of verse 1 (`verse.first`). If verse 1 starts with punctuation or a digit this will look wrong; verify when adding new psalms.
- The font-size range is clamped `[14, 28]` in `PsalmReaderView.swift`. Don't add a slider without adjusting bounds in both call sites (the two buttons).
- **New UI strings use `LocalizedText`**, in `CalendarStrings.swift` (or beside the data they belong to). The type takes `sr` and `en` together, so a one-language string is a compile error — which the old arrangement could not catch. The Psalter screens still read from `AppStrings` in `Strings.swift`; if you add a string *there*, it still has to go into both `AppStrings.sr` and `AppStrings.en`, because that pair has no fallback.
- `LocalizedText` deliberately exposes a plain `text(_:)` method rather than `callAsFunction`. `feast.name(language)` reads better but leans on `callAsFunction` resolving through a member access, and nothing here can compile-check that.
- Julian dates in `FixedFeasts.swift` are **Julian**. Божић is 25 December there and 7 January on screen. Never "fix" a date by adding thirteen days.

## Decision history

- **2026-09**: Rebuilt the app around the **church calendar**, at the user's request: the app is more than psalm reading and the Hours, so the day became the organising unit — Today (rules, Hours, kathismata, and a held space for the service), a Calendar carrying the fasting rules, and the Psalter demoted to one of three tabs. Two decisions inside that are worth keeping: the calendar is **computed, not tabulated** (a fasting table would be another 365-row artefact to maintain and to get wrong), and missing content is a **visible, labelled gap** rather than a silent omission (`ServiceBlock.pending`), because a prayer rule that looks complete and isn't is worse than one that admits what it is missing. `LocalizedText` was introduced at the same time so a new string cannot exist in one language only.

- **2026-09**: Regenerated `OpeningLinesEn.swift` from Brenton instead of KJV. The full text and the in-app footer had said Brenton since the 2026-06 switch, but the opening lines shown in the list view were still KJV manually remapped onto LXX numbers — so the app credited one translation and displayed another, and the remap was exactly the thing the 2026-06 entry calls unfixable at the split boundaries. Verified by checking that, for all 23 psalms whose Brenton full text is already committed, each new opening line is an exact prefix of that text's verse 1 (23/23). Inscriptions stay excluded, matching `FullTextEn.swift`.
- **2026-09**: Removed the inherited CodeQL workflow. Making `prayer-rules-ios` public auto-enabled code scanning **default setup**, and GitHub refuses SARIF from an advanced-config workflow while default setup owns scanning, so `.github/workflows/codeql.yml` failed on every run. Default setup covers Swift, so deleting the workflow lost no coverage. Its `javascript-typescript` half targeted the legacy web app that is slated for deletion anyway.
- **2026-09**: Project moved to its own repository, `marko-ciric/prayer-rules-ios`, and renamed to **prayer-rules** at the project level only — `PsaltirApp` → `PrayerRulesApp`, bundle id `rs.psalter.app` → `rs.prayerrules.app`, docs retitled. The user-facing app name stayed **Псалтир/Psalter** deliberately: the content is the Psalter, so the displayed title is accurate; the broader "prayer rules" name anticipates future scope (morning/evening prayers, canons) rather than describing what ships today. The original `Psalter-Serbian-` repo still holds the pre-move history. Not a GitHub fork — forks can't target the same owner — but a new repo carrying the full history, merged with its own initial commit (MIT LICENSE + Xcode `.gitignore`).
- **2026-09**: Converted from React/Vite/Capacitor web app (wrapped for iOS + Android) to a native SwiftUI, iPhone-only app. Reason: user requested Xcode/iPhone-only distribution with no web/WebView layer. The web app and Android wrapper are kept temporarily for reference and will be deleted once the native app builds successfully.
- **2026-06**: English translation switched from KJV (with manual LXX renumber) → Brenton's Septuagint (1851). Reason: at the LXX/MT split boundaries (Ps 9, 113, 114, 115, 146, 147) the KJV remap is unfixable — KJV's verse divisions don't carve up the same way LXX does. Brenton translates directly from the Greek the Orthodox tradition uses, so verse numbers and divisions match Atanasije natively.
- **2026-06**: Confirmed inscriptions ("A Psalm of David…") are dropped from the verse arrays — matching the Atanasije source convention and avoiding awkward verse-1 content.
