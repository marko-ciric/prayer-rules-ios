import Foundation

/// What the Typikon allows on a given day, from most to least permissive.
/// `rawValue` is the strictness order, which the feast-relaxation logic in
/// `FastingRule` compares against.
enum FastLevel: Int, CaseIterable, Comparable {
    case fastFree = 0   // разрешење на сва јела
    case dairy = 1      // сиропусно — без меса, дозвољени млечни производи и јаја
    case fish = 2       // риба, вино и уље
    case wineOil = 3    // вино и уље
    case xerophagy = 4  // сухоједење — без уља
    case strict = 5     // строго уздржање

    static func < (a: FastLevel, b: FastLevel) -> Bool { a.rawValue < b.rawValue }

    var name: LocalizedText {
        switch self {
        case .fastFree:  return LocalizedText(sr: "Мрсни дан", en: "Fast-free")
        case .dairy:     return LocalizedText(sr: "Сиропусно", en: "Dairy allowed")
        case .fish:      return LocalizedText(sr: "Риба", en: "Fish allowed")
        case .wineOil:   return LocalizedText(sr: "Вино и уље", en: "Wine and oil")
        case .xerophagy: return LocalizedText(sr: "Сухоједење", en: "Xerophagy")
        case .strict:    return LocalizedText(sr: "Строги пост", en: "Strict fast")
        }
    }

    var detail: LocalizedText {
        switch self {
        case .fastFree:
            return LocalizedText(
                sr: "Нема поста — дозвољена су сва јела.",
                en: "No fast — all foods are permitted."
            )
        case .dairy:
            return LocalizedText(
                sr: "Без меса; дозвољени су млечни производи, јаја и риба.",
                en: "No meat; dairy, eggs and fish are permitted."
            )
        case .fish:
            return LocalizedText(
                sr: "Посан дан уз рибу, вино и уље.",
                en: "A fast day on which fish, wine and oil are permitted."
            )
        case .wineOil:
            return LocalizedText(
                sr: "Посан дан уз вино и уље; без рибе.",
                en: "A fast day on which wine and oil are permitted; no fish."
            )
        case .xerophagy:
            return LocalizedText(
                sr: "Сухоједење — посна јела без уља и вина.",
                en: "Xerophagy — fasting food without oil or wine."
            )
        case .strict:
            return LocalizedText(
                sr: "Строго уздржање, по могућности до вечери.",
                en: "Strict abstinence, kept until evening where possible."
            )
        }
    }
}

/// The fast for one day: the level, plus why it is what it is.
struct FastDay {
    let level: FastLevel
    /// The period or reason — "Часни пост", "Среда", "Божићне свеце".
    let reason: LocalizedText?
}

/// The Typikon's fasting rules, resolved from the day's position in the
/// year. Everything is derived — there is no per-day fasting table.
///
/// These are the general norms of the Typikon as commonly published for
/// parish use. Local practice and a spiritual father's blessing govern the
/// individual rule; the UI says so, and should keep saying so.
enum FastingRule {

    // Weekday constants, in `Calendar`'s numbering.
    private static let sunday = 1, monday = 2, tuesday = 3, wednesday = 4
    private static let thursday = 5, friday = 6, saturday = 7

    /// - Parameters:
    ///   - church: the day's Julian calendar date.
    ///   - weekday: 1 = Sunday … 7 = Saturday.
    ///   - sincePascha: days elapsed since the most recent Pascha (≥ 0).
    ///   - untilPascha: days remaining until the next Pascha (> 0).
    ///   - feasts: commemorations falling on the day.
    static func fast(
        church: ChurchDate,
        weekday: Int,
        sincePascha: Int,
        untilPascha: Int,
        feasts: [Feast]
    ) -> FastDay {
        let base = baseFast(
            church: church, weekday: weekday,
            sincePascha: sincePascha, untilPascha: untilPascha
        )

        // Holy Week and Clean Monday admit no relaxation at all. The rest of
        // Great Lent admits wine and oil for a polyeleos feast but never
        // fish, so the relaxation is floored there. The two Lenten days that
        // really do get fish — the Annunciation and Palm Sunday — are set
        // inside `baseFast` and bypass this entirely.
        guard untilPascha > 6, untilPascha != 48 else { return base }
        let floor: FastLevel = untilPascha <= 48 ? .wineOil : .fastFree

        guard let granted = feasts.compactMap(\.fastRelaxation).min() else { return base }
        let relaxation = max(granted, floor)
        guard relaxation < base.level else { return base }

        let feast = feasts.first { $0.fastRelaxation == granted }
        return FastDay(level: relaxation, reason: feast?.name ?? base.reason)
    }

