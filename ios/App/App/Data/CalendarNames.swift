import Foundation

/// Month and weekday names, written out rather than taken from
/// `DateFormatter`. Serbian display is Cyrillic-only, and the system's
/// Serbian locale is not guaranteed to be Cyrillic on the user's phone; the
/// church-calendar dates are also plain Julian numbers with no `Calendar`
/// behind them, so there is nothing for a formatter to format.
enum CalendarNames {

    /// Nominative — the month standing on its own, as a calendar heading.
    static let months: [LocalizedText] = [
        LocalizedText(sr: "јануар", en: "January"),
        LocalizedText(sr: "фебруар", en: "February"),
        LocalizedText(sr: "март", en: "March"),
        LocalizedText(sr: "април", en: "April"),
        LocalizedText(sr: "мај", en: "May"),
        LocalizedText(sr: "јун", en: "June"),
        LocalizedText(sr: "јул", en: "July"),
        LocalizedText(sr: "август", en: "August"),
        LocalizedText(sr: "септембар", en: "September"),
        LocalizedText(sr: "октобар", en: "October"),
        LocalizedText(sr: "новембар", en: "November"),
        LocalizedText(sr: "децембар", en: "December"),
    ]

    /// Genitive — Serbian takes the genitive after a day number
    /// ("10. септембра"), where English does not change the word.
    static let monthsInDate: [LocalizedText] = [
        LocalizedText(sr: "јануара", en: "January"),
        LocalizedText(sr: "фебруара", en: "February"),
        LocalizedText(sr: "марта", en: "March"),
        LocalizedText(sr: "априла", en: "April"),
        LocalizedText(sr: "маја", en: "May"),
        LocalizedText(sr: "јуна", en: "June"),
        LocalizedText(sr: "јула", en: "July"),
        LocalizedText(sr: "августа", en: "August"),
        LocalizedText(sr: "септембра", en: "September"),
        LocalizedText(sr: "октобра", en: "October"),
        LocalizedText(sr: "новембра", en: "November"),
        LocalizedText(sr: "децембра", en: "December"),
    ]

    /// Indexed 1 = Sunday … 7 = Saturday, to match `Calendar`'s numbering.
    static let weekdays: [LocalizedText] = [
        LocalizedText(sr: "", en: ""),
        LocalizedText(sr: "недеља", en: "Sunday"),
        LocalizedText(sr: "понедељак", en: "Monday"),
        LocalizedText(sr: "уторак", en: "Tuesday"),
        LocalizedText(sr: "среда", en: "Wednesday"),
        LocalizedText(sr: "четвртак", en: "Thursday"),
        LocalizedText(sr: "петак", en: "Friday"),
        LocalizedText(sr: "субота", en: "Saturday"),
    ]

    /// Column headings of the month grid, Monday first.
    static let weekdayInitials: [LocalizedText] = [
        LocalizedText(sr: "По", en: "Mon"),
        LocalizedText(sr: "Ут", en: "Tue"),
        LocalizedText(sr: "Ср", en: "Wed"),
        LocalizedText(sr: "Че", en: "Thu"),
        LocalizedText(sr: "Пе", en: "Fri"),
        LocalizedText(sr: "Су", en: "Sat"),
        LocalizedText(sr: "Не", en: "Sun"),
    ]

    static func monthName(_ month: Int, _ language: Language) -> String {
        guard (1...12).contains(month) else { return "" }
        return months[month - 1].text(language)
    }

    static func weekdayName(_ weekday: Int, _ language: Language) -> String {
        guard (1...7).contains(weekday) else { return "" }
        return weekdays[weekday].text(language)
    }

    /// "10. септембра 2026." / "10 September 2026"
    static func longDate(_ d: ChurchDate, _ language: Language) -> String {
        guard (1...12).contains(d.month) else { return "" }
        let month = monthsInDate[d.month - 1].text(language)
        return language == .en
            ? "\(d.day) \(month) \(d.year)"
            : "\(d.day). \(month) \(d.year)."
    }

    /// "28. август" / "28 August" — the church date, without the year, which
    /// is how it is printed beside the civil date.
    static func shortDate(_ d: ChurchDate, _ language: Language) -> String {
        guard (1...12).contains(d.month) else { return "" }
        let month = monthsInDate[d.month - 1].text(language)
        return language == .en ? "\(d.day) \(month)" : "\(d.day). \(month)"
    }
}
