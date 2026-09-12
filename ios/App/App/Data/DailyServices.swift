import Foundation

/// The space for the service of the day — the Menaion.
///
/// This is deliberately a lookup with almost nothing in it yet. The Today
/// view renders whatever is here for the day's principal commemoration and
/// otherwise shows the day's troparion from `FixedFeasts`/`MovableFeasts`
/// with a note that the full service is still being prepared. Adding a
/// service is one entry keyed by the feast's `id` — nothing else changes.
enum DailyServices {

    /// Keyed by `Feast.id`.
    private static let byFeast: [String: Service] = [:]

    /// The service for a day, if one has been transcribed. Commemorations
    /// are already ranked, so the first match wins.
    static func service(for day: LiturgicalDay) -> Service? {
        for feast in day.feasts {
            if let service = byFeast[feast.id] { return service }
        }
        return nil
    }

    /// What the Today view falls back to while a day's full service is still
    /// being prepared: the troparion and kontakion its feast already carries.
    static func propers(for day: LiturgicalDay) -> [Proper] {
        guard let feast = day.principalFeast else { return [] }
        var result: [Proper] = []
        if let troparion = feast.troparion {
            result.append(Proper(
                id: "\(feast.id)-troparion",
                label: LocalizedText(sr: "Тропар", en: "Troparion"),
                text: troparion
            ))
        }
        if let kontakion = feast.kontakion {
            result.append(Proper(
                id: "\(feast.id)-kontakion",
                label: LocalizedText(sr: "Кондак", en: "Kontakion"),
                text: kontakion
            ))
        }
        return result
    }
}

/// One proper of the day, ready to list.
struct Proper: Identifiable {
    let id: String
    let label: LocalizedText
    let text: LocalizedText
}
