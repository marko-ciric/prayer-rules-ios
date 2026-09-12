import Foundation

/// A string that exists in both languages at once.
///
/// The Psalter data files predate this type and keep parallel
/// `…Sr.swift` / `…En.swift` dictionaries. Everything added for the
/// calendar redesign uses `LocalizedText` instead: it makes a missing
/// translation a compile error rather than a silent fallback, which the
/// app has never had.
struct LocalizedText: Equatable {
    let sr: String
    let en: String

    init(sr: String, en: String) {
        self.sr = sr
        self.en = en
    }

    func text(_ language: Language) -> String {
        language == .en ? en : sr
    }
}
