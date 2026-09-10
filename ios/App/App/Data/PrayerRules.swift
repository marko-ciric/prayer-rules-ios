import Foundation

/// The morning and evening rule.
///
/// The fixed frame — the beginning, the Symbol of Faith, Psalm 50, the
/// Theotokion, the dismissal — is complete. The numbered prayers of each
/// rule are listed by the name they carry in the molitvenik and marked
/// `.pending`: the app shows a labelled gap rather than pretending the rule
/// is shorter than it is, and each one can be filled in on its own.
enum PrayerRules {

    static let all: [Service] = [morning, evening]

    static let morning = Service(
        id: "rule-morning",
        title: LocalizedText(sr: "Јутарње молитве", en: "Morning Prayers"),
        subtitle: LocalizedText(sr: "Молитвено правило по устајању", en: "The rule on rising"),
        sections: [
            ServiceSection(
                id: "morning-beginning",
                title: LocalizedText(sr: "Почетак", en: "The beginning"),
                blocks: [
                    ServiceBlock.rubric(LocalizedText(
                        sr: "Уставши од сна, пре сваког другог посла, стани са страхом Божијим и прекрсти се.",
                        en: "On rising from sleep, before any other work, stand with the fear of God and sign yourself with the cross."
                    ))
                ] + CommonPrayers.beginning
            ),
            ServiceSection(
                id: "morning-prayers",
                title: LocalizedText(sr: "Молитве јутарње", en: "The morning prayers"),
                blocks: [
                    ServiceBlock.prayer(
                        title: LocalizedText(sr: "Молитва цариникова", en: "The prayer of the publican"),
                        text: LocalizedText(
                            sr: "Боже, милостив буди мени грешноме.",
                            en: "O God, be merciful to me a sinner."
                        )
                    ),
                    .pending(LocalizedText(sr: "1. Молитва Св. Макарија Великог", en: "1. Prayer of St Macarius the Great")),
                    .pending(LocalizedText(sr: "2. Молитва Св. Василија Великог", en: "2. Prayer of St Basil the Great")),
                    .pending(LocalizedText(sr: "3. Молитва Пресветој Тројици", en: "3. Prayer to the Most Holy Trinity")),
                    .pending(LocalizedText(sr: "4. Молитва Св. Јована Златоуста (по часовима дана и ноћи)", en: "4. Prayer of St John Chrysostom (for the hours of the day and night)")),
                    .pending(LocalizedText(sr: "5. Молитва Св. Јована Дамаскина", en: "5. Prayer of St John of Damascus")),
                ]
            ),
            ServiceSection(
                id: "morning-creed",
                title: LocalizedText(sr: "Символ вере", en: "The Symbol of Faith"),
                blocks: [CommonPrayers.creed]
            ),
            ServiceSection(
                id: "morning-psalm",
                title: LocalizedText(sr: "Псалам покајни", en: "The psalm of repentance"),
                blocks: [
                    ServiceBlock.rubric(LocalizedText(
                        sr: "Псалам 50 — покајни псалам Давидов, чита се сваког јутра.",
                        en: "Psalm 50 — the penitential psalm of David, read each morning."
                    )),
                    .psalm(50),
                ]
            ),
            ServiceSection(
                id: "morning-intercession",
                title: LocalizedText(sr: "Молитве заступничке", en: "Prayers of intercession"),
                blocks: [
                    CommonPrayers.theotokosSalutation,
                    .pending(LocalizedText(sr: "Молитва Анђелу чувару", en: "Prayer to the Guardian Angel")),
                    .pending(LocalizedText(sr: "Молитва за живе", en: "Prayer for the living")),
                    .pending(LocalizedText(sr: "Молитва за упокојене", en: "Prayer for the departed")),
                ]
            ),
            ServiceSection(
                id: "morning-dismissal",
                title: LocalizedText(sr: "Отпуст", en: "The dismissal"),
                blocks: CommonPrayers.dismissal
            ),
        ]
    )

    static let evening = Service(
        id: "rule-evening",
        title: LocalizedText(sr: "Вечерње молитве", en: "Evening Prayers"),
        subtitle: LocalizedText(sr: "Молитвено правило пред спавање", en: "The rule before sleep"),
        sections: [
            ServiceSection(
                id: "evening-beginning",
                title: LocalizedText(sr: "Почетак", en: "The beginning"),
                blocks: CommonPrayers.beginning
            ),
            ServiceSection(
                id: "evening-prayers",
                title: LocalizedText(sr: "Молитве вечерње", en: "The evening prayers"),
                blocks: [
                    ServiceBlock.pending(LocalizedText(sr: "1. Молитва Св. Макарија Великог", en: "1. Prayer of St Macarius the Great")),
                    .pending(LocalizedText(sr: "2. Молитва Св. Антиоха, Господу нашем Исусу Христу", en: "2. Prayer of St Antiochus, to our Lord Jesus Christ")),
                    .pending(LocalizedText(sr: "3. Молитва Св. Јована Златоуста", en: "3. Prayer of St John Chrysostom")),
                    .pending(LocalizedText(sr: "4. Молитва Св. Јована Дамаскина, пред сан", en: "4. Prayer of St John of Damascus, before sleep")),
                ]
            ),
            ServiceSection(
                id: "evening-confession",
                title: LocalizedText(sr: "Свакодневно исповедање грехова", en: "The daily confession of sins"),
                blocks: [
                    ServiceBlock.pending(LocalizedText(
                        sr: "Исповедам Теби, Господу Богу моме…",
                        en: "I confess to Thee, the Lord my God…"
                    ))
                ]
            ),
            ServiceSection(
                id: "evening-theotokion",
                title: LocalizedText(sr: "Богородици", en: "To the Theotokos"),
                blocks: [
                    CommonPrayers.theotokosSalutation,
                    CommonPrayers.itIsTrulyMeet,
                    .pending(LocalizedText(
                        sr: "Молитва Св. Јоаникија: „Уповање моје је Отац…\"",
                        en: "Prayer of St Ioannicius: \"My hope is the Father…\""
                    )),
                ]
            ),
            ServiceSection(
                id: "evening-dismissal",
                title: LocalizedText(sr: "Отпуст", en: "The dismissal"),
                blocks: CommonPrayers.dismissal
            ),
        ]
    )
}
