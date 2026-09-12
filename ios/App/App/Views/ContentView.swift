import SwiftUI

/// Root view. Owns the two objects every screen reads from — the active
/// language and the shared reading preferences — and hands off to the tabs.
struct ContentView: View {
    @StateObject private var lang = LanguageManager()
    @StateObject private var settings = ReaderSettings()

    var body: some View {
        RootTabView()
            .environmentObject(lang)
            .environmentObject(settings)
    }
}
