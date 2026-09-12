import Foundation

/// How prominent a commemoration is — drives ordering and typography,
/// and decides which entry the "Service of the day" section follows.
enum FeastRank: Int, Comparable {
    case commemoration = 0  // ordinary saint of the day
    case major = 1          // polyeleos / vigil-rank feast, patronal days
    case great = 2          // one of the Twelve Great Feasts
    case pascha = 3         // Pascha itself — "the Feast of feasts"

    static func < (a: FeastRank, b: FeastRank) -> Bool { a.rawValue < b.rawValue }
}

/// A commemoration. Fixed feasts are pinned to a Julian month/day in
/// `FixedFeasts.swift`; movable ones to an offset in days from Pascha in
/// `MovableFeasts.swift`.
struct Feast: Identifiable {
    let id: String
    let name: LocalizedText
    let rank: FeastRank
    /// Popular Serbian name where one exists (Божић, Ђурђевдан, Видовдан…).
    let commonName: LocalizedText?
    /// Relaxation of the day's fast granted by the feast. Applied only when
    /// it is *less* strict than the computed rule, and never during Holy Week
    /// or on Clean Monday.
    let fastRelaxation: FastLevel?
    let troparion: LocalizedText?
    let kontakion: LocalizedText?

    init(
        id: String,
        name: LocalizedText,
        rank: FeastRank = .commemoration,
        commonName: LocalizedText? = nil,
        fastRelaxation: FastLevel? = nil,
        troparion: LocalizedText? = nil,
        kontakion: LocalizedText? = nil
    ) {
        self.id = id
        self.name = name
        self.rank = rank
        self.commonName = commonName
        self.fastRelaxation = fastRelaxation
        self.troparion = troparion
        self.kontakion = kontakion
    }
}
