import Foundation

/// Where in the year a day falls. Drives the season line under the date and
/// decides whether the Octoechos tone and the kathisma table apply at all.
enum LiturgicalSeason {
    case brightWeek
    case pentecostarion   // Thomas Sunday → Ascension
    case afterAscension   // Ascension → Pentecost
    case afterPentecost   // the long stretch, into the following winter
    case preLent          // Publican and Pharisee → Cheesefare Sunday
    case greatLent        // Clean Monday → Palm Sunday
    case holyWeek         // Great Monday → Great Saturday
}

/// Which kathismata are appointed at Matins and at Vespers.
///
/// Vespers belongs to the *following* liturgical day, so the reading listed
/// here for a civil day is the one served on that day's evening — which is
/// how printed parish calendars set it out.
struct KathismaReading {
    let matins: [Int]
    let vespers: [Int]
}

/// One day of the church year, fully resolved: civil and church dates, the
/// tone, the fast, the commemorations, the Psalter reading.
struct LiturgicalDay: Identifiable {
    let jdn: Int
    let date: Date
    let civil: ChurchDate
    let church: ChurchDate
    /// 1 = Sunday … 7 = Saturday.
    let weekday: Int
    let daysSincePascha: Int
    let daysUntilPascha: Int
    let season: LiturgicalSeason
    /// Octoechos tone (глас) 1–8, or nil in Bright and Holy Week where the
    /// Octoechos is set aside.
    let tone: Int?
    let fast: FastDay
    /// Commemorations, most prominent first.
    let feasts: [Feast]
    /// nil during Great Lent (which has its own distribution) and Bright
    /// Week (which has none).
    let kathismata: KathismaReading?

    var id: Int { jdn }

    var isToday: Bool { jdn == OrthodoxCalendar.jdn(from: Date()) }

    /// The commemoration the Service of the day follows.
    var principalFeast: Feast? { feasts.first }

    // MARK: - Construction

    static func make(jdn: Int) -> LiturgicalDay {
        let civil = OrthodoxCalendar.civilDate(fromJDN: jdn)
        let church = OrthodoxCalendar.churchDate(fromJDN: jdn)
        let weekday = OrthodoxCalendar.weekday(fromJDN: jdn)

        let paschaThisYear = OrthodoxCalendar.paschaJDN(civilYear: civil.year)
        let current = jdn >= paschaThisYear
            ? paschaThisYear
            : OrthodoxCalendar.paschaJDN(civilYear: civil.year - 1)
        let next = jdn >= paschaThisYear
            ? OrthodoxCalendar.paschaJDN(civilYear: civil.year + 1)
            : paschaThisYear

        let since = jdn - current
        let until = next - jdn

        let season = self.season(since: since, until: until)
        let feasts = commemorations(church: church, since: since, until: until)
        let fast = FastingRule.fast(
            church: church, weekday: weekday,
            sincePascha: since, untilPascha: until, feasts: feasts
        )

        return LiturgicalDay(
            jdn: jdn,
            date: OrthodoxCalendar.date(fromJDN: jdn),
            civil: civil,
            church: church,
            weekday: weekday,
            daysSincePascha: since,
            daysUntilPascha: until,
            season: season,
            tone: tone(since: since, season: season),
            fast: fast,
            feasts: feasts,
            kathismata: kathismaReading(weekday: weekday, season: season)
        )
    }

    static func make(date: Date) -> LiturgicalDay {
        make(jdn: OrthodoxCalendar.jdn(from: date))
    }

    // MARK: - Derived pieces

    private static func season(since: Int, until: Int) -> LiturgicalSeason {
        // The pre-Paschal reckoning wins: a date can be both 300 days after
        // one Pascha and 60 days before the next.
        if until <= 6 { return .holyWeek }
        if until <= 48 { return .greatLent }
        if until <= 70 { return .preLent }
        if since <= 6 { return .brightWeek }
        if since <= 38 { return .pentecostarion }
        if since <= 48 { return .afterAscension }
        return .afterPentecost
    }

    /// The Octoechos runs in an eight-week cycle whose first week begins on
    /// Thomas Sunday (Pascha + 7). It simply keeps turning from there —
    /// through Pentecost, through Great Lent — until the next Holy Week.
    private static func tone(since: Int, season: LiturgicalSeason) -> Int? {
        guard season != .brightWeek, season != .holyWeek else { return nil }
        let week = since / 7
        guard week >= 1 else { return nil }
        return (week - 1) % 8 + 1
    }

    private static func commemorations(church: ChurchDate, since: Int, until: Int) -> [Feast] {
        var all = MovableFeasts.feasts(sincePascha: since, untilPascha: until)
        all += FixedFeasts.feasts(month: church.month, day: church.day)
        // Stable sort: rank descending, original order preserved within a rank.
        return all.enumerated()
            .sorted { a, b in
                a.element.rank == b.element.rank
                    ? a.offset < b.offset
                    : a.element.rank > b.element.rank
            }
            .map { $0.element }
    }

    /// The ordinary-time distribution of the Psalter over the week. Great
    /// Lent reads the whole Psalter twice a week on a different table, and
    /// Bright Week reads none at all, so both return nil rather than show a
    /// reading that is not served.
    private static func kathismaReading(weekday: Int, season: LiturgicalSeason) -> KathismaReading? {
        switch season {
        case .brightWeek, .greatLent, .holyWeek:
            return nil
        default:
            break
        }
        switch weekday {
        case 1: return KathismaReading(matins: [2, 3], vespers: [])
        case 2: return KathismaReading(matins: [4, 5], vespers: [6])
        case 3: return KathismaReading(matins: [7, 8], vespers: [9])
        case 4: return KathismaReading(matins: [10, 11], vespers: [12])
        case 5: return KathismaReading(matins: [13, 14], vespers: [15])
        case 6: return KathismaReading(matins: [19, 20], vespers: [18])
        default: return KathismaReading(matins: [16, 17], vespers: [1])
        }
    }
}

extension LiturgicalDay {
    /// "15. недеља по Духовима", "3. недеља Часног поста" — the line that
    /// sits under the date beside the tone.
    var seasonLabel: LocalizedText {
        switch season {
        case .brightWeek:
            return LocalizedText(sr: "Светла седмица", en: "Bright Week")
        case .holyWeek:
            return LocalizedText(sr: "Страсна седмица", en: "Holy Week")
        case .greatLent:
            let week = (48 - daysUntilPascha) / 7 + 1
            return LocalizedText(
                sr: "\(week). седмица Часног поста",
                en: "Week \(week) of Great Lent"
            )
        case .preLent:
            return LocalizedText(sr: "Припрема за Часни пост", en: "Pre-Lenten weeks")
        case .pentecostarion, .afterAscension:
            let week = daysSincePascha / 7
            return LocalizedText(
                sr: "\(week). седмица по Васкрсу",
                en: "Week \(week) after Pascha"
            )
        case .afterPentecost:
            guard daysSincePascha >= 56 else {
                return LocalizedText(sr: "Педесетница", en: "Pentecost")
            }
            let week = (daysSincePascha - 49) / 7
            return LocalizedText(
                sr: "\(week). седмица по Духовима",
                en: "Week \(week) after Pentecost"
            )
        }
    }
}
