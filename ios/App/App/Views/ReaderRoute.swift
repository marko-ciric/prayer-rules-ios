import SwiftUI

/// What a tap from the Today or Calendar screen opens over the top.
///
/// One route rather than several `.fullScreenCover` modifiers on the same
/// view: stacking those is unreliable, and everything a day links to is a
/// full-screen reader anyway.
enum ReaderRoute: Identifiable {
    case psalm(Int)
    case service(Service)

    var id: String {
        switch self {
        case .psalm(let n): return "psalm-\(n)"
        case .service(let s): return "service-\(s.id)"
        }
    }
}

extension View {
    /// The environment objects are passed in and re-injected rather than
    /// inherited: SwiftUI's propagation of `@EnvironmentObject` into a
    /// presented cover has been unreliable across versions, and a reader that
    /// traps on a missing object is not a trade worth making for two lines.
    func readerCover(
        route: Binding<ReaderRoute?>,
        lang: LanguageManager,
        settings: ReaderSettings
    ) -> some View {
        fullScreenCover(item: route) { destination in
            Group {
                switch destination {
                case .psalm(let number):
                    PsalmReaderCover(start: number) { route.wrappedValue = nil }
                case .service(let service):
                    ServiceView(service: service) { route.wrappedValue = nil }
                }
            }
            .environmentObject(lang)
            .environmentObject(settings)
        }
    }
}

/// Hosts `PsalmReaderView` outside the Psalter tab, holding the prev/next
/// state the reader navigates through.
struct PsalmReaderCover: View {
    let start: Int
    let onClose: () -> Void

    @State private var number: Int

    init(start: Int, onClose: @escaping () -> Void) {
        self.start = start
        self.onClose = onClose
        _number = State(initialValue: start)
    }

    var body: some View {
        PsalmReaderView(number: number, onBack: onClose, onNavigate: { number = $0 })
    }
}
