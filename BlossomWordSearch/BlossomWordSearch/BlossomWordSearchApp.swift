import SwiftUI

@main
struct BlossomWordSearchApp: App {
    @State private var store = PlayerStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
        }
    }
}