    // MARK: - The cascade

    private static func baseFast(
        church: ChurchDate,
        weekday: Int,
        sincePascha: Int,
        untilPascha: Int
    ) -> FastDay {
        let m = church.month, d = church.day
        let weekend = weekday == saturday || weekday == sunday
        let strictWeekday = weekday == monday || weekday == wednesday || weekday == friday

        // ── Fast-free periods ────────────────────────────────────────────
        if sincePascha <= 7 {
            return FastDay(level: .fastFree, reason: Reason.brightWeek)
        }
        if sincePascha >= 49 && sincePascha <= 55 {
            return FastDay(level: .fastFree, reason: Reason.trinityWeek)
        }
        if (m == 12 && d >= 25) || (m == 1 && d <= 4) {
            return FastDay(level: .fastFree, reason: Reason.svjatki)
        }
        if untilPascha >= 64 && untilPascha <= 69 {
            return FastDay(level: .fastFree, reason: Reason.publicanWeek)
        }

        // ── Cheesefare week ──────────────────────────────────────────────
        if untilPascha >= 49 && untilPascha <= 55 {
            return FastDay(level: .dairy, reason: Reason.cheesefare)
        }

        // ── Great Lent and Holy Week ─────────────────────────────────────
        if untilPascha >= 1 && untilPascha <= 48 {
            return greatLentFast(church: church, untilPascha: untilPascha, weekend: weekend)
        }

        // ── Apostles' Fast: Monday after All Saints → Julian 28 June ─────
        // Pascha falls between 22 March and 25 April (Julian), so the fast
        // always lies inside May–June; the month guard keeps a date late in
        // the *previous* Paschal cycle (January, say — also 57+ days after
        // its Pascha) from matching.
        if sincePascha >= 57 && (m == 5 || (m == 6 && d <= 28)) {
            return FastDay(
                level: strictWeekday ? .xerophagy : .fish,
                reason: Reason.apostlesFast
            )
        }

        // ── Dormition Fast: Julian 1–14 August ───────────────────────────
        if m == 8 && d <= 14 {
            if d == 6 { return FastDay(level: .fish, reason: Reason.dormitionFast) }
            if d == 14 { return FastDay(level: .xerophagy, reason: Reason.dormitionFast) }
            return FastDay(
                level: strictWeekday ? .xerophagy : .wineOil,
                reason: Reason.dormitionFast
            )
        }

        // ── Nativity Fast: Julian 15 November – 24 December ──────────────
        if (m == 11 && d >= 15) || (m == 12 && d <= 24) {
            if m == 12 && d == 24 {
                return FastDay(level: .strict, reason: Reason.nativityEve)
            }
            // The last five days drop fish even on Saturday and Sunday.
            let lastStretch = (m == 12 && d >= 20)
            if strictWeekday {
                return FastDay(level: .xerophagy, reason: Reason.nativityFast)
            }
            return FastDay(
                level: lastStretch ? .wineOil : (weekend ? .fish : .wineOil),
                reason: Reason.nativityFast
            )
        }

        // ── Strict days standing outside any fasting season ──────────────
        if m == 1 && d == 5 {
            return FastDay(level: .xerophagy, reason: Reason.theophanyEve)
        }
        if m == 8 && d == 29 {
            return FastDay(level: .xerophagy, reason: Reason.beheading)
        }
        if m == 9 && d == 14 {
            return FastDay(level: .xerophagy, reason: Reason.elevation)
        }

        // ── The weekly fast ──────────────────────────────────────────────
        if weekday == wednesday {
            return FastDay(level: .xerophagy, reason: Reason.wednesday)
        }
        if weekday == friday {
            return FastDay(level: .xerophagy, reason: Reason.friday)
        }

        return FastDay(level: .fastFree, reason: nil)
    }

