import SwiftUI

/// The month grid, with the selected day's full entry beneath it.
///
/// Each cell carries the civil day, the church (Julian) day beside it, and a
/// band in the colour of the day's fast — so a month reads at a glance as the
/// shape of the fasting year, which is what a calendar is for here.
struct CalendarMonthView: View {
    @EnvironmentObject var lang: LanguageManager
    let onOpen: (ReaderRoute) -> Void

    @State private var year: Int
    @State private var month: Int
    @State private var selectedJDN: Int

    init(onOpen: @escaping (ReaderRoute) -> Void) {
        self.onOpen = onOpen
        let today = OrthodoxCalendar.jdn(from: Date())
        let civil = OrthodoxCalendar.civilDate(fromJDN: today)
        _year = State(initialValue: civil.year)
        _month = State(initialValue: civil.month)
        _selectedJDN = State(initialValue: today)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        let language = lang.language
        let days = monthDays()
        let selected = LiturgicalDay.make(jdn: selectedJDN)

        ScrollView {
            VStack(spacing: 22) {
                monthHeader(language)
                weekdayHeader(language)
                grid(days)
                legend(language)

                DividerView()

                LiturgicalDayView(day: selected, onOpen: onOpen)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Theme.parchment.ignoresSafeArea())
    }

    // MARK: - Header

    @ViewBuilder
    private func monthHeader(_ language: Language) -> some View {
        HStack {
            Button(action: { step(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.amber900)
                    .padding(8)
            }
            .accessibilityLabel(CalendarStrings.previousMonth.text(language))

            Spacer()

            VStack(spacing: 2) {
                Text(CalendarNames.monthName(month, language))
                    .font(Theme.display(26, weight: .bold))
                    .foregroundColor(Theme.amber900)
                Text(String(year))
                    .font(Theme.serif(12))
                    .kerning(2)
                    .foregroundColor(Theme.stone500)
            }

            Spacer()

            Button(action: { step(1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.amber900)
                    .padding(8)
            }
            .accessibilityLabel(CalendarStrings.nextMonth.text(language))
        }
    }

    @ViewBuilder
    private func weekdayHeader(_ language: Language) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(CalendarNames.weekdayInitials.enumerated()), id: \.offset) { _, name in
                Text(name.text(language))
                    .font(Theme.serif(11))
                    .kerning(1)
                    .textCase(.uppercase)
                    .foregroundColor(Theme.amber900.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Grid

    @ViewBuilder
    private func grid(_ days: [LiturgicalDay?]) -> some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let day = day {
                    cell(day)
                } else {
                    Color.clear.frame(height: 54)
                }
            }
        }
    }

    @ViewBuilder
    private func cell(_ day: LiturgicalDay) -> some View {
        let isSelected = day.jdn == selectedJDN
        let isToday = day.isToday
        let isGreat = (day.principalFeast?.rank ?? .commemoration) >= .great

        Button(action: { selectedJDN = day.jdn }) {
            VStack(spacing: 2) {
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(day.civil.day)")
                        .font(Theme.display(17, weight: isGreat ? .bold : .regular))
                        .foregroundColor(isSelected ? Theme.amber50 : (isGreat ? Theme.red900 : Theme.stone800))
                    Text("\(day.church.day)")
                        .font(Theme.serif(9))
                        .foregroundColor(isSelected ? Theme.amber50.opacity(0.8) : Theme.stone400)
                }
                Spacer(minLength: 0)
                FastMarkView(level: day.fast.level)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(isSelected ? Theme.amber900 : Color.white.opacity(0.55))
            .overlay(
                Rectangle()
                    .stroke(isToday ? Theme.amber900 : Theme.amber900.opacity(0.12),
                            lineWidth: isToday ? 1.5 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(day))
    }

    private func accessibilityLabel(_ day: LiturgicalDay) -> String {
        let language = lang.language
        var parts = [CalendarNames.longDate(day.civil, language), day.fast.level.name.text(language)]
        if let feast = day.principalFeast { parts.append(feast.name.text(language)) }
        return parts.joined(separator: ", ")
    }

    // MARK: - Legend

    @ViewBuilder
    private func legend(_ language: Language) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(CalendarStrings.legend.text(language))
                .font(Theme.serif(10))
                .kerning(2)
                .textCase(.uppercase)
                .foregroundColor(Theme.amber900.opacity(0.6))
            // Two rows of three keeps every label readable at phone width.
            ForEach([Array(FastLevel.allCases.prefix(3)), Array(FastLevel.allCases.suffix(3))], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.rawValue) { level in
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(Theme.fastColor(level) ?? Theme.stone400.opacity(0.3))
                                .frame(width: 10, height: 3)
                            Text(level.name.text(language))
                                .font(Theme.serif(11))
                                .foregroundColor(Theme.stone600)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Month arithmetic

    /// Leading blanks then every day of the month, laid out Monday-first.
    private func monthDays() -> [LiturgicalDay?] {
        let first = OrthodoxCalendar.jdn(gregorianYear: year, month: month, day: 1)
        let nextMonth = month == 12 ? 1 : month + 1
        let nextYear = month == 12 ? year + 1 : year
        let count = OrthodoxCalendar.jdn(gregorianYear: nextYear, month: nextMonth, day: 1) - first

        // weekday is 1 = Sunday … 7 = Saturday; the grid starts on Monday.
        let leading = (OrthodoxCalendar.weekday(fromJDN: first) + 5) % 7

        var cells: [LiturgicalDay?] = Array(repeating: nil, count: leading)
        cells += (0..<count).map { LiturgicalDay.make(jdn: first + $0) }
        return cells
    }

    private func step(_ delta: Int) {
        let total = year * 12 + (month - 1) + delta
        year = total / 12
        month = total % 12 + 1
    }
}
