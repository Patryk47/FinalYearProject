// DiscoverView.swift

import SwiftUI

struct DiscoverView: View {
    @Environment(AppState.self) private var appState
    @State private var levelFilter      = "All"
    @State private var gymFilter        = "All"
    @State private var ageFilter        = "All"
    @State private var genderFilter     = "All"
    @State private var timeFilter       = "All"
    @State private var searchText       = ""

    private var suggestions: [(user: GymUser, score: Int)] {
        var all = appState.suggestedPartners()
        if levelFilter != "All"  { all = all.filter { $0.user.level    == levelFilter } }
        if gymFilter   != "All"  { all = all.filter { $0.user.gym      == gymFilter   } }
        if ageFilter   != "All"  { all = all.filter { $0.user.ageGroup == ageFilter   } }
        if genderFilter != "All" { all = all.filter {
            $0.user.gender == genderFilter || $0.user.gender == "Prefer not to say"
        }}
        if timeFilter  != "All"  { all = all.filter {
            $0.user.preferredWorkoutTime == timeFilter || $0.user.preferredWorkoutTime == "Any"
        }}
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            all = all.filter {
                $0.user.username.lowercased().contains(q) ||
                $0.user.gym.lowercased().contains(q)
            }
        }
        return all
    }

    private var allGyms: [String] {
        Array(Set(appState.users.filter { !$0.isAdmin && !$0.isBanned }.map { $0.gym })).sorted()
    }

    private var hasActiveFilters: Bool {
        levelFilter != "All" || gymFilter != "All" || ageFilter != "All"
            || genderFilter != "All" || timeFilter != "All" || !searchText.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(label: "All Levels",
                                   options: ["All", "Beginner", "Intermediate", "Advanced"],
                                   selection: $levelFilter)
                        FilterChip(label: "All Gyms",
                                   options: ["All"] + allGyms,
                                   selection: $gymFilter)
                        FilterChip(label: "Any Age",
                                   options: ["All", "18-24", "25-34", "35-44", "45+"],
                                   selection: $ageFilter)
                        FilterChip(label: "Any Gender",
                                   options: ["All", "Male", "Female", "Non-binary"],
                                   selection: $genderFilter)
                        FilterChip(label: "Any Time",
                                   options: ["All", "Morning", "Afternoon", "Evening"],
                                   selection: $timeFilter)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                Divider()

                if suggestions.isEmpty {
                    EmptyState(icon: "magnifyingglass",
                               title: "No matches found",
                               message: "Try adjusting your filters.",
                               buttonTitle: hasActiveFilters ? "Clear Filters" : nil) {
                        levelFilter = "All"; gymFilter = "All"; ageFilter = "All"
                        genderFilter = "All"; timeFilter = "All"; searchText = ""
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(suggestions, id: \.user.id) { item in
                            NavigationLink(destination: UserProfileView(user: item.user)) {
                                PartnerRow(user: item.user, score: item.score)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, prompt: "Search by name or gym")
        }
    }
}

private struct FilterChip: View {
    let label: String
    let options: [String]
    @Binding var selection: String

    var isActive: Bool { selection != "All" }

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { opt in
                Button(opt) { selection = opt }
            }
        } label: {
            HStack(spacing: 4) {
                Text(isActive ? selection : label)
                    .font(.subheadline).fontWeight(.semibold)
                Image(systemName: "chevron.down").font(.caption2)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(isActive
                ? Color(hex: "#00D47A").opacity(0.15)
                : Color(.secondarySystemBackground))
            .foregroundStyle(isActive ? Color(hex: "#00D47A") : .primary)
            .clipShape(Capsule())
        }
    }
}

private struct PartnerRow: View {
    @Environment(AppState.self) private var appState
    let user: GymUser
    let score: Int

    private var isMatched: Bool {
        appState.currentUser?.matches.contains(user.id) ?? false
    }

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(user: user, size: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(user.username).font(.subheadline).bold()
                Text(user.gym).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    LevelBadge(level: user.level)
                    Text("\(score)% match").font(.caption2).foregroundStyle(.secondary)
                    if user.preferredWorkoutTime != "Any" {
                        Text(user.preferredWorkoutTime)
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                if isMatched { appState.unmatchUser(targetId: user.id) }
                else         { appState.matchUser(targetId: user.id) }
            } label: {
                Text(isMatched ? "Connected" : "Connect")
                    .font(.caption).fontWeight(.semibold)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(isMatched
                        ? Color(.secondarySystemBackground)
                        : Color(hex: "#00D47A"))
                    .foregroundColor(isMatched ? .secondary : .black)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
