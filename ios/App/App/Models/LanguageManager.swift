import Foundation
import Combine

enum Language: String, CaseIterable {
    case sr, en
}

/// Single source of truth for the active language, mirroring
/// `LanguageContext.jsx`: persists to UserDefaults under the same
/// "psalter-lang" key the web app used for localStorage, and exposes
/// the language-active data tables (opening lines, notes, full text).
final class LanguageManager: ObservableObject {
    private static let storageKey = "psalter-lang"

    @Published var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.storageKey)
        self.language = Language(rawValue: saved ?? "") ?? .sr
    }

    var t: AppStrings {
        language == .en ? .en : .sr
    }

    var openingLines: [Int: String] {
        language == .en ? openingLinesEn : openingLinesSr
    }

    var notes: [Int: String] {
        language == .en ? notesEn : notesSr
    }

    var fullText: [Int: [String]] {
        language == .en ? fullTextEn : fullTextSr
    }
}
