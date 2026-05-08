// GymSpaceApp.swift

import SwiftUI


@main
struct GymSpaceApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}