    private static func greatLentFast(
        church: ChurchDate,
        untilPascha: Int,
        weekend: Bool
    ) -> FastDay {
        switch untilPascha {
        case 48:
            return FastDay(level: .strict, reason: Reason.cleanMonday)
        case 8:
            return FastDay(level: .wineOil, reason: Reason.lazarusSaturday)
        case 7:
            return FastDay(level: .fish, reason: Reason.palmSunday)
        case 3:
            return FastDay(level: .wineOil, reason: Reason.holyWeek)
        case 2:
            return FastDay(level: .strict, reason: Reason.greatFriday)
        case 1:
            return FastDay(level: .xerophagy, reason: Reason.greatSaturday)
        case 4, 5, 6:
            return FastDay(level: .xerophagy, reason: Reason.holyWeek)
        default:
            // The Annunciation keeps its fish even in the middle of Lent.
            if church.month == 3 && church.day == 25 {
                return FastDay(level: .fish, reason: Reason.annunciation)
            }
            return FastDay(
                level: weekend ? .wineOil : .xerophagy,
                reason: Reason.greatLent
            )
        }
    }

    private enum Reason {
        static let brightWeek = LocalizedText(sr: "Светла седмица", en: "Bright Week")
        static let trinityWeek = LocalizedText(sr: "Тројичина седмица", en: "Trinity Week")
        static let svjatki = LocalizedText(sr: "Божићне свеце", en: "Christmastide")
        static let publicanWeek = LocalizedText(sr: "Седмица по Митару и фарисеју", en: "Week after the Publican and Pharisee")
        static let cheesefare = LocalizedText(sr: "Сиропусна седмица", en: "Cheesefare Week")
        static let greatLent = LocalizedText(sr: "Часни пост", en: "Great Lent")
        static let cleanMonday = LocalizedText(sr: "Чисти понедељак", en: "Clean Monday")
        static let lazarusSaturday = LocalizedText(sr: "Лазарева субота", en: "Lazarus Saturday")
        static let palmSunday = LocalizedText(sr: "Цвети", en: "Palm Sunday")
        static let holyWeek = LocalizedText(sr: "Страсна седмица", en: "Holy Week")
        static let greatFriday = LocalizedText(sr: "Велики петак", en: "Great Friday")
        static let greatSaturday = LocalizedText(sr: "Велика субота", en: "Great Saturday")
        static let annunciation = LocalizedText(sr: "Благовести", en: "The Annunciation")
        static let apostlesFast = LocalizedText(sr: "Петровски пост", en: "Apostles' Fast")
        static let dormitionFast = LocalizedText(sr: "Госпојински пост", en: "Dormition Fast")
        static let nativityFast = LocalizedText(sr: "Божићни пост", en: "Nativity Fast")
        static let nativityEve = LocalizedText(sr: "Бадњи дан", en: "Nativity Eve")
        static let theophanyEve = LocalizedText(sr: "Крстовдан (навечерје Богојављења)", en: "Eve of Theophany")
        static let beheading = LocalizedText(sr: "Усековање главе Св. Јована Крститеља", en: "Beheading of St John the Baptist")
        static let elevation = LocalizedText(sr: "Воздвижење Часног Крста", en: "Elevation of the Cross")
        static let wednesday = LocalizedText(sr: "Среда", en: "Wednesday")
        static let friday = LocalizedText(sr: "Петак", en: "Friday")
    }
}
