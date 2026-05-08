// ProfileView.swift

import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var showEdit = false

    var body: some View {
        NavigationStack {
            Group {
                if let user = appState.currentUser {
                    List {
                        Section {
                            HStack(spacing: 16) {
                                AvatarView(user: user, size: 64)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.username).font(.title3).bold()
                                    Text(user.gym).font(.subheadline).foregroundStyle(.secondary)
                                    HStack(spacing: 6) {
                                        LevelBadge(level: user.level)
                                        if user.isAdmin {
                                            Text("Admin").font(.caption2).fontWeight(.semibold)
                                                .padding(.horizontal, 8).padding(.vertical, 3)
                                                .background(Color.purple.opacity(0.15))
                                                .foregroundStyle(.purple)
                                                .clipShape(Capsule())
                                        }
                                    }
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
                                        Text(g).font(.caption).fontWeight(.semibold)
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

                        if !user.availability.isEmpty {
                            Section("Available Days") {
                                Text(user.availability.joined(separator: " · "))
                                    .font(.subheadline)
                            }
                        }

                        Section("Profile Details") {
                            if user.ageGroup != "Prefer not to say" {
                                LabeledContent("Age Group", value: user.ageGroup)
                            }
                            if user.gender != "Prefer not to say" {
                                LabeledContent("Gender", value: user.gender)
                            }
                            LabeledContent("Workout Time", value: user.preferredWorkoutTime)
                        }

                        Section("Stats") {
                            LabeledContent("Matches", value: "\(user.matches.count)")
                            LabeledContent("Upcoming Sessions", value: "\(appState.upcomingSessions().count)")
                            LabeledContent("Saved Workouts", value: "\(appState.myWorkoutPlans().count)")
                        }

                        Section("Appearance") {
                            Toggle(isOn: Binding(
                                get: { appState.isDarkMode },
                                set: { appState.isDarkMode = $0 }
                            )) {
                                Text("Dark Mode")
                            }
                            .tint(Color(hex: "#00D47A"))
                        }

                        Section("Tips & Info") {
                            NavigationLink(destination: SafetyTipsDetailView()) {
                                Text("Safety & Injury Tips")
                            }
                            NavigationLink(destination: CommunicationTipsDetailView()) {
                                Text("Communication Tips")
                            }
                        }

                        Section {
                            Button(role: .destructive) {
                                appState.logout()
                            } label: {
                                Text("Log Out").foregroundStyle(.red)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Profile")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Edit") { showEdit = true }
                        }
                    }
                    .sheet(isPresented: $showEdit) {
                        EditProfileView(user: user)
                    }
                } else {
                    EmptyState(icon: "person.crop.circle", title: "Not logged in", message: "Please log in to view your profile.")
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State var username: String
    @State var gym: String
    @State var level: String
    @State var bio: String
    @State var goals: [String]
    @State var injuries: [String]
    @State var availability: [String]
    @State var profileColor: String
    @State var ageGroup: String
    @State var gender: String
    @State var preferredWorkoutTime: String

    init(user: GymUser) {
        _username             = State(initialValue: user.username)
        _gym                  = State(initialValue: user.gym)
        _level                = State(initialValue: user.level)
        _bio                  = State(initialValue: user.bio)
        _goals                = State(initialValue: Array(user.goals))
        _injuries             = State(initialValue: Array(user.injuries))
        _availability         = State(initialValue: Array(user.availability))
        _profileColor         = State(initialValue: user.profileColor)
        _ageGroup             = State(initialValue: user.ageGroup)
        _gender               = State(initialValue: user.gender)
        _preferredWorkoutTime = State(initialValue: user.preferredWorkoutTime)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Username", text: $username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Gym & Level") {
                    Picker("Gym", selection: $gym) {
                        ForEach(gymList, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Level", selection: $level) {
                        ForEach(["Beginner","Intermediate","Advanced"], id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Personal Details") {
                    Picker("Age Group", selection: $ageGroup) {
                        ForEach(allAgeGroups, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Gender", selection: $gender) {
                        ForEach(allGenders, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Preferred Workout Time", selection: $preferredWorkoutTime) {
                        ForEach(allWorkoutTimes, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Profile Colour") {
                    HStack(spacing: 10) {
                        ForEach(profileColors, id: \.self) { c in
                            Circle().fill(Color(hex: c)).frame(width: 30, height: 30)
                                .overlay(profileColor == c ? Circle().stroke(Color.white, lineWidth: 3) : nil)
                                .onTapGesture { profileColor = c }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Available Days") {
                    FlowLayout(spacing: 6) {
                        ForEach(allDays, id: \.self) { day in
                            let on = availability.contains(day)
                            Button { toggle(&availability, day) } label: {
                                Text(day).font(.caption).fontWeight(.semibold)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(on ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                    .foregroundColor(on ? .black : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Fitness Goals") {
                    FlowLayout(spacing: 6) {
                        ForEach(allGoals, id: \.self) { g in
                            let on = goals.contains(g)
                            Button { toggle(&goals, g) } label: {
                                Text(g).font(.caption).fontWeight(.semibold)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(on ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                    .foregroundColor(on ? .black : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Injury Constraints") {
                    FlowLayout(spacing: 6) {
                        ForEach(allInjuries, id: \.self) { inj in
                            let on = injuries.contains(inj)
                            Button { toggle(&injuries, inj) } label: {
                                Text(inj).font(.caption).fontWeight(.semibold)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(on ? Color.orange.opacity(0.2) : Color(.secondarySystemBackground))
                                    .foregroundColor(on ? .orange : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func toggle(_ arr: inout [String], _ val: String) {
        if arr.contains(val) { arr.removeAll { $0 == val } }
        else { arr.append(val) }
    }

    private func save() {
        guard let user = appState.currentUser else { return }
        appState.updateUser(
            id: user.id, username: username, gym: gym, level: level, bio: bio,
            goals: goals, injuries: injuries, availability: availability,
            profileColor: profileColor, ageGroup: ageGroup,
            gender: gender, preferredWorkoutTime: preferredWorkoutTime
        )
        dismiss()
    }
}

struct SafetyTipsDetailView: View {
    var body: some View {
        List {
            Section("Shoulder Safety") {
                ForEach(["Avoid painful ranges and heavy vertical presses.",
                          "Prioritise scapular control and neutral grips.",
                          "Progress load gradually — form before weight.",
                          "Include face pulls and band external rotations for shoulder health."], id: \.self) { tip in
                    Text(tip)
                }
            }
            Section("Knee Safety") {
                ForEach(["Avoid high-impact activities when recovering.",
                          "Strengthen glutes — they reduce knee joint load.",
                          "Keep the knee tracking over the toe, not caving inward.",
                          "Stop any exercise that causes sharp pain or swelling."], id: \.self) { tip in
                    Text(tip)
                }
            }
            Section("General") {
                ForEach(["Warm up 5–10 min before intense work.",
                          "Stop any exercise that causes sharp pain.",
                          "Hydrate and rest adequately.",
                          "Consult a physio for persistent injuries."], id: \.self) { tip in
                    Text(tip)
                }
            }
        }
        .navigationTitle("Safety Tips")
        .listStyle(.insetGrouped)
    }
}

struct CommunicationTipsDetailView: View {
    var body: some View {
        List {
            Section("Low-Pressure Icebreakers") {
                ForEach(["\"Hey, are you using this bench?\"",
                          "\"Mind if I work in between sets?\"",
                          "\"Could you spot me for one set?\"",
                          "\"Do you know how this machine works?\""], id: \.self) { line in
                    Text(line)
                }
            }
            Section("Confidence Builders") {
                ForEach(["Use simple questions and smile — most people are happy to chat.",
                          "Keep it brief and respectful of their time.",
                          "Thank your partner after the session.",
                          "Remember: most regulars were once beginners too."], id: \.self) { tip in
                    Text(tip)
                }
            }
        }
        .navigationTitle("Communication Tips")
        .listStyle(.insetGrouped)
    }
}
