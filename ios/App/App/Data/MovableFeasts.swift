import Foundation

/// The Triodion and Pentecostarion — everything fixed to Pascha rather than
/// to a date. Keyed by whole days: `before` counts down to Pascha,
/// `after` counts up from it.
///
/// The two tables can never both match. Their keys reach 70 days back and 56
/// days forward, and no Paschal year is 126 days long.
enum MovableFeasts {

    static func feasts(sincePascha: Int, untilPascha: Int) -> [Feast] {
        var result: [Feast] = []
        if let f = after[sincePascha] { result.append(f) }
        if let f = before[untilPascha] { result.append(f) }
        return result
    }

    // MARK: - Triodion

    private static let before: [Int: Feast] = [
        70: Feast(
            id: "publican-pharisee",
            name: LocalizedText(sr: "Недеља митара и фарисеја", en: "Sunday of the Publican and the Pharisee"),
            rank: .major
        ),
        63: Feast(
            id: "prodigal-son",
            name: LocalizedText(sr: "Недеља блудног сина", en: "Sunday of the Prodigal Son"),
            rank: .major
        ),
        56: Feast(
            id: "meatfare",
            name: LocalizedText(sr: "Месопусна недеља — Страшног суда", en: "Meatfare Sunday — of the Last Judgement"),
            rank: .major
        ),
        49: Feast(
            id: "cheesefare",
            name: LocalizedText(sr: "Сиропусна недеља — Опроштајна", en: "Cheesefare Sunday — Forgiveness Sunday"),
            rank: .major,
            commonName: LocalizedText(sr: "Бели покладе", en: "Forgiveness Sunday")
        ),
        48: Feast(
            id: "clean-monday",
            name: LocalizedText(sr: "Чисти понедељак — почетак Часног поста", en: "Clean Monday — the beginning of Great Lent"),
            rank: .major
        ),
        42: Feast(
            id: "orthodoxy",
            name: LocalizedText(sr: "Недеља Православља", en: "Sunday of Orthodoxy"),
            rank: .major
        ),
        35: Feast(
            id: "palamas",
            name: LocalizedText(sr: "Недеља Светог Григорија Паламе", en: "Sunday of St Gregory Palamas"),
            rank: .major
        ),
        28: Feast(
            id: "veneration-cross",
            name: LocalizedText(sr: "Крстопоклона недеља", en: "Sunday of the Veneration of the Cross"),
            rank: .major
        ),
        21: Feast(
            id: "climacus",
            name: LocalizedText(sr: "Недеља Светог Јована Лествичника", en: "Sunday of St John Climacus"),
            rank: .major
        ),
        14: Feast(
            id: "mary-of-egypt",
            name: LocalizedText(sr: "Недеља Свете Марије Египћанке", en: "Sunday of St Mary of Egypt"),
            rank: .major
        ),
        8: Feast(
            id: "lazarus-saturday",
            name: LocalizedText(sr: "Лазарева субота", en: "Lazarus Saturday"),
            rank: .major
        ),
        7: Feast(
            id: "palm-sunday",
            name: LocalizedText(sr: "Улазак Господњи у Јерусалим", en: "The Entry of the Lord into Jerusalem"),
            rank: .great,
            commonName: LocalizedText(sr: "Цвети", en: "Palm Sunday")
        ),
        6: Feast(id: "great-monday", name: LocalizedText(sr: "Велики понедељак", en: "Great and Holy Monday"), rank: .major),
        5: Feast(id: "great-tuesday", name: LocalizedText(sr: "Велики уторак", en: "Great and Holy Tuesday"), rank: .major),
        4: Feast(id: "great-wednesday", name: LocalizedText(sr: "Велика среда", en: "Great and Holy Wednesday"), rank: .major),
        3: Feast(id: "great-thursday", name: LocalizedText(sr: "Велики четвртак", en: "Great and Holy Thursday"), rank: .major),
        2: Feast(id: "great-friday", name: LocalizedText(sr: "Велики петак", en: "Great and Holy Friday"), rank: .major),
        1: Feast(id: "great-saturday", name: LocalizedText(sr: "Велика субота", en: "Great and Holy Saturday"), rank: .major),
    ]

