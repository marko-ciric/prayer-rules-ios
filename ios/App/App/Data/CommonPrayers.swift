import Foundation

/// The prayers that recur across every rule and hour, written once.
///
/// Text is the Serbian translation in common liturgical use alongside a
/// standard English rendering. Anything here appears in print in every
/// molitvenik; the day-proper material — troparia, kontakia, the canon —
/// belongs in `FixedFeasts`/`MovableFeasts` and `DailyServices` instead,
/// where it is added a commemoration at a time.
enum CommonPrayers {

    /// "Уобичајени почетак" — the invocation through the Lord's Prayer that
    /// opens the morning rule, the evening rule and each of the hours.
    static let beginning: [ServiceBlock] = [
        .prayer(
            title: nil,
            text: LocalizedText(
                sr: "У име Оца и Сина и Светога Духа. Амин.",
                en: "In the name of the Father, and of the Son, and of the Holy Spirit. Amen."
            )
        ),
        .prayer(
            title: nil,
            text: LocalizedText(
                sr: "Слава Теби, Боже наш, слава Теби.",
                en: "Glory to Thee, our God, glory to Thee."
            )
        ),
        .prayer(
            title: LocalizedText(sr: "Царе Небески", en: "O Heavenly King"),
            text: LocalizedText(
                sr: "Царе Небески, Утешитељу, Душе Истине, Који си свуда присутан и све испуњаваш, Ризницо добара и Животодавче, дођи и усели се у нас, и очисти нас од сваке нечистоте, и спаси, Благи, душе наше.",
                en: "O Heavenly King, the Comforter, the Spirit of Truth, who art everywhere present and fillest all things, Treasury of good things and Giver of life: come and abide in us, and cleanse us from every impurity, and save our souls, O Good One."
            )
        ),
        .rubric(LocalizedText(sr: "Трисвето — трипут:", en: "The Trisagion, three times:")),
        .prayer(
            title: LocalizedText(sr: "Трисвето", en: "The Trisagion"),
            text: LocalizedText(
                sr: "Свети Боже, Свети Крепки, Свети Бесмртни, помилуј нас.",
                en: "Holy God, Holy Mighty, Holy Immortal, have mercy on us."
            )
        ),
        .prayer(
            title: nil,
            text: LocalizedText(
                sr: "Слава Оцу и Сину и Светоме Духу, и сада и увек и у векове векова. Амин.",
                en: "Glory to the Father, and to the Son, and to the Holy Spirit, both now and ever, and unto the ages of ages. Amen."
            )
        ),
        .prayer(
            title: LocalizedText(sr: "Пресвета Тројице", en: "O Most Holy Trinity"),
            text: LocalizedText(
                sr: "Пресвета Тројице, помилуј нас; Господе, очисти грехе наше; Владико, опрости безакоња наша; Свети, посети и исцели немоћи наше, имена Твога ради.",
                en: "O Most Holy Trinity, have mercy on us. O Lord, cleanse us from our sins. O Master, pardon our iniquities. O Holy One, visit and heal our infirmities, for Thy name's sake."
            )
        ),
        .rubric(LocalizedText(sr: "Господе, помилуј. (трипут) Слава… и сада…", en: "Lord, have mercy. (three times) Glory… both now…")),
        .prayer(
            title: LocalizedText(sr: "Оче наш", en: "The Lord's Prayer"),
            text: LocalizedText(
                sr: "Оче наш, Који си на небесима, да се свети име Твоје, да дође царство Твоје, да буде воља Твоја и на земљи као на небу; хлеб наш насушни дај нам данас; и опрости нам дугове наше као што и ми опраштамо дужницима својим; и не уведи нас у искушење, но избави нас од злога.",
                en: "Our Father, who art in the heavens, hallowed be Thy name. Thy kingdom come. Thy will be done, on earth as it is in heaven. Give us this day our daily bread, and forgive us our debts, as we forgive our debtors. And lead us not into temptation, but deliver us from the evil one."
            )
        ),
        .prayer(
            title: nil,
            text: LocalizedText(
                sr: "Јер је Твоје царство и сила и слава, Оца и Сина и Светога Духа, сада и увек и у векове векова. Амин.",
                en: "For Thine is the kingdom, and the power, and the glory: of the Father, and of the Son, and of the Holy Spirit, now and ever, and unto the ages of ages. Amen."
            )
        ),
        .rubric(LocalizedText(sr: "Господе, помилуј. (дванаест пута)", en: "Lord, have mercy. (twelve times)")),
        .prayer(
            title: nil,
            text: LocalizedText(
                sr: "Ходите, поклонимо се Цару нашем Богу. Ходите, поклонимо се и припаднимо Христу, Цару нашем Богу. Ходите, поклонимо се и припаднимо самоме Христу, Цару и Богу нашем.",
                en: "O come, let us worship God our King. O come, let us worship and fall down before Christ, our King and our God. O come, let us worship and fall down before Christ Himself, our King and our God."
            )
        ),
    ]

