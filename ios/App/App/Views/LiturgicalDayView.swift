import SwiftUI

/// Everything one day carries: its two dates, the tone, the fast, the
/// commemorations, the rules and hours to pray, the kathismata appointed,
/// and the space held for the service.
///
/// Today and the Calendar both render this — Today for the current day,
/// Calendar for whichever day is selected — so the two never drift apart.
struct LiturgicalDayView: View {
    @EnvironmentObject var lang: LanguageManager
    let day: LiturgicalDay
    let onOpen: (ReaderRoute) -> Void

    var body: some View {
        let language = lang.language

        VStack(spacing: 26) {
            dateHeader(language)

            FastBadgeView(fast: day.fast)

            if !day.feasts.isEmpty {
                commemorations(language)
            }

            serviceOfDay(language)

            card(title: CalendarStrings.prayerRules.text(language)) {
                ForEach(PrayerRules.all) { rule in
                    serviceRow(rule, language)
                }
            }

            card(title: CalendarStrings.hours.text(language)) {
                ForEach(Hours.all) { hour in
                    serviceRow(hour, language)
                }
            }

            psalterOfDay(language)

            Text(CalendarStrings.fastingDisclaimer.text(language))
                .font(Theme.serif(12))
                .italic()
                .foregroundColor(Theme.stone500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.top, 4)
        }
    }

    // MARK: - Date

