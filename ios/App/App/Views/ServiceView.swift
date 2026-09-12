import SwiftUI

/// Reader for a prayer rule, an hour, or the service of a day.
///
/// Shares the psalm reader's furniture — parchment, ornament rules, the same
/// top bar with the shared font control — so moving between a psalm and a
/// rule does not feel like moving between two apps.
struct ServiceView: View {
    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var settings: ReaderSettings
    let service: Service
    let onBack: () -> Void

    @State private var psalm: Int? = nil

    var body: some View {
        let language = lang.language

        ScrollView {
            VStack(spacing: 0) {
                topBar

                VStack(spacing: 0) {
                    Text(service.title.text(language))
                        .font(Theme.display(34, weight: .bold))
                        .foregroundColor(Theme.amber900)
                        .multilineTextAlignment(.center)

                    if let subtitle = service.subtitle {
                        Text(subtitle.text(language))
                            .font(Theme.serif(14))
                            .italic()
                            .foregroundColor(Theme.stone600)
                            .multilineTextAlignment(.center)
                            .padding(.top, 6)
                    }

                    DividerView()

                    ForEach(service.sections) { section in
                        sectionView(section, language)
                    }

                    DividerView()

                    Text(lang.t.glory)
                        .font(Theme.display(17))
                        .italic()
                        .foregroundColor(Theme.amber900.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 32)
            }
        }
        .background(Theme.parchment.ignoresSafeArea())
        .fullScreenCover(item: Binding(
            get: { psalm.map { PsalmNumber(id: $0) } },
            set: { psalm = $0?.id }
        )) { selection in
            PsalmReaderCover(start: selection.id) { psalm = nil }
                .environmentObject(lang)
                .environmentObject(settings)
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text(lang.t.back).font(Theme.serif(16))
                }
                .foregroundColor(Theme.amber900)
            }
            Spacer()
            HStack(spacing: 8) {
                Button(action: { settings.decrease() }) {
                    Image(systemName: "minus").foregroundColor(Theme.amber900)
                }
                .accessibilityLabel(lang.t.smallerFont)
                Image(systemName: "textformat.size").foregroundColor(Theme.amber900.opacity(0.6))
                Button(action: { settings.increase() }) {
                    Image(systemName: "plus").foregroundColor(Theme.amber900)
                }
                .accessibilityLabel(lang.t.largerFont)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.stone50.opacity(0.95))
        .overlay(Rectangle().fill(Theme.amber900.opacity(0.15)).frame(height: 1), alignment: .bottom)
    }

    @ViewBuilder
    private func sectionView(_ section: ServiceSection, _ language: Language) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title = section.title {
                Text(title.text(language))
                    .font(Theme.serif(11))
                    .kerning(2.5)
                    .textCase(.uppercase)
                    .foregroundColor(Theme.amber900.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 2)
            }
            ForEach(Array(section.blocks.enumerated()), id: \.offset) { _, block in
                blockView(block, language)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 34)
    }

    @ViewBuilder
    private func blockView(_ block: ServiceBlock, _ language: Language) -> some View {
        switch block {
        case .heading(let text):
            Text(text.text(language))
                .font(Theme.display(20, weight: .semibold))
                .foregroundColor(Theme.amber900)
                .padding(.top, 8)

        case .rubric(let text):
            Text(text.text(language))
                .font(Theme.serif(14))
                .italic()
                .foregroundColor(Theme.red900.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)

        case .prayer(let title, let text):
            VStack(alignment: .leading, spacing: 6) {
                if let title = title {
                    Text(title.text(language))
                        .font(Theme.display(15, weight: .semibold))
                        .foregroundColor(Theme.amber900.opacity(0.85))
                }
                Text(text.text(language))
                    .font(.system(size: settings.fontSize, design: .serif))
                    .foregroundColor(Theme.stone800)
                    .lineSpacing(settings.fontSize * 0.4)
                    .fixedSize(horizontal: false, vertical: true)
            }

        case .psalm(let number):
            Button(action: { psalm = number }) {
                let openingLine = lang.openingLines[number].flatMap { $0.isEmpty ? nil : $0 }
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("\(number)")
                        .font(Theme.display(24, weight: .semibold))
                        .foregroundColor(Theme.amber900)
                        .frame(width: 40, alignment: .trailing)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(CalendarStrings.openPsalm.text(language))
                            .font(Theme.serif(11))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(Theme.amber900.opacity(0.6))
                        Text(openingLine.map { $0 + "…" } ?? CalendarStrings.psalmPreviewUnavailable.text(language))
                            .font(Theme.serif(15))
                            .foregroundColor(Theme.stone700)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)
                    Text("›")
                        .font(.system(size: 22))
                        .foregroundColor(Theme.amber900.opacity(0.4))
                        .accessibilityHidden(true)
                }
                .padding(12)
                .contentShape(Rectangle())
                .background(Theme.amber50.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.amber900.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)

        case .pending(let label):
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "hourglass")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.stone400)
                    .padding(.top, 3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label.text(language))
                        .font(Theme.serif(15))
                        .foregroundColor(Theme.stone600)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(CalendarStrings.sectionPending.text(language))
                        .font(Theme.serif(11))
                        .italic()
                        .foregroundColor(Theme.stone400)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.stone100.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundColor(Theme.stone400.opacity(0.6))
            )
        }
    }
}

/// `fullScreenCover(item:)` needs an `Identifiable`, and `Int` is not one.
struct PsalmNumber: Identifiable {
    let id: Int
}
