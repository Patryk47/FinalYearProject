// HomeView.swift

import SwiftUI

private func relativeMinutes(_ date: Date) -> String {
    let fmt = DateComponentsFormatter()
    fmt.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
    fmt.maximumUnitCount = 1
    fmt.unitsStyle = .short
    let interval = Date().timeIntervalSince(date)
    if interval < 60 { return "just now" }
    return (fmt.string(from: interval) ?? "just now") + " ago"
}

struct HomeView: View {
    @Environment(AppState.self) private var appState

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning" }
        if h < 17 { return "Good afternoon" }
        return "Good evening"
    }

    var body: some View {
        NavigationStack {
            if let user = appState.currentUser {
                List {
                    Section {
                        HStack(spacing: 12) {
                            AvatarView(user: user, size: 48)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(greeting).font(.subheadline).foregroundStyle(.secondary)
                                Text(user.username).font(.headline)
                            }
                            Spacer()
                            LevelBadge(level: user.level)
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Overview") {
                        LabeledContent("Matches",           value: "\(user.matches.count)")
                        LabeledContent("Upcoming Sessions", value: "\(appState.upcomingSessions().count)")
                        LabeledContent("Unread",            value: "\(appState.unreadCount)")
                    }

                    let sessions = appState.upcomingSessions()
                    if !sessions.isEmpty {
                        Section("Upcoming Sessions") {
                            ForEach(sessions.prefix(3)) { session in
                                let partner = session.participants
                                    .filter { $0 != appState.currentUserId }
                                    .compactMap { id in appState.users.first { $0.id == id } }
                                    .first
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(partner?.username ?? "Partner").font(.subheadline)
                                        Text(session.dateTime.formatted(.dateTime.weekday(.wide).day().month().hour().minute()))
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(session.status.capitalized)
                                        .font(.caption2).foregroundStyle(
                                            session.status == "confirmed" ? Color(hex: "#00D47A") : .orange)
                                }
                            }
                        }
                    }

                    let suggestions = appState.suggestedPartners()
                    if !suggestions.isEmpty {
                        Section("Suggested Partners") {
                            ForEach(suggestions.prefix(4), id: \.user.id) { item in
                                NavigationLink(destination: UserProfileView(user: item.user)) {
                                    HStack(spacing: 12) {
                                        AvatarView(user: item.user, size: 36)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.user.username).font(.subheadline)
                                            Text(item.user.gym).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("\(item.score)%").font(.caption).foregroundStyle(.secondary)
                                        LevelBadge(level: item.user.level)
                                    }
                                }
                            }
                        }
                    }

                    let matches = appState.users.filter { user.matches.contains($0.id) }
                    if !matches.isEmpty {
                        Section("Your Matches") {
                            ForEach(matches) { partner in
                                NavigationLink(destination: ChatDetailView(otherUser: partner)) {
                                    HStack(spacing: 12) {
                                        AvatarView(user: partner, size: 36)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(partner.username).font(.subheadline)
                                            Text(partner.gym).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        LevelBadge(level: partner.level)
                                    }
                                }
                            }
                        }
                    }

                    let notifs = appState.myNotifications()
                    if !notifs.isEmpty {
                        Section("Recent Activity") {
                            ForEach(notifs.prefix(5)) { notif in
                                HStack(spacing: 10) {
                                    if !notif.isRead {
                                        Circle().fill(Color(hex: "#00D47A")).frame(width: 7, height: 7)
                                    } else {
                                        Circle().fill(Color.clear).frame(width: 7, height: 7)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(notif.content).font(.subheadline).lineLimit(2)
                                        Text(relativeMinutes(notif.timestamp))
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: NotificationsView()) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                if appState.unreadCount > 0 {
                                    Circle().fill(.red).frame(width: 8, height: 8).offset(x: 4, y: -4)
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyState(icon: "person.crop.circle", title: "Not logged in", message: "Please log in.")
            }
        }
    }
}

struct NotificationsView: View {
    @Environment(AppState.self) private var appState
    var body: some View {
        List {
            ForEach(appState.myNotifications()) { notif in
                HStack(spacing: 10) {
                    Circle()
                        .fill(notif.isRead ? Color.clear : Color(hex: "#00D47A"))
                        .frame(width: 7, height: 7)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(notif.content).font(.subheadline)
                        Text(relativeMinutes(notif.timestamp)).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Notifications")
        .onAppear { appState.markAllRead() }
    }
}

struct UserProfileView: View {
    @Environment(AppState.self) private var appState
    let user: GymUser

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    AvatarView(user: user, size: 56)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username).font(.title3).bold()
                        Text(user.gym).font(.subheadline).foregroundStyle(.secondary)
                        LevelBadge(level: user.level)
                    }
                }
                .padding(.vertical, 4)
            }

            if !user.bio.isEmpty {
                Section("About") {
                    Text(user.bio).font(.subheadline)
                }
            }

            if !user.goals.isEmpty {
                Section("Goals") {
                    ForEach(user.goals, id: \.self) { g in
                        Text(g).font(.subheadline)
                    }
                }
            }

            if !user.injuries.isEmpty {
                Section("Injuries") {
                    ForEach(user.injuries, id: \.self) { inj in
                        Label(inj, systemImage: "exclamationmark.triangle")
                            .font(.subheadline).foregroundStyle(.orange)
                    }
                }
            }

            if !user.availability.isEmpty {
                Section("Available Days") {
                    Text(user.availability.joined(separator: " · ")).font(.subheadline)
                }
            }

            let hasDetails = user.ageGroup != "Prefer not to say"
                || user.gender != "Prefer not to say"
                || user.preferredWorkoutTime != "Any"
            if hasDetails {
                Section("Details") {
                    if user.ageGroup != "Prefer not to say" {
                        LabeledContent("Age Group", value: user.ageGroup)
                    }
                    if user.gender != "Prefer not to say" {
                        LabeledContent("Gender", value: user.gender)
                    }
                    if user.preferredWorkoutTime != "Any" {
                        LabeledContent("Workout Time", value: user.preferredWorkoutTime)
                    }
                }
            }

            if let myId = appState.currentUserId, myId != user.id {
                let isMatched = appState.currentUser?.matches.contains(user.id) ?? false
                Section {
                    Button {
                        if isMatched { appState.unmatchUser(targetId: user.id) }
                        else         { appState.matchUser(targetId: user.id) }
                    } label: {
                        Text(isMatched ? "Remove Connection" : "Connect")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(isMatched ? .red : Color(hex: "#00D47A"))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct AvatarView: View {
    let user: GymUser
    let size: CGFloat
    var body: some View {
        Text(user.initials)
            .font(.system(size: size * 0.38, weight: .bold))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(Color(hex: user.profileColor))
            .clipShape(Circle())
    }
}

struct LevelBadge: View {
    let level: String
    private var color: Color {
        switch level {
        case "Beginner":     return Color(hex: "#22c55e")
        case "Intermediate": return Color(hex: "#f59e0b")
        case "Advanced":     return Color(hex: "#ef4444")
        default:             return .secondary
        }
    }
    var body: some View {
        Text(level)
            .font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let title = buttonTitle, let action = action {
                Button(action: action) {
                    Text(title).font(.subheadline).fontWeight(.semibold)
                }
                .padding(.top, 4)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
