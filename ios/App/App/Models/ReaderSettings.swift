import Foundation
import Combine

/// Reading preferences shared by every text surface — the psalm reader, the
/// hours, the prayer rules. Previously the font size was `@State` on the root
/// view and was lost on relaunch; it now persists and is set once for the
/// whole app.
final class ReaderSettings: ObservableObject {
    private static let fontSizeKey = "reader-font-size"

    /// Clamped to this range by `increase()` / `decrease()`.
    static let fontRange: ClosedRange<CGFloat> = 14...28

    @Published var fontSize: CGFloat {
        didSet {
            UserDefaults.standard.set(Double(fontSize), forKey: Self.fontSizeKey)
        }
    }

    init() {
        let saved = UserDefaults.standard.double(forKey: Self.fontSizeKey)
        let value = CGFloat(saved)
        self.fontSize = Self.fontRange.contains(value) ? value : 18
    }

    func increase() { fontSize = min(Self.fontRange.upperBound, fontSize + 2) }
    func decrease() { fontSize = max(Self.fontRange.lowerBound, fontSize - 2) }
}
