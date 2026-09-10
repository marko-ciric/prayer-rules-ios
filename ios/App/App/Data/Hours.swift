import Foundation

/// The Little Hours. Each is three psalms with propers around them, and the
/// psalms are cited rather than copied — the Psalter is already in the app,
/// so `.psalm(5)` opens the same reader the Psalter tab uses.
///
/// The psalms and the shape are fixed and complete. The propers that change
/// with the day — the troparion and kontakion of the day, the Lenten
/// troparia with their prostrations — are marked `.pending` and are filled
/// in from the Menaion as that work goes on.
enum Hours {

    static let all: [Service] = [first, third, sixth, ninth]

    static let first = hour(
        id: "hour-1",
        title: LocalizedText(sr: "Први час", en: "First Hour"),
        subtitle: LocalizedText(sr: "Око седам часова ујутро", en: "About the seventh hour of the morning"),
        psalms: [5, 89, 100],
        closingPrayer: LocalizedText(sr: "Молитва Првога часа", en: "Prayer of the First Hour")
    )

    static let third = hour(
        id: "hour-3",
        title: LocalizedText(sr: "Трећи час", en: "Third Hour"),
        subtitle: LocalizedText(sr: "Силазак Светога Духа на апостоле", en: "The descent of the Holy Spirit upon the apostles"),
        psalms: [16, 24, 50],
        closingPrayer: LocalizedText(sr: "Молитва Трећега часа", en: "Prayer of the Third Hour")
    )

    static let sixth = hour(
        id: "hour-6",
        title: LocalizedText(sr: "Шести час", en: "Sixth Hour"),
        subtitle: LocalizedText(sr: "Распеће Господње", en: "The Crucifixion of the Lord"),
        psalms: [53, 54, 90],
        closingPrayer: LocalizedText(sr: "Молитва Шестога часа", en: "Prayer of the Sixth Hour")
    )

    static let ninth = hour(
        id: "hour-9",
        title: LocalizedText(sr: "Девети час", en: "Ninth Hour"),
        subtitle: LocalizedText(sr: "Смрт Господња на Крсту", en: "The death of the Lord upon the Cross"),
        psalms: [83, 84, 85],
        closingPrayer: LocalizedText(sr: "Молитва Деветога часа", en: "Prayer of the Ninth Hour")
    )

    /// All four hours have the same skeleton; only the psalms and the closing
    /// prayer differ, so it is built once.
    private static func hour(
        id: String,
        title: LocalizedText,
        subtitle: LocalizedText,
        psalms: [Int],
        closingPrayer: LocalizedText
    ) -> Service {
        Service(
            id: id,
            title: title,
            subtitle: subtitle,
            sections: [
                ServiceSection(
                    id: "\(id)-beginning",
                    title: LocalizedText(sr: "Почетак", en: "The beginning"),
                    blocks: CommonPrayers.beginning
                ),
                ServiceSection(
                    id: "\(id)-psalms",
                    title: LocalizedText(sr: "Псалми часа", en: "Psalms of the Hour"),
                    blocks: psalms.map { ServiceBlock.psalm($0) }
                        + [.rubric(LocalizedText(
                            sr: "Слава… и сада… Алилуја, алилуја, алилуја, слава Теби, Боже. (трипут)",
                            en: "Glory… both now… Alleluia, alleluia, alleluia, glory to Thee, O God. (three times)"
                        ))]
                ),
                ServiceSection(
                    id: "\(id)-propers",
                    title: LocalizedText(sr: "Тропари дана", en: "Troparia of the day"),
                    blocks: [
                        .pending(LocalizedText(
                            sr: "Тропар и кондак дана, по Минеју.",
                            en: "The troparion and kontakion of the day, from the Menaion."
                        ))
                    ]
                ),
                ServiceSection(
                    id: "\(id)-close",
                    title: LocalizedText(sr: "Завршетак", en: "The conclusion"),
                    blocks: [
                        CommonPrayers.theotokosSalutation,
                        .rubric(LocalizedText(sr: "Господе, помилуј. (четрдесет пута)", en: "Lord, have mercy. (forty times)")),
                        .pending(closingPrayer),
                    ] + CommonPrayers.dismissal
                ),
            ]
        )
    }
}
