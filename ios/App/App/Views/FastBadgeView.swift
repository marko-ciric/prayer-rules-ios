import SwiftUI

/// The day's fasting rule, stated rather than merely coloured: the level, the
/// period it comes from, and what it permits.
struct FastBadgeView: View {
    @EnvironmentObject var lang: LanguageManager
    let fast: FastDay

    var body: some View {
        let accent = Theme.fastColor(fast.level) ?? Theme.stone400

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Circle()
                    .fill(accent)
                    .frame(width: 10, height: 10)
                Text(fast.level.name.text(lang.language))
                    .font(Theme.display(19, weight: .semibold))
                    .foregroundColor(Theme.stone800)
                Spacer(minLength: 0)
                if let reason = fast.reason {
                    Text(reason.text(lang.language))
                        .font(Theme.serif(12))
                        .italic()
                        .foregroundColor(Theme.stone500)
                        .multilineTextAlignment(.trailing)
                }
            }
            Text(fast.level.detail.text(lang.language))
                .font(Theme.serif(14))
                .foregroundColor(Theme.stone600)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .overlay(Rectangle().fill(accent).frame(width: 3), alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.amber900.opacity(0.18), lineWidth: 1))
    }
}

/// A single small band under a day number in the month grid.
struct FastMarkView: View {
    let level: FastLevel

    var body: some View {
        Rectangle()
            .fill(Theme.fastColor(level) ?? Color.clear)
            .frame(height: 3)
            .frame(maxWidth: .infinity)
    }
}
