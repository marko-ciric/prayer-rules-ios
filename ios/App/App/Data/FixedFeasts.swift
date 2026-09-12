import Foundation

/// The Menaion — commemorations pinned to a date.
///
/// **Dates are Julian**, the calendar the Serbian Orthodox Church keeps, and
/// the key is `month * 100 + day` on that calendar. The civil (Gregorian)
/// date currently runs thirteen days later, and the conversion is done once,
/// in `OrthodoxCalendar`, not here — so Божић stays 25 December where the
/// Menaion puts it, and the app shows 7 January.
///
/// This is a working selection, not the whole Menaion: the Twelve Great
/// Feasts, the days a Serbian household keeps as a slava, and the
/// commemorations that carry their own service. It is meant to be extended a
/// day at a time — add an entry and the calendar, the fasting rule and the
/// Service of the day all pick it up with no other change.
enum FixedFeasts {

    static func feasts(month: Int, day: Int) -> [Feast] {
        table[month * 100 + day] ?? []
    }

    private static let table: [Int: [Feast]] = [

        // ── January (civil: 14 January – 13 February) ────────────────────
        101: [Feast(
            id: "circumcision",
            name: LocalizedText(sr: "Обрезање Господње; Св. Василије Велики", en: "The Circumcision of the Lord; St Basil the Great"),
            rank: .major
        )],
        105: [Feast(
            id: "theophany-eve",
            name: LocalizedText(sr: "Навечерје Богојављења", en: "The Eve of Theophany"),
            rank: .major,
            commonName: LocalizedText(sr: "Крстовдан", en: "Theophany Eve")
        )],
        106: [Feast(
            id: "theophany",
            name: LocalizedText(sr: "Богојављење — Крштење Господње", en: "Theophany — the Baptism of the Lord"),
            rank: .great,
            commonName: LocalizedText(sr: "Богојављење", en: "Theophany"),
            fastRelaxation: .fastFree,
            troparion: LocalizedText(
                sr: "У Јордану када си се крстио Ти, Господе, тројичноме се јави поклоњење: јер Родитељев глас сведочаше Ти, љубљеним Те Сином називајући, и Дух у виду голубице потврђиваше истинитост речи. Јави се, Христе Боже, и свет просвети, слава Теби.",
                en: "When Thou wast baptized in the Jordan, O Lord, the worship of the Trinity was made manifest; for the voice of the Father bore witness to Thee, calling Thee His beloved Son, and the Spirit in the form of a dove confirmed the truth of His word. O Christ our God, who hast appeared and enlightened the world, glory to Thee."
            )
        )],
        107: [Feast(
            id: "synaxis-forerunner",
            name: LocalizedText(sr: "Сабор Св. Јована Крститеља", en: "The Synaxis of St John the Baptist"),
            rank: .major,
            commonName: LocalizedText(sr: "Јовањдан", en: "St John's Day"),
            fastRelaxation: .fish
        )],
        112: [Feast(id: "tatiana", name: LocalizedText(sr: "Св. мученица Татјана", en: "St Tatiana the Martyr"))],
        114: [Feast(
            id: "sava",
            name: LocalizedText(sr: "Св. Сава, први архиепископ српски", en: "St Sava, First Archbishop of Serbia"),
            rank: .major,
            commonName: LocalizedText(sr: "Савиндан", en: "St Sava's Day"),
            fastRelaxation: .fish
        )],
        117: [Feast(id: "anthony-great", name: LocalizedText(sr: "Св. Антоније Велики", en: "St Anthony the Great"), fastRelaxation: .fish)],
        118: [Feast(id: "athanasius-cyril", name: LocalizedText(sr: "Св. Атанасије и Кирило Александријски", en: "Ss Athanasius and Cyril of Alexandria"))],
        120: [Feast(id: "euthymius", name: LocalizedText(sr: "Св. Јефтимије Велики", en: "St Euthymius the Great"))],
        125: [Feast(id: "gregory-theologian", name: LocalizedText(sr: "Св. Григорије Богослов", en: "St Gregory the Theologian"), fastRelaxation: .fish)],
        127: [Feast(id: "chrysostom-relics", name: LocalizedText(sr: "Пренос моштију Св. Јована Златоуста", en: "The Translation of the Relics of St John Chrysostom"))],
        130: [Feast(
            id: "three-hierarchs",
            name: LocalizedText(sr: "Света Три Јерарха — Василије Велики, Григорије Богослов и Јован Златоусти", en: "The Three Holy Hierarchs — Basil the Great, Gregory the Theologian and John Chrysostom"),
            rank: .major,
            fastRelaxation: .fish
        )],

        // ── February (civil: 14 February – 13 March) ─────────────────────
        202: [Feast(
            id: "meeting",
            name: LocalizedText(sr: "Сретење Господње", en: "The Meeting of the Lord"),
            rank: .great,
            commonName: LocalizedText(sr: "Сретење", en: "The Meeting"),
            fastRelaxation: .fish,
            troparion: LocalizedText(
                sr: "Радуј се, Благодатна Богородице Дјево, јер из Тебе засија Сунце правде, Христос Бог наш, просвећујући оне који су у тами. Весели се и ти, старче праведни, примивши у наручје Ослободитеља душа наших, Који нам дарује васкрсење.",
                en: "Rejoice, O Virgin Theotokos, full of grace, for from thee hath shone forth the Sun of Righteousness, Christ our God, enlightening those in darkness. Be glad also, O righteous Elder, who didst receive in thine arms the Deliverer of our souls, who granteth unto us the Resurrection."
            )
        )],
        203: [Feast(id: "simeon-anna", name: LocalizedText(sr: "Св. Симеон Богопримац и Ана пророчица", en: "St Simeon the God-receiver and Anna the Prophetess"))],
        210: [Feast(id: "haralampije", name: LocalizedText(sr: "Свмч. Харалампије", en: "Hieromartyr Charalampos"))],
        213: [Feast(
            id: "simeon-myrrh",
            name: LocalizedText(sr: "Св. Симеон Мироточиви (Стефан Немања)", en: "St Simeon the Myrrh-streaming (Stefan Nemanja)"),
            rank: .major,
            fastRelaxation: .fish
        )],
        224: [Feast(id: "forerunner-head", name: LocalizedText(sr: "Прво и друго обретење главе Св. Јована Крститеља", en: "The First and Second Findings of the Head of St John the Baptist"), fastRelaxation: .fish)],

        // ── March (civil: 14 March – 13 April) ───────────────────────────
        309: [Feast(
            id: "forty-martyrs",
            name: LocalizedText(sr: "Свети четрдесет мученика севастијских", en: "The Forty Martyrs of Sebaste"),
            rank: .major,
            commonName: LocalizedText(sr: "Младенци", en: "The Forty Martyrs"),
            fastRelaxation: .fish
        )],
        325: [Feast(
            id: "annunciation",
            name: LocalizedText(sr: "Благовести Пресвете Богородице", en: "The Annunciation of the Most Holy Theotokos"),
            rank: .great,
            commonName: LocalizedText(sr: "Благовести", en: "The Annunciation"),
            fastRelaxation: .fish,
            troparion: LocalizedText(
                sr: "Данас је почетак нашега спасења и откривење вечне тајне: Син Божији постаје Син Дјеве, и Гаврило благодат благовести. Зато и ми са њим Богородици кликнимо: Радуј се, Благодатна, Господ је с Тобом.",
                en: "Today is the beginning of our salvation and the revelation of the eternal mystery: the Son of God becometh the Son of the Virgin, and Gabriel proclaimeth the good tidings of grace. Therefore let us also cry out with him to the Theotokos: Rejoice, thou who art full of grace, the Lord is with thee."
            )
        )],

        // ── April (civil: 14 April – 13 May) ─────────────────────────────
        423: [Feast(
            id: "george",
            name: LocalizedText(sr: "Св. великомученик Георгије", en: "St George the Great Martyr"),
            rank: .major,
            commonName: LocalizedText(sr: "Ђурђевдан", en: "St George's Day"),
            fastRelaxation: .fish
        )],
        425: [Feast(id: "mark", name: LocalizedText(sr: "Св. апостол и јеванђелист Марко", en: "St Mark the Apostle and Evangelist"), fastRelaxation: .fish)],
        429: [Feast(
            id: "vasilije-ostroski",
            name: LocalizedText(sr: "Св. Василије Острошки Чудотворац", en: "St Basil of Ostrog the Wonderworker"),
            rank: .major,
            fastRelaxation: .fish
        )],

        // ── May (civil: 14 May – 13 June) ────────────────────────────────
        508: [Feast(id: "john-theologian", name: LocalizedText(sr: "Св. апостол и јеванђелист Јован Богослов", en: "St John the Theologian, Apostle and Evangelist"), rank: .major, fastRelaxation: .fish)],
        511: [Feast(id: "cyril-methodius", name: LocalizedText(sr: "Св. Кирило и Методије, просветитељи словенски", en: "Ss Cyril and Methodius, Enlighteners of the Slavs"), fastRelaxation: .fish)],
        521: [Feast(
            id: "constantine-helen",
            name: LocalizedText(sr: "Св. цар Константин и царица Јелена", en: "Ss Constantine and Helen"),
            rank: .major,
            fastRelaxation: .fish
        )],

        // ── June (civil: 14 June – 13 July) ──────────────────────────────
        615: [Feast(
            id: "lazar",
            name: LocalizedText(sr: "Св. великомученик кнез Лазар и свети српски мученици", en: "St Lazar the Great Martyr, Prince of Serbia, and the Holy Serbian Martyrs"),
            rank: .major,
            commonName: LocalizedText(sr: "Видовдан", en: "Vidovdan"),
            fastRelaxation: .fish
        )],
        624: [Feast(
            id: "forerunner-nativity",
            name: LocalizedText(sr: "Рођење Св. Јована Крститеља", en: "The Nativity of St John the Baptist"),
            rank: .major,
            commonName: LocalizedText(sr: "Ивањдан", en: "St John's Nativity"),
            fastRelaxation: .fish
        )],
        629: [Feast(
            id: "peter-paul",
            name: LocalizedText(sr: "Св. врховни апостоли Петар и Павле", en: "The Holy Chief Apostles Peter and Paul"),
            rank: .major,
            commonName: LocalizedText(sr: "Петровдан", en: "Ss Peter and Paul"),
            fastRelaxation: .fish
        )],
        630: [Feast(id: "twelve-apostles", name: LocalizedText(sr: "Сабор Светих дванаест апостола", en: "The Synaxis of the Twelve Apostles"), fastRelaxation: .fish)],

        // ── July (civil: 14 July – 13 August) ────────────────────────────
        702: [Feast(id: "robe-theotokos", name: LocalizedText(sr: "Полагање ризе Пресвете Богородице", en: "The Deposition of the Robe of the Theotokos"), fastRelaxation: .fish)],
        708: [Feast(id: "prokopije", name: LocalizedText(sr: "Св. великомученик Прокопије", en: "St Procopius the Great Martyr"))],
        717: [Feast(id: "marina", name: LocalizedText(sr: "Св. великомученица Марина", en: "St Marina the Great Martyr"), commonName: LocalizedText(sr: "Огњена Марија", en: "St Marina"))],
        720: [Feast(
            id: "elijah",
            name: LocalizedText(sr: "Св. пророк Илија Тезвићанин", en: "The Holy Prophet Elijah the Tishbite"),
            rank: .major,
            commonName: LocalizedText(sr: "Илиндан", en: "St Elijah's Day"),
            fastRelaxation: .fish
        )],
        722: [Feast(id: "mary-magdalene", name: LocalizedText(sr: "Св. Марија Магдалина, равноапостолна", en: "St Mary Magdalene, Equal to the Apostles"), fastRelaxation: .fish)],
        725: [Feast(id: "dormition-anna", name: LocalizedText(sr: "Успење Св. Ане, мајке Пресвете Богородице", en: "The Dormition of St Anna, Mother of the Theotokos"), fastRelaxation: .fish)],
        727: [Feast(
            id: "panteleimon",
            name: LocalizedText(sr: "Св. великомученик и целитељ Пантелејмон", en: "St Panteleimon the Great Martyr and Healer"),
            rank: .major,
            fastRelaxation: .fish
        )],

        // ── August (civil: 14 August – 13 September) ─────────────────────
        801: [Feast(id: "procession-cross", name: LocalizedText(sr: "Изношење Часног Крста; почетак Госпојинског поста", en: "The Procession of the Precious Cross; the Dormition Fast begins"), rank: .major)],
        806: [Feast(
            id: "transfiguration",
            name: LocalizedText(sr: "Преображење Господње", en: "The Transfiguration of the Lord"),
            rank: .great,
            commonName: LocalizedText(sr: "Преображење", en: "The Transfiguration"),
            fastRelaxation: .fish,
            troparion: LocalizedText(
                sr: "Преобразио си се на гори, Христе Боже, показавши ученицима Својим славу Своју колико су могли поднети. Нека и нама грешнима засија светлост Твоја вечна, молитвама Богородице, Даваоче светлости, слава Теби.",
                en: "Thou wast transfigured on the mount, O Christ our God, showing to Thy disciples Thy glory as far as they could bear it. Let Thine everlasting light shine also upon us sinners, through the prayers of the Theotokos. O Giver of light, glory to Thee."
            )
        )],
        815: [Feast(
            id: "dormition",
            name: LocalizedText(sr: "Успење Пресвете Богородице", en: "The Dormition of the Most Holy Theotokos"),
            rank: .great,
            commonName: LocalizedText(sr: "Велика Госпојина", en: "The Dormition"),
            fastRelaxation: .fish,
            troparion: LocalizedText(
                sr: "У рођењу си девственост сачувала, у успењу свет ниси оставила, Богородице; преставила си се к Животу, будући Мати Живота, и молитвама Твојим избављаш од смрти душе наше.",
                en: "In giving birth thou didst preserve thy virginity; in thy dormition thou didst not forsake the world, O Theotokos. Thou wast translated unto life, being the Mother of Life; and by thine intercessions dost thou deliver our souls from death."
            )
        )],
        816: [Feast(id: "image-not-made-by-hands", name: LocalizedText(sr: "Пренос Нерукотвореног образа Господњег", en: "The Translation of the Image of the Lord Not Made by Hands"), fastRelaxation: .fish)],
        828: [Feast(id: "moses-the-black", name: LocalizedText(sr: "Св. Мојсије Мурин", en: "St Moses the Black"))],
        829: [Feast(
            id: "beheading",
            name: LocalizedText(sr: "Усековање главе Св. Јована Крститеља", en: "The Beheading of St John the Baptist"),
            rank: .major,
            commonName: LocalizedText(sr: "Усековање", en: "The Beheading")
        )],
        830: [Feast(
            id: "serbian-saints",
            name: LocalizedText(sr: "Сабор српских светитеља", en: "The Synaxis of the Serbian Saints"),
            rank: .major,
            fastRelaxation: .fish
        )],
        831: [Feast(id: "cincture-theotokos", name: LocalizedText(sr: "Полагање појаса Пресвете Богородице", en: "The Deposition of the Cincture of the Theotokos"), fastRelaxation: .fish)],

        // ── September (civil: 14 September – 13 October) ─────────────────
        901: [Feast(
            id: "indiction",
            name: LocalizedText(sr: "Почетак црквене нове године — Индикт", en: "The Beginning of the Church Year — the Indiction"),
            rank: .major
        )],
        908: [Feast(
            id: "nativity-theotokos",
            name: LocalizedText(sr: "Рођење Пресвете Богородице", en: "The Nativity of the Most Holy Theotokos"),
            rank: .great,
            commonName: LocalizedText(sr: "Мала Госпојина", en: "The Nativity of the Theotokos"),
            fastRelaxation: .fish,
            troparion: LocalizedText(
                sr: "Рођење Твоје, Богородице Дјево, радост објави свој васељени; јер из Тебе засија Сунце правде, Христос Бог наш, и разрешивши клетву даде благослов, и уништивши смрт дарова нам живот вечни.",
                en: "Thy nativity, O Theotokos Virgin, hath proclaimed joy to the whole world; for from thee hath dawned the Sun of Righteousness, Christ our God, who, having annulled the curse, hath given a blessing, and, having abolished death, hath granted us life everlasting."
            )
        )],
        914: [Feast(
            id: "elevation-cross",
            name: LocalizedText(sr: "Воздвижење Часног Крста", en: "The Elevation of the Precious Cross"),
            rank: .great,
            commonName: LocalizedText(sr: "Крстовдан", en: "The Elevation of the Cross"),
            troparion: LocalizedText(
                sr: "Спаси, Господе, народ Твој и благослови наслеђе Твоје; победу православним хришћанима над противницима даруј и Крстом Твојим чувај народ Твој.",
                en: "O Lord, save Thy people and bless Thine inheritance; grant victory to the Orthodox Christians over their adversaries, and by the power of Thy Cross preserve Thy commonwealth."
            )
        )],
        923: [Feast(id: "conception-forerunner", name: LocalizedText(sr: "Зачеће Св. Јована Крститеља", en: "The Conception of St John the Baptist"), fastRelaxation: .fish)],
        926: [Feast(id: "repose-john-theologian", name: LocalizedText(sr: "Преставење Св. апостола Јована Богослова", en: "The Repose of St John the Theologian"), rank: .major, fastRelaxation: .fish)],

        // ── October (civil: 14 October – 12 November) ────────────────────
        1001: [Feast(
            id: "protection",
            name: LocalizedText(sr: "Покров Пресвете Богородице", en: "The Protection of the Most Holy Theotokos"),
            rank: .major,
            commonName: LocalizedText(sr: "Покров", en: "The Protection"),
            fastRelaxation: .fish
        )],
        1014: [Feast(
            id: "paraskeva",
            name: LocalizedText(sr: "Св. преподобна мати Параскева", en: "St Paraskeva the Righteous"),
            rank: .major,
            commonName: LocalizedText(sr: "Св. Петка", en: "St Paraskeva"),
            fastRelaxation: .fish
        )],
        1018: [Feast(id: "luke", name: LocalizedText(sr: "Св. апостол и јеванђелист Лука", en: "St Luke the Apostle and Evangelist"), fastRelaxation: .fish)],
        1026: [Feast(
            id: "demetrius",
            name: LocalizedText(sr: "Св. великомученик Димитрије Мироточиви", en: "St Demetrius the Great Martyr, the Myrrh-streaming"),
            rank: .major,
            commonName: LocalizedText(sr: "Митровдан", en: "St Demetrius' Day"),
            fastRelaxation: .fish
        )],

        // ── November (civil: 14 November – 13 December) ──────────────────
        1101: [Feast(id: "cosmas-damian", name: LocalizedText(sr: "Св. бесребреници Козма и Дамјан", en: "Ss Cosmas and Damian the Unmercenaries"), fastRelaxation: .fish)],
        1108: [Feast(
            id: "archangel-michael",
            name: LocalizedText(sr: "Сабор Св. архангела Михаила и осталих бестелесних сила", en: "The Synaxis of the Archangel Michael and the Bodiless Powers"),
            rank: .major,
            commonName: LocalizedText(sr: "Аранђеловдан", en: "The Synaxis of the Archangel"),
            fastRelaxation: .fish
        )],
        1113: [Feast(id: "chrysostom", name: LocalizedText(sr: "Св. Јован Златоусти", en: "St John Chrysostom"), rank: .major, fastRelaxation: .fish)],
        1114: [Feast(id: "philip", name: LocalizedText(sr: "Св. апостол Филип", en: "St Philip the Apostle"), fastRelaxation: .fish)],
        1116: [Feast(id: "matthew", name: LocalizedText(sr: "Св. апостол и јеванђелист Матеј", en: "St Matthew the Apostle and Evangelist"), fastRelaxation: .fish)],
        1121: [Feast(
            id: "entry-theotokos",
            name: LocalizedText(sr: "Ваведење Пресвете Богородице у храм", en: "The Entry of the Most Holy Theotokos into the Temple"),
            rank: .great,
            commonName: LocalizedText(sr: "Ваведење", en: "The Entry"),
            fastRelaxation: .fish
        )],
        1130: [Feast(id: "andrew", name: LocalizedText(sr: "Св. апостол Андреј Првозвани", en: "St Andrew the First-called Apostle"), rank: .major, fastRelaxation: .fish)],

        // ── December (civil: 14 December – 13 January) ───────────────────
        1204: [Feast(id: "barbara", name: LocalizedText(sr: "Св. великомученица Варвара; Св. Јован Дамаскин", en: "St Barbara the Great Martyr; St John of Damascus"), fastRelaxation: .fish)],
        1205: [Feast(id: "sava-sanctified", name: LocalizedText(sr: "Св. Сава Освећени", en: "St Sabbas the Sanctified"))],
        1206: [Feast(
            id: "nicholas",
            name: LocalizedText(sr: "Св. Николај, архиепископ мирликијски, чудотворац", en: "St Nicholas, Archbishop of Myra, the Wonderworker"),
            rank: .major,
            commonName: LocalizedText(sr: "Никољдан", en: "St Nicholas' Day"),
            fastRelaxation: .fish
        )],
        1209: [Feast(id: "conception-anna", name: LocalizedText(sr: "Зачеће Св. Ане", en: "The Conception of St Anna"), fastRelaxation: .fish)],
        1212: [Feast(id: "spyridon", name: LocalizedText(sr: "Св. Спиридон Чудотворац", en: "St Spyridon the Wonderworker"), fastRelaxation: .fish)],
        1220: [Feast(id: "ignatius", name: LocalizedText(sr: "Свмч. Игњатије Богоносац", en: "Hieromartyr Ignatius the God-bearer"))],
        1224: [Feast(
            id: "nativity-eve",
            name: LocalizedText(sr: "Навечерје Рождества Христовог", en: "The Eve of the Nativity of Christ"),
            rank: .major,
            commonName: LocalizedText(sr: "Бадњи дан", en: "Christmas Eve")
        )],
        1225: [Feast(
            id: "nativity",
            name: LocalizedText(sr: "Рождество Христово", en: "The Nativity of Christ"),
            rank: .great,
            commonName: LocalizedText(sr: "Божић", en: "Christmas"),
            fastRelaxation: .fastFree,
            troparion: LocalizedText(
                sr: "Рождество Твоје, Христе Боже наш, засија свету светлост разума; јер у њему они који су звездама служили, од звезде научише се да се клањају Теби, Сунцу правде, и да Тебе познају, Исток са висине. Господе, слава Теби.",
                en: "Thy nativity, O Christ our God, hath shone upon the world the light of knowledge; for thereby they that worshipped the stars were taught by a star to worship Thee, the Sun of Righteousness, and to know Thee, the Dayspring from on high. O Lord, glory to Thee."
            )
        )],
        1226: [Feast(id: "synaxis-theotokos", name: LocalizedText(sr: "Сабор Пресвете Богородице", en: "The Synaxis of the Most Holy Theotokos"), rank: .major)],
        1227: [Feast(id: "stephen", name: LocalizedText(sr: "Св. првомученик и архиђакон Стефан", en: "St Stephen the Protomartyr and Archdeacon"), rank: .major)],
    ]
}
