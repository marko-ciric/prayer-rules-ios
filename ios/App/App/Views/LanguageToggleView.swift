import SwiftUI

/// The SR / EN switch. Sits on both top-level screens — Today and the
/// Psalter — so it is one view rather than two copies.
struct LanguageToggleView: View {
    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Language.allCases, id: \.self) { l in
                Button(action: { lang.language = l }) {
                    Text(l.rawValue.uppercased())
                        .font(Theme.serif(11))
                        .kerning(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(lang.language == l ? Theme.amber900 : Color.white)
                        .foregroundColor(lang.language == l ? Theme.amber50 : Theme.amber900)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(lang.language == l ? Theme.amber900 : Theme.amber900.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(2)
                }
            }
        }
    }
}
