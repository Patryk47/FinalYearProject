// ChatsView.swift

import SwiftUI

struct ChatsView: View {
    @Environment(AppState.self) private var appState
    @State private var segment = 0

    private var allMatches: [GymUser] {
        guard let me = appState.currentUser else { return [] }
        return me.matches.compactMap { id in appState.users.first { $0.id == id } }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $segment) {
                    Text("Matches").tag(0)
                    Text("Messages").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider()

                if segment == 0 {
                    MatchesPage(matches: allMatches)
                } else {
                    MessagesPage()
                }
            }
            .navigationTitle("Connections")
        }
    }
}

private struct MatchesPage: View {
    let matches: [GymUser]

    var body: some View {
        if matches.isEmpty {
            EmptyState(
                icon: "person.2",
                title: "No matches yet",
                message: "Connect with gym partners in Discover to see them here.")
            .frame(maxHeight: .infinity)
        } else {
            List {
                ForEach(matches) { user in
                    NavigationLink(destination: MatchDetailView(user: user)) {
                        MatchRow(user: user)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

private struct MessagesPage: View {
    @Environment(AppState.self) private var appState

    private var chats: [AppState.ChatPreview] {
        appState.getChats()
    }

    var body: some View {
        if chats.isEmpty {
            EmptyState(
                icon: "bubble.left.and.bubble.right",
                title: "No conversations yet",
                message: "Match with gym partners in Discover, then start chatting!")
            .frame(maxHeight: .infinity)
        } else {
            List {
                ForEach(chats, id: \.chatId) { preview in
                    NavigationLink(destination: ChatDetailView(otherUser: preview.otherUser)) {
                        HStack(spacing: 12) {
                            AvatarView(user: preview.otherUser, size: 48)
                            Text(preview.otherUser.username).font(.subheadline).bold()
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            appState.deleteChat(with: preview.otherUser.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

private struct MatchRow: View {
    let user: GymUser

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(user: user, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(user.username).font(.subheadline).bold()
                Text(user.gym).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    LevelBadge(level: user.level)
                    if user.preferredWorkoutTime != "Any" {
                        Text(user.preferredWorkoutTime)
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct MatchDetailView: View {
    @Environment(AppState.self) private var appState
    let user: GymUser

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    AvatarView(user: user, size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username).font(.title3).bold()
                        Text(user.gym).font(.subheadline).foregroundStyle(.secondary)
                        LevelBadge(level: user.level)
                    }
                }
                .padding(.vertical, 6)
            }

            if !user.bio.isEmpty {
                Section("About") {
                    Text(user.bio).font(.subheadline)
                }
            }

            if !user.goals.isEmpty {
                Section("Fitness Goals") {
                    FlowLayout(spacing: 6) {
                        ForEach(user.goals, id: \.self) { g in
                            Text(g)
                                .font(.caption).fontWeight(.semibold)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color(hex: "#00D47A").opacity(0.12))
                                .foregroundStyle(Color(hex: "#00D47A"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if !user.injuries.isEmpty {
                Section("Injury Constraints") {
                    FlowLayout(spacing: 6) {
                        ForEach(user.injuries, id: \.self) { inj in
                            Label(inj, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption).fontWeight(.semibold)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.orange.opacity(0.12))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Schedule") {
                if !user.availability.isEmpty {
                    LabeledContent("Available", value: user.availability.joined(separator: " · "))
                }
                if user.preferredWorkoutTime != "Any" {
                    LabeledContent("Prefers", value: user.preferredWorkoutTime)
                }
            }

            let hasDetails = user.ageGroup != "Prefer not to say" || user.gender != "Prefer not to say"
            if hasDetails {
                Section("Details") {
                    if user.ageGroup != "Prefer not to say" {
                        LabeledContent("Age Group", value: user.ageGroup)
                    }
                    if user.gender != "Prefer not to say" {
                        LabeledContent("Gender", value: user.gender)
                    }
                }
            }

            Section {
                NavigationLink(destination: ChatDetailView(otherUser: user)) {
                    Text("Send Message")
                        .foregroundStyle(Color(hex: "#00D47A"))
                        .fontWeight(.semibold)
                }
            }

            Section {
                Button(role: .destructive) {
                    appState.unmatchUser(targetId: user.id)
                } label: {
                    Text("Remove Match")
                        .foregroundStyle(.red)
                }
            } footer: {
                Text("Removes this person from your matches. Your conversation history is kept separately.")
                    .font(.caption)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }
}
