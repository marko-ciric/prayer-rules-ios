import SwiftUI

// Color palette approximating the web app's Tailwind amber/stone/red tokens.
enum Theme {
    static let amber50 = Color(red: 1.00, green: 0.984, blue: 0.922)   // #fffbeb
    static let amber100 = Color(red: 0.996, green: 0.953, blue: 0.780) // #fef3c7
    static let amber900 = Color(red: 0.471, green: 0.208, blue: 0.059) // #78350f
    static let stone50 = Color(red: 0.980, green: 0.980, blue: 0.976)  // #fafaf9
    static let stone100 = Color(red: 0.961, green: 0.961, blue: 0.957) // #f5f5f4
    static let stone400 = Color(red: 0.659, green: 0.635, blue: 0.620) // #a8a29e
    static let stone500 = Color(red: 0.471, green: 0.443, blue: 0.424) // #78716c
    static let stone600 = Color(red: 0.341, green: 0.325, blue: 0.310) // #57534e
    static let stone700 = Color(red: 0.267, green: 0.251, blue: 0.235) // #44403c
    static let stone800 = Color(red: 0.161, green: 0.145, blue: 0.141) // #292524
    static let red900 = Color(red: 0.498, green: 0.114, blue: 0.114)   // #7f1d1d

    // Fasting marks. Muted enough to sit inside the parchment palette and
    // distinct enough to tell apart in a month grid — but the grid never
    // relies on colour alone: every cell's day view spells the rule out, and
    // the legend under the calendar names each band.
    static let fastDairy = Color(red: 0.784, green: 0.635, blue: 0.290)     // #c8a24a
    static let fastFish = Color(red: 0.373, green: 0.478, blue: 0.322)      // #5f7a52
    static let fastWineOil = Color(red: 0.631, green: 0.400, blue: 0.184)   // #a1662f
    static let fastStrict = Color(red: 0.247, green: 0.184, blue: 0.184)    // #3f2f2f

    /// nil on a fast-free day, which is marked by the absence of a band.
    static func fastColor(_ level: FastLevel) -> Color? {
        switch level {
        case .fastFree:  return nil
        case .dairy:     return fastDairy
        case .fish:      return fastFish
        case .wineOil:   return fastWineOil
        case .xerophagy: return red900
        case .strict:    return fastStrict
        }
    }

    static let parchment = LinearGradient(
        colors: [Color(red: 0.980, green: 0.961, blue: 0.910), Color(red: 0.961, green: 0.937, blue: 0.878)],
        startPoint: .top, endPoint: .bottom
    )

    // Stand-ins for the web app's Cormorant Garamond ("display") and
    // EB Garamond ("serif") web fonts, which aren't bundled natively yet.
    // TODO: bundle the actual Cormorant/EB Garamond .ttf files and register
    // them via Info.plist's UIAppFonts to match the web app exactly.
    static func display(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
