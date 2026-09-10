import SwiftUI

/// The day the app opens on: what to pray now, what the fast is, whose
/// memory it is, and the space held for the service.
struct TodayView: View {
    @EnvironmentObject var lang: LanguageManager
    let onOpen: (ReaderRoute) -> Void

    /// Recomputed each time the view is built rather than cached, so the app
    /// is never showing yesterday after midnight.
    private var today: LiturgicalDay { LiturgicalDay.make(date: Date()) }

    var body: some View {
        let language = lang.language

        ScrollView {
            VStack(spacing: 22) {
                HStack {
                    Text(CalendarStrings.today.text(language))
                        .font(Theme.serif(11))
                        .kerning(3)
                        .textCase(.uppercase)
                        .foregroundColor(Theme.amber900.opacity(0.6))
                    Spacer()
                    LanguageToggleView()
                }

                LiturgicalDayView(day: today, onOpen: onOpen)

                footer(language)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(Theme.parchment.ignoresSafeArea())
    }

    @ViewBuilder
    private func footer(_ language: Language) -> some View {
        VStack(spacing: 0) {
            DividerView()
            Text(lang.t.alleluia)
                .font(Theme.display(15))
                .italic()
                .foregroundColor(Theme.amber900.opacity(0.7))
        }
    }
}
