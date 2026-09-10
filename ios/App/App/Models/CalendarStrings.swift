import Foundation

/// UI copy for the calendar, the Today view and the service reader.
///
/// The Psalter screens still take their strings from `AppStrings`, which
/// keeps two parallel structs. Everything added here uses `LocalizedText`
/// instead, so a string cannot be added in one language only.
enum CalendarStrings {

    // Tabs
    static let tabToday = LocalizedText(sr: "Данас", en: "Today")
    static let tabCalendar = LocalizedText(sr: "Календар", en: "Calendar")
    static let tabPsalter = LocalizedText(sr: "Псалтир", en: "Psalter")

    // Dates
    static let churchCalendar = LocalizedText(sr: "по црквеном календару", en: "on the church calendar")
    static let tone = LocalizedText(sr: "Глас", en: "Tone")
    static let today = LocalizedText(sr: "Данас", en: "Today")

    // Sections
    static let commemorations = LocalizedText(sr: "Спомен дана", en: "Commemorations")
    static let fasting = LocalizedText(sr: "Пост", en: "Fasting")
    static let prayerRules = LocalizedText(sr: "Молитвено правило", en: "Prayer rules")
    static let hours = LocalizedText(sr: "Часови", en: "The Hours")
    static let psalterOfDay = LocalizedText(sr: "Катизме дана", en: "Psalter of the day")
    static let serviceOfDay = LocalizedText(sr: "Служба дана", en: "Service of the day")

    // Kathismata
    static let matins = LocalizedText(sr: "Јутрење", en: "Matins")
    static let vespers = LocalizedText(sr: "Вечерње", en: "Vespers")
    static let kathisma = LocalizedText(sr: "Катизма", en: "Kathisma")
    static let kathismaLenten = LocalizedText(
        sr: "У Часном посту Псалтир се чита по посном поретку.",
        en: "During Great Lent the Psalter is read on the Lenten distribution."
    )
    static let kathismaBrightWeek = LocalizedText(
        sr: "У Светлој седмици Псалтир се не чита.",
        en: "The Psalter is not read during Bright Week."
    )

    // Service of the day
    static let serviceInPreparation = LocalizedText(
        sr: "Служба овог дана се припрема. Минеј се уноси постепено — тропар и кондак се појављују чим буду унети.",
        en: "The service for this day is being prepared. The Menaion is being added gradually — the troparion and kontakion appear as soon as they are entered."
    )
    static let openService = LocalizedText(sr: "Отвори службу", en: "Open the service")

    // Service reader
    static let sectionPending = LocalizedText(sr: "Текст се припрема", en: "Text in preparation")
    static let openPsalm = LocalizedText(sr: "Псалам", en: "Psalm")

    // Calendar
    static let legend = LocalizedText(sr: "Ознаке поста", en: "Fasting key")
    static let previousMonth = LocalizedText(sr: "Претходни месец", en: "Previous month")
    static let nextMonth = LocalizedText(sr: "Следећи месец", en: "Next month")
    static let jumpToToday = LocalizedText(sr: "На данашњи дан", en: "Go to today")

    // Standing note — the app states the general norm and says so plainly.
    static let fastingDisclaimer = LocalizedText(
        sr: "Правило поста дато је по општем типику. За своје правило посаветуј се са духовником.",
        en: "The fasting rule shown follows the general Typikon. For your own rule, consult your spiritual father."
    )
}
