# Prayer Rules — Псалтир Светог цара Давида

A native iPhone app of the 150 Psalms of David in Serbian (Cyrillic), based on the translation by Bishop Atanasije (Jevtić) from Church Slavonic and Greek (the Septuagint) — plus an English translation from Brenton's English Septuagint (1851).

> The project/repo is named **prayer-rules**; the app itself is presented to users as **Псалтир**, since its content is the Psalter.

## Building

```
ios/App/App.xcodeproj
```

Open in Xcode (15+, iOS 15+ deployment target) and run. Swift/SwiftUI, no third-party dependencies, no WebView, iPhone only.

```
ios/App/App/
├── PrayerRulesApp.swift   # @main entry point
├── Views/                 # ContentView, PsalmListView, PsalmReaderView, etc.
├── Models/                # AppStrings (i18n copy), LanguageManager
├── Data/                  # Kathismata, OpeningLinesSr/En, NotesSr/En, FullTextSr/En
└── Extensions/            # Theme.swift (colors, font helpers)
```

`.github/workflows/build.yml` runs `xcodebuild` against the project on every push and pull request to `main`.

## Features

- All 150 psalms listed with opening line and number
- Full text for 23 of the most-used Orthodox psalms (Kathisma 1, the Hexapsalmos, Psalm 50, Psalm 90, the Liturgy and Vespers psalms, the closing praise psalms 148–150)
- Opening lines for the remaining psalms; full text can be added incrementally
- Search by text or psalm number
- Filter by kathisma (the 20 traditional Orthodox liturgical divisions)
- Adjustable font size in the reader
- Previous/next navigation between psalms
- Serbian and English, switchable in-app

Numbering follows the **Septuagint (LXX)** tradition throughout, as Orthodox usage requires. This differs from the Masoretic/KJV numbering through most of the Psalter — see `CLAUDE.md` for the mapping.

## Sources

- Serbian: translation by Епископ Атанасије (Јевтић), via [молитвеник.in.rs](https://www.molitvenik.in.rs/psaltir_index.html)
- English: Brenton's English Septuagint (1851), via [ebible.org](https://ebible.org/eng-Brenton/)

## Licence

**Application code**: MIT — see [`LICENSE`](LICENSE).

**The psalm texts are a separate matter.** The Psalms themselves are ancient and in the public domain, but a *translation* is its own copyrightable work, and the two translations here are not in the same position:

- **English** — Brenton's *English Septuagint* (1851). Brenton died in 1862, so this translation is itself in the public domain.
- **Serbian** — the translation of Bishop Atanasije (Jevtić), who died in 2021. Under Serbian copyright terms (life + 70 years) this translation is most likely still protected, and it is included here without an explicit licence from the rights holder.

If you intend to distribute this app, or to expand the Serbian text beyond what is already here, settle that permission first — the rights holder would be his estate or publisher. This note describes the situation as understood; it is not legal advice.