    @ViewBuilder
    private func dateHeader(_ language: Language) -> some View {
        VStack(spacing: 6) {
            Text(CalendarNames.weekdayName(day.weekday, language))
                .font(Theme.serif(12))
                .kerning(3)
                .textCase(.uppercase)
                .foregroundColor(Theme.amber900.opacity(0.8))

            Text(CalendarNames.longDate(day.civil, language))
                .font(Theme.display(30, weight: .bold))
                .foregroundColor(Theme.amber900)
                .multilineTextAlignment(.center)

            Text("\(CalendarNames.shortDate(day.church, language)) \(CalendarStrings.churchCalendar.text(language))")
                .font(Theme.serif(14))
                .italic()
                .foregroundColor(Theme.stone600)

            HStack(spacing: 10) {
                Rectangle().fill(Theme.amber900.opacity(0.3)).frame(width: 28, height: 1)
                Text(seasonLine(language))
                    .font(Theme.serif(11))
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(Theme.amber900.opacity(0.65))
                    .multilineTextAlignment(.center)
                Rectangle().fill(Theme.amber900.opacity(0.3)).frame(width: 28, height: 1)
            }
            .padding(.top, 6)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private func seasonLine(_ language: Language) -> String {
        let season = day.seasonLabel.text(language)
        guard let tone = day.tone else { return season }
        return "\(CalendarStrings.tone.text(language)) \(tone) · \(season)"
    }

    // MARK: - Commemorations

    @ViewBuilder
    private func commemorations(_ language: Language) -> some View {
        card(title: CalendarStrings.commemorations.text(language)) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(day.feasts) { feast in
                    HStack(alignment: .top, spacing: 10) {
                        OrnamentView(size: feast.rank >= .great ? 14 : 10)
                            .padding(.top, 3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feast.name.text(language))
                                .font(feast.rank >= .great
                                      ? Theme.display(18, weight: .semibold)
                                      : Theme.serif(16))
                                .foregroundColor(feast.rank >= .great ? Theme.amber900 : Theme.stone800)
                                .fixedSize(horizontal: false, vertical: true)
                            if let common = feast.commonName {
                                Text(common.text(language))
                                    .font(Theme.serif(13))
                                    .italic()
                                    .foregroundColor(Theme.stone500)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    // MARK: - The service of the day

    @ViewBuilder
    private func serviceOfDay(_ language: Language) -> some View {
        card(title: CalendarStrings.serviceOfDay.text(language)) {
            if let service = DailyServices.service(for: day) {
                serviceRow(service, language)
            } else if case let propers = DailyServices.propers(for: day), !propers.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(propers) { proper in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(proper.label.text(language))
                                .font(Theme.serif(11))
                                .kerning(2)
                                .textCase(.uppercase)
                                .foregroundColor(Theme.amber900.opacity(0.7))
                            Text(proper.text.text(language))
                                .font(Theme.serif(16))
                                .foregroundColor(Theme.stone800)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    pendingNote(language)
                }
            }
        }
    }

    @ViewBuilder
    private func pendingNote(_ language: Language) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "hourglass")
                .font(.system(size: 12))
                .foregroundColor(Theme.stone400)
                .padding(.top, 3)
            Text(CalendarStrings.serviceInPreparation.text(language))
                .font(Theme.serif(13))
                .italic()
                .foregroundColor(Theme.stone500)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.top, 2)
    }

    // MARK: - Psalter of the day

    @ViewBuilder
    private func psalterOfDay(_ language: Language) -> some View {
        card(title: CalendarStrings.psalterOfDay.text(language)) {
            if let reading = day.kathismata {
                VStack(alignment: .leading, spacing: 14) {
                    if !reading.matins.isEmpty {
                        kathismaRow(CalendarStrings.matins.text(language), reading.matins, language)
                    }
                    if !reading.vespers.isEmpty {
                        kathismaRow(CalendarStrings.vespers.text(language), reading.vespers, language)
                    }
                }
            } else {
                Text(day.season == .brightWeek
                     ? CalendarStrings.kathismaBrightWeek.text(language)
                     : CalendarStrings.kathismaLenten.text(language))
                    .font(Theme.serif(14))
                    .italic()
                    .foregroundColor(Theme.stone500)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func kathismaRow(_ label: String, _ numbers: [Int], _ language: Language) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Theme.serif(11))
                .kerning(2)
                .textCase(.uppercase)
                .foregroundColor(Theme.amber900.opacity(0.7))
            ForEach(numbers, id: \.self) { number in
                if let kathisma = kathismata.first(where: { $0.number == number }) {
                    let firstPsalm = kathisma.psalms.first ?? 1
                    Button(action: { onOpen(.psalm(firstPsalm)) }) {
                        HStack(spacing: 10) {
                            Text("\(CalendarStrings.kathisma.text(language)) \(number)")
                                .font(Theme.display(16, weight: .semibold))
                                .foregroundColor(Theme.amber900)
                            Text("\(kathisma.range) · \(CalendarStrings.openPsalm.text(language)) \(firstPsalm)")
                                .font(Theme.serif(14))
                                .foregroundColor(Theme.stone600)
                            Spacer(minLength: 0)
                            Text("›")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.amber900.opacity(0.4))
                                .accessibilityHidden(true)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .contentShape(Rectangle())
                        .background(Theme.amber50.opacity(0.6))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.amber900.opacity(0.18), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Building blocks

    @ViewBuilder
    private func serviceRow(_ service: Service, _ language: Language) -> some View {
        Button(action: { onOpen(.service(service)) }) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(service.title.text(language))
                        .font(Theme.display(18, weight: .semibold))
                        .foregroundColor(Theme.amber900)
                        .multilineTextAlignment(.leading)
                    if !service.citedPsalms.isEmpty {
                        Text(psalmSummary(service, language))
                            .font(Theme.serif(13))
                            .foregroundColor(Theme.stone500)
                    } else if let subtitle = service.subtitle {
                        Text(subtitle.text(language))
                            .font(Theme.serif(13))
                            .italic()
                            .foregroundColor(Theme.stone500)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
                Text("›")
                    .font(.system(size: 22))
                    .foregroundColor(Theme.amber900.opacity(0.4))
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(serviceAccessibilityLabel(service, language))
        .overlay(Rectangle().fill(Theme.amber900.opacity(0.12)).frame(height: 1), alignment: .bottom)
    }

    private func psalmSummary(_ service: Service, _ language: Language) -> String {
        let numbers = service.citedPsalms.map(String.init).joined(separator: " · ")
        return "\(CalendarStrings.openPsalm.text(language)) \(numbers)"
    }

    private func serviceAccessibilityLabel(_ service: Service, _ language: Language) -> String {
        if !service.citedPsalms.isEmpty {
            return "\(service.title.text(language)), \(psalmSummary(service, language))"
        }
        if let subtitle = service.subtitle {
            return "\(service.title.text(language)), \(subtitle.text(language))"
        }
        return service.title.text(language)
    }

    @ViewBuilder
    private func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.serif(11))
                .kerning(2.5)
                .textCase(.uppercase)
                .foregroundColor(Theme.amber900.opacity(0.7))
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.65))
        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.amber900.opacity(0.18), lineWidth: 1))
    }
}
