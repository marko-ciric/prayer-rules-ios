import Foundation

/// One block of a prayer rule, hour, or service.
///
/// `.psalm` is the reason this is an enum rather than a flat string: the app
/// already carries the Psalter, so an hour cites Psalm 5 instead of
/// duplicating it, and tapping the citation opens the existing reader.
enum ServiceBlock {
    /// A section heading inside the body of a service.
    case heading(LocalizedText)
    /// A rubric — the italic instruction, not the prayer: "Трипут", "Поклон".
    case rubric(LocalizedText)
    /// A prayer. `title` is the name it is known by, where it has one.
    case prayer(title: LocalizedText?, text: LocalizedText)
    /// A citation into the Psalter, opened in the psalm reader.
    case psalm(Int)
    /// Content still to be transcribed. Rendered as a visible, labelled gap
    /// rather than silently omitted — the Menaion arrives a day at a time.
    case pending(LocalizedText)
}

struct ServiceSection: Identifiable {
    let id: String
    let title: LocalizedText?
    let blocks: [ServiceBlock]

    init(id: String, title: LocalizedText? = nil, blocks: [ServiceBlock]) {
        self.id = id
        self.title = title
        self.blocks = blocks
    }
}

/// A prayer rule, an hour, or the service of a day.
struct Service: Identifiable {
    let id: String
    let title: LocalizedText
    let subtitle: LocalizedText?
    let sections: [ServiceSection]

    init(id: String, title: LocalizedText, subtitle: LocalizedText? = nil, sections: [ServiceSection]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.sections = sections
    }

    /// Psalms cited anywhere in the service, in order, without repeats —
    /// used for the "Пс 5 · 89 · 100" summary on the list rows.
    var citedPsalms: [Int] {
        var seen = Set<Int>()
        var result: [Int] = []
        for section in sections {
            for block in section.blocks {
                if case .psalm(let n) = block, !seen.contains(n) {
                    seen.insert(n)
                    result.append(n)
                }
            }
        }
        return result
    }

    /// True when nothing but placeholders has been written yet.
    var isEntirelyPending: Bool {
        sections.allSatisfy { section in
            section.blocks.allSatisfy { block in
                if case .pending = block { return true }
                if case .heading = block { return true }
                return false
            }
        }
    }
}