    static let creed = ServiceBlock.prayer(
        title: LocalizedText(sr: "Символ вере", en: "The Symbol of Faith"),
        text: LocalizedText(
            sr: "Верујем у једнога Бога Оца, Сведржитеља, Творца неба и земље и свега видљивог и невидљивог. И у једнога Господа Исуса Христа, Сина Божијег, Јединородног, од Оца рођеног пре свих векова; Светлост од Светлости, Бога истинитог од Бога истинитог; рођеног, а не створеног, једносуштног Оцу, кроз Кога је све постало. Који је ради нас људи и ради нашег спасења сишао с небеса, и оваплотио се од Духа Светога и Марије Дјеве, и постао човек; и Који је распет за нас у време Понтија Пилата, и страдао и погребен; и Који је васкрсао у трећи дан, по Писму; и Који се вазнео на небеса и седи с десне стране Оца; и Који ће опет доћи са славом, да суди живима и мртвима, и Његовом царству неће бити краја. И у Духа Светога, Господа, Животворног, Који од Оца исходи, Који се са Оцем и Сином подједнако поштује и заједно слави, Који је говорио кроз пророке. У једну, свету, саборну и апостолску Цркву. Исповедам једно крштење за опроштење грехова. Чекам васкрсење мртвих. И живот будућег века. Амин.",
            en: "I believe in one God, the Father Almighty, Maker of heaven and earth, and of all things visible and invisible. And in one Lord Jesus Christ, the Son of God, the Only-begotten, begotten of the Father before all ages; Light of Light, true God of true God; begotten, not made, of one essence with the Father, by whom all things were made; who for us men and for our salvation came down from the heavens, and was incarnate of the Holy Spirit and the Virgin Mary, and became man; and was crucified for us under Pontius Pilate, and suffered, and was buried; and rose again on the third day according to the Scriptures; and ascended into the heavens, and sitteth at the right hand of the Father; and shall come again with glory to judge the living and the dead, whose kingdom shall have no end. And in the Holy Spirit, the Lord, the Giver of life, who proceedeth from the Father, who together with the Father and the Son is worshipped and glorified, who spake by the prophets. In one holy, catholic and apostolic Church. I confess one baptism for the remission of sins. I look for the resurrection of the dead, and the life of the age to come. Amen."
        )
    )

    static let theotokosSalutation = ServiceBlock.prayer(
        title: LocalizedText(sr: "Богородице Дјево", en: "O Virgin Theotokos"),
        text: LocalizedText(
            sr: "Богородице Дјево, радуј се, благодатна Маријо, Господ је с Тобом; благословена си Ти међу женама и благословен је плод утробе Твоје, јер си родила Спаса душа наших.",
            en: "O Virgin Theotokos, rejoice, Mary full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, for thou hast borne the Saviour of our souls."
        )
    )

    static let itIsTrulyMeet = ServiceBlock.prayer(
        title: LocalizedText(sr: "Достојно јест", en: "It Is Truly Meet"),
        text: LocalizedText(
            sr: "Достојно је ваистину блаженом звати Тебе, Богородицу, свагдаблажену и пренепорочну и Матер Бога нашега. Часнију од херувима и неупоредиво славнију од серафима, Тебе која си без истљења Бога Логоса родила, сушту Богородицу, Тебе величамо.",
            en: "It is truly meet to bless thee, the Theotokos, ever-blessed and most blameless, and the Mother of our God. More honourable than the cherubim, and beyond compare more glorious than the seraphim; who without corruption gavest birth to God the Word, the very Theotokos, thee do we magnify."
        )
    )

    /// The dismissal that closes each of the hours and both rules.
    static let dismissal: [ServiceBlock] = [
        .prayer(
            title: nil,
            text: LocalizedText(
                sr: "Слава Оцу и Сину и Светоме Духу, и сада и увек и у векове векова. Амин. Господе, помилуј. (трипут) Благослови.",
                en: "Glory to the Father, and to the Son, and to the Holy Spirit, both now and ever, and unto the ages of ages. Amen. Lord, have mercy. (three times) Bless."
            )
        ),
        .prayer(
            title: nil,
            text: LocalizedText(
                sr: "Молитвама светих отаца наших, Господе Исусе Христе, Боже наш, помилуј нас. Амин.",
                en: "Through the prayers of our holy fathers, O Lord Jesus Christ our God, have mercy on us. Amen."
            )
        ),
    ]
}
