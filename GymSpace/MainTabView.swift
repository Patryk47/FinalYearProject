// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home",     systemImage: "house.fill") }
                .tag(0)

            DiscoverView()
                .tabItem { Label("Discover", systemImage: "person.2.fill") }
                .tag(1)

            ChatsView()
                .tabItem { Label("Chats", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(2)
                .badge(appState.unreadCount > 0 ? "\(appState.unreadCount)" : nil)

            WorkoutsView()
                .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(4)
        }
        .tint(Color(hex: "#00D47A"))
    }
}
