import Foundation

/// A date on the Julian ("church") calendar.
struct ChurchDate: Equatable {
    let year: Int
    let month: Int
    let day: Int
}

/// Date arithmetic for the Orthodox liturgical year.
///
/// The Serbian Orthodox Church keeps the **Julian** calendar, so every fixed
/// commemoration in `FixedFeasts.swift` is stored by its Julian month/day and
/// converted to the phone's civil (Gregorian) date only for display. All
/// arithmetic here routes through the Julian Day Number, which is
/// calendar-agnostic and makes both the conversion and the Pascha-relative
/// day offsets exact — no `DateComponents` rounding, no time zones.
enum OrthodoxCalendar {

    // MARK: - Julian Day Number

    /// JDN of a (proleptic) Gregorian calendar date.
    static func jdn(gregorianYear y: Int, month m: Int, day d: Int) -> Int {
        let a = (14 - m) / 12
        let yy = y + 4800 - a
        let mm = m + 12 * a - 3
        return d + (153 * mm + 2) / 5 + 365 * yy + yy / 4 - yy / 100 + yy / 400 - 32045
    }

    /// JDN of a Julian calendar date.
    static func jdn(julianYear y: Int, month m: Int, day d: Int) -> Int {
        let a = (14 - m) / 12
        let yy = y + 4800 - a
        let mm = m + 12 * a - 3
        return d + (153 * mm + 2) / 5 + 365 * yy + yy / 4 - 32083
    }

    /// The Julian ("church") calendar date for a JDN.
    static func churchDate(fromJDN j: Int) -> ChurchDate {
        let c = j + 32082
        let d = (4 * c + 3) / 1461
        let e = c - (1461 * d) / 4
        let m = (5 * e + 2) / 153
        return ChurchDate(
            year: d - 4800 + m / 10,
            month: m + 3 - 12 * (m / 10),
            day: e - (153 * m + 2) / 5 + 1
        )
    }

    /// The Gregorian (civil) calendar date for a JDN.
    static func civilDate(fromJDN j: Int) -> ChurchDate {
        let a = j + 32044
        let b = (4 * a + 3) / 146097
        let c = a - (146097 * b) / 4
        let d = (4 * c + 3) / 1461
        let e = c - (1461 * d) / 4
        let m = (5 * e + 2) / 153
        return ChurchDate(
            year: 100 * b + d - 4800 + m / 10,
            month: m + 3 - 12 * (m / 10),
            day: e - (153 * m + 2) / 5 + 1
        )
    }

    // MARK: - Bridging to Foundation

    private static let gregorian: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone.current
        return c
    }()

    static func jdn(from date: Date) -> Int {
        let c = gregorian.dateComponents([.year, .month, .day], from: date)
        return jdn(gregorianYear: c.year ?? 1970, month: c.month ?? 1, day: c.day ?? 1)
    }

    static func date(fromJDN j: Int) -> Date {
        let civil = civilDate(fromJDN: j)
        var c = DateComponents()
        c.year = civil.year
        c.month = civil.month
        c.day = civil.day
        c.hour = 12 // midday, so DST shifts can never move the day
        return gregorian.date(from: c) ?? Date()
    }

    /// 1 = Sunday … 7 = Saturday, matching `Calendar.component(.weekday:)`.
    /// Derived from the JDN so it never disagrees with the rest of the maths:
    /// JDN 0 was a Monday.
    static func weekday(fromJDN j: Int) -> Int {
        (j + 1) % 7 + 1
    }

    // MARK: - Paschalion

    /// JDN of Orthodox Pascha in the given civil year (Meeus's Julian
    /// algorithm — it yields the *Julian* calendar date, which we then turn
    /// into a JDN so that the 13-day offset falls out automatically).
    static func paschaJDN(civilYear year: Int) -> Int {
        let a = year % 4
        let b = year % 7
        let c = year % 19
        let d = (19 * c + 15) % 30
        let e = (2 * a + 4 * b - d + 34) % 7
        let month = (d + e + 114) / 31      // 3 = March, 4 = April
        let day = (d + e + 114) % 31 + 1
        return jdn(julianYear: year, month: month, day: day)
    }
}