    // MARK: - Pentecostarion

    private static let after: [Int: Feast] = [
        0: Feast(
            id: "pascha",
            name: LocalizedText(sr: "Васкрсење Христово", en: "The Resurrection of Christ"),
            rank: .pascha,
            commonName: LocalizedText(sr: "Васкрс", en: "Pascha"),
            troparion: LocalizedText(
                sr: "Христос васкрсе из мртвих, смрћу смрт уништи, и онима који су у гробовима живот дарова.",
                en: "Christ is risen from the dead, trampling down death by death, and upon those in the tombs bestowing life."
            )
        ),
        7: Feast(
            id: "thomas-sunday",
            name: LocalizedText(sr: "Томина недеља — Антипасха", en: "Thomas Sunday — Antipascha"),
            rank: .major
        ),
        14: Feast(
            id: "myrrhbearers",
            name: LocalizedText(sr: "Недеља светих жена мироносица", en: "Sunday of the Myrrh-bearing Women"),
            rank: .major
        ),
        21: Feast(
            id: "paralytic",
            name: LocalizedText(sr: "Недеља о раслабљеном", en: "Sunday of the Paralytic"),
            rank: .major
        ),
        24: Feast(
            id: "mid-pentecost",
            name: LocalizedText(sr: "Преполовљење Педесетнице", en: "Mid-Pentecost"),
            rank: .major
        ),
        28: Feast(
            id: "samaritan-woman",
            name: LocalizedText(sr: "Недеља о Самарјанки", en: "Sunday of the Samaritan Woman"),
            rank: .major
        ),
        35: Feast(
            id: "blind-man",
            name: LocalizedText(sr: "Недеља о слепом", en: "Sunday of the Blind Man"),
            rank: .major
        ),
        39: Feast(
            id: "ascension",
            name: LocalizedText(sr: "Вазнесење Господње", en: "The Ascension of the Lord"),
            rank: .great,
            commonName: LocalizedText(sr: "Спасовдан", en: "Ascension"),
            fastRelaxation: .fastFree,
            troparion: LocalizedText(
                sr: "Вазнео си се у слави, Христе Боже наш, обрадовавши ученике обећањем Светога Духа, кад су благословом уверени били да си Ти Син Божији, Избавитељ света.",
                en: "Thou hast ascended in glory, O Christ our God, having gladdened Thy disciples by the promise of the Holy Spirit, when they had been assured by the blessing that Thou art the Son of God, the Redeemer of the world."
            )
        ),
        42: Feast(
            id: "fathers-first-council",
            name: LocalizedText(sr: "Недеља светих отаца Првог васељенског сабора", en: "Sunday of the Fathers of the First Council"),
            rank: .major
        ),
        49: Feast(
            id: "pentecost",
            name: LocalizedText(sr: "Педесетница — Силазак Светога Духа", en: "Pentecost — the Descent of the Holy Spirit"),
            rank: .great,
            commonName: LocalizedText(sr: "Духови (Света Тројица)", en: "Pentecost (Holy Trinity)"),
            troparion: LocalizedText(
                sr: "Благословен си, Христе Боже наш, Који си премудрим рибаре учинио, пославши им Духа Светога, и њима уловио васељену. Човекољупче, слава Теби.",
                en: "Blessed art Thou, O Christ our God, who hast revealed the fishermen as most wise, having sent down upon them the Holy Spirit, and through them didst draw the world into Thy net. O Lover of mankind, glory to Thee."
            )
        ),
        50: Feast(
            id: "holy-spirit",
            name: LocalizedText(sr: "Дан Светога Духа", en: "Monday of the Holy Spirit"),
            rank: .major
        ),
        56: Feast(
            id: "all-saints",
            name: LocalizedText(sr: "Недеља Свих Светих", en: "Sunday of All Saints"),
            rank: .major
        ),
    ]
}
