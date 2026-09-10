import SwiftUI

/// The app's three surfaces. The calendar is the spine — Today is the
/// calendar opened at the current day — and the Psalter, which used to be
/// the whole app, is now one of them.
struct RootTabView: View {
    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var settings: ReaderSettings

    @State private var route: ReaderRoute? = nil
    @State private var psalterSelection: Int? = nil

    var body: some View {
        let language = lang.language

        TabView {
            TodayView(onOpen: { route = $0 })
                .tabItem {
                    Label(CalendarStrings.tabToday.text(language), systemImage: "sun.max")
                }

            CalendarMonthView(onOpen: { route = $0 })
                .tabItem {
                    Label(CalendarStrings.tabCalendar.text(language), systemImage: "calendar")
                }

            psalterTab
                .tabItem {
                    Label(CalendarStrings.tabPsalter.text(language), systemImage: "book.closed")
                }
        }
        .accentColor(Theme.amber900)
        .readerCover(route: $route, lang: lang, settings: settings)
    }

    /// The Psalter keeps the list/reader state machine it has always had —
    /// `selected == nil` shows the list — rather than being pushed through
    /// the shared cover, so its back button still lands on the list.
    @ViewBuilder
    private var psalterTab: some View {
        if let number = psalterSelection {
            PsalmReaderView(
                number: number,
                onBack: { psalterSelection = nil },
                onNavigate: { psalterSelection = $0 }
            )
        } else {
            PsalmListView(onSelect: { psalterSelection = $0 })
        }
    }
}
