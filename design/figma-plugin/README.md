# Prayer Rules → Figma

A development plugin that builds the app's screens as **native Figma layers** —
auto-layout frames, editable text, and a shared colour style library — rather
than importing a flat picture of them.

It is a reverse-engineering of `ios/App/App/`, not a redraw: the palette comes
from `Extensions/Theme.swift`, the strings are the Swift literals, and the
calendar data baked into `code.js` was produced by the app's own engine (11
September 2026 / 29 August on the church calendar — Усековање, a Friday, глас
5, xerophagy).

## Run it

Figma **desktop** app (plugins can't be loaded from the browser):

1. `Plugins → Development → Import plugin from manifest…`
2. Pick `design/figma-plugin/manifest.json`
3. `Plugins → Development → Prayer Rules — Screens`

It builds three 390 × 844 artboards side by side and adds the `Theme/…` and
`Fast/…` paint styles to the file.

## What it makes

| Frame | Source |
|---|---|
| `Данас — Today` | `Views/TodayView.swift` + `LiturgicalDayView.swift` |
| `Календар — Calendar` | `Views/CalendarMonthView.swift` |
| `Први час — ServiceView` | `Views/ServiceView.swift` + `Data/Hours.swift` |

Plus paint styles for every colour in `Theme.swift`, including the parchment
gradient and the six `FastLevel` band colours — each band layer is named after
the case it came from (`fast band — .xerophagy`), so the calendar reads as the
fasting year rather than as decoration.

## Fonts

The app *intends* Cormorant Garamond (display) and EB Garamond (body); it
currently ships system serif, and bundling the real faces remains open work in
`CLAUDE.md`. The plugin tries to load both and falls back to Inter with a
notice if Figma doesn't have them — so what you see is the target state, not
what a simulator would show today.

Both Garamonds need Cyrillic coverage. If the Serbian text renders as boxes,
the fallback is the fix: delete the frames, disable those families in Figma,
and re-run.

## The other route

If you only want the screens *in* Figma and don't need them as editable
layers, the published HTML study imports directly with the **html.to.design**
plugin — paste the artifact URL. Faster, and closer pixel-for-pixel, but you
get a DOM translation rather than clean auto-layout.

## Keeping it honest

This file duplicates values that live in Swift. When `Theme.swift` or a screen
changes, `code.js` does not follow automatically — treat it as a design
deliverable that gets regenerated, not as a second source of truth. The Swift
is the source of truth.
