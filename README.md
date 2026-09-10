# Prayer Rules

A native iPhone app built around the **Orthodox church calendar**, on the Julian reckoning the Serbian Orthodox Church keeps.

Open it and you get today: its civil and church dates, the tone of the week, the fast and what it permits, whose memory the day is, the morning and evening rule, the Hours, the kathismata appointed to be read — and the space held for the day's service, which is filled in from the Menaion as that work goes on. The calendar tab shows the fasting year as a month grid; tapping any day gives that day in full.

The Psalter — 150 psalms in Serbian (Cyrillic) in Bishop Atanasije (Jevtić)'s translation from Church Slavonic and Greek, and in Brenton's English Septuagint (1851) — is now one of the three tabs, and the Hours and the rules cite it rather than duplicating it.

> The project/repo is named **prayer-rules**. **Псалтир / Psalter** is the name of the Psalter tab and of the book, not of the app.

**This repo is mid-conversion** from a React/Vite/Capacitor web app to a **native SwiftUI, iPhone-only app**. See `CLAUDE.md` for the full status. The native app is now the primary target; the original web app is kept temporarily for reference and will be removed.

## Native iOS app

```
ios/App/App.xcodeproj
```

Open in Xcode (15+, iOS 15+ deployment target) and run. Swift/SwiftUI, no third-party dependencies, no WebView.

```
ios/App/App/
├── PrayerRulesApp.swift  # @main entry point
├── Views/                # RootTabView, TodayView, CalendarMonthView,
│                         # LiturgicalDayView, ServiceView, the Psalter screens
├── Models/               # the liturgical engine + i18n
├── Data/                 # the Menaion, the Triodion/Pentecostarion,
│                         # the rules and Hours, the Psalter text
└── Extensions/           # Theme.swift (colours, fast colours, font helpers)
```

## The calendar

Everything the calendar shows is computed, not tabulated — there is no per-day table to keep in step:

- **Dates.** All arithmetic goes through the Julian Day Number, so the Julian ("church") date and the civil (Gregorian) date are two views of the same number and can't drift apart.
- **Pascha.** Meeus's Julian algorithm, checked against 2024–2028.
- **The fast.** Derived from the day's position in the year: the four fasting seasons, the fast-free weeks, Wednesdays and Fridays, and the relaxations a feast grants — floored at wine and oil inside Great Lent, and refused outright in Holy Week.
- **The tone.** The eight-week Octoechos cycle, counted from Thomas Sunday.
- **The kathismata.** The ordinary-time distribution over the week; Great Lent and Bright Week say so instead of showing a reading that is not served.

The fasting rules shown are the general norms of the Typikon as published for parish use, and the app says as much on every day: local practice and a spiritual father's blessing govern the individual rule.

## Features

- **Today** — both dates, tone, fast, commemorations, prayer rules, the four Hours, the kathismata of the day, and the service of the day
- **Calendar** — a month grid banded by fasting rule, with a key; any day opens in full
- **Psalter** — all 150 psalms, full text for 23, search by text or number, filter by kathisma
- The Hours and the rules cite psalms; tapping a citation opens the psalm reader
- Reader font size, shared across every text screen and remembered between launches
- Serbian (Atanasije Jevtić) and English (Brenton's Septuagint), switchable in-app

## Content still being written

The calendar, the fasting rules and the fixed frame of the rules and Hours are complete. The day-proper material is not, and the app shows a labelled gap rather than a shorter service: the numbered morning and evening prayers, the Hours' troparia and closing prayers, and the services of the Menaion. Adding a commemoration is one entry in `Data/FixedFeasts.swift`; adding its service is one entry in `Data/DailyServices.swift`.

## Legacy web app (reference only)

`src/`, `android/`, and the root Vite/Capacitor config files are the original React implementation this native app was ported from. Not maintained going forward — see `CLAUDE.md`'s "Open work" for the plan to remove them.

## Source

- Serbian Psalter translation by Епископ Атанасије (Јевтић), via [молитвеник.in.rs](https://www.molitvenik.in.rs/psaltir_index.html).
- English Psalter translation: Brenton's English Septuagint (1851, public domain), via [ebible.org](https://ebible.org/eng-Brenton/).
- Prayers, troparia and the calendar follow the Serbian Orthodox Church's usage. Every liturgical text in the app should be checked against a printed molitvenik or Minej before release.

## License

Application code: MIT.
The Psalter text is a translation of public-domain scripture; please credit the translator (Bishop Atanasije Jevtić) when redistributing the Serbian text.
