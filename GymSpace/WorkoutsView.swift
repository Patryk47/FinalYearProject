// WorkoutsView.swift

import SwiftUI
import SafariServices

struct WorkoutsView: View {
    @Environment(AppState.self) private var appState
    @State private var tab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $tab) {
                    Text("My Plans").tag(0)
                    Text("Generate").tag(1)
                    Text("Sessions").tag(2)
                    Text("AI Coach").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                Divider()

                Group {
                    switch tab {
                    case 0:  MyPlansTab()
                    case 1:  GenerateTab()
                    case 2:  SessionsTab()
                    default: AICoachView()
                    }
                }
            }
            .navigationTitle("Workouts")
        }
    }
}


private struct MyPlansTab: View {
    @Environment(AppState.self) private var appState
    @State private var expandedId: String? = nil

    var body: some View {
        let plans = appState.myWorkoutPlans()
        ScrollView {
            if plans.isEmpty {
                EmptyState(icon: "list.clipboard",
                           title: "No saved plans yet",
                           message: "Generate a personalised workout plan tailored to your level, goals and any injuries.",
                           buttonTitle: nil)
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                VStack(spacing: 12) {
                    ForEach(plans) { plan in
                        WorkoutPlanCard(plan: plan, expandedId: $expandedId) {
                            appState.deleteWorkoutPlan(id: plan.id)
                        }
                    }
                }
                .padding()
            }
        }
    }
}


private let allMuscleGroups: [(key: String, label: String, icon: String)] = [
    ("chest",     "Chest",       "figure.strengthtraining.functional"),
    ("back",      "Back",        "figure.rowing"),
    ("legs",      "Legs",        "figure.run"),
    ("shoulders", "Shoulders",   "figure.arms.open"),
    ("arms",      "Arms",        "dumbbell.fill"),
    ("core",      "Core",        "circle.grid.cross.fill"),
    ("cardio",    "Cardio",      "heart.fill"),
]

private struct GenerateTab: View {
    @Environment(AppState.self) private var appState
    @State private var duration = 45
    @State private var selectedGroups: Set<String> = ["chest", "back", "legs", "core"]
    @State private var generated: WorkoutPlan? = nil
    @State private var saved = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                if let user = appState.currentUser {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AI Workout Generator")
                            .font(.headline)
                        Text("Pick your body parts, set a duration, and get a plan built around your injuries and schedule.")
                            .font(.caption).foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            LevelBadge(level: user.level)
                            ForEach(user.injuries, id: \.self) { inj in
                                Text("\(inj) injury").font(.caption2).fontWeight(.semibold)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundStyle(.red)
                                    .clipShape(Capsule())
                            }
                        }
                        if !user.availability.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar").font(.caption2).foregroundStyle(.secondary)
                                Text("Training days: \(user.availability.joined(separator: " · "))")
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#00D47A").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Body Parts").font(.subheadline).fontWeight(.semibold)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(allMuscleGroups, id: \.key) { group in
                            let on = selectedGroups.contains(group.key)
                            Button {
                                if on { selectedGroups.remove(group.key) }
                                else  { selectedGroups.insert(group.key) }
                            } label: {
                                Text(group.label)
                                    .font(.caption2).fontWeight(.semibold)
                                    .foregroundColor(on ? .black : .primary)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(on ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Duration").font(.subheadline).fontWeight(.semibold)
                    HStack(spacing: 10) {
                        ForEach([30, 45, 60], id: \.self) { d in
                            Button { duration = d } label: {
                                Text("\(d) min")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(duration == d ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                    .foregroundColor(duration == d ? .black : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    generate()
                } label: {
                    Text("Generate Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity).padding()
                        .background(selectedGroups.isEmpty ? Color(.systemGray4) : Color(hex: "#00D47A"))
                        .foregroundColor(selectedGroups.isEmpty ? .secondary : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedGroups.isEmpty)
                .buttonStyle(.plain)

                if let plan = generated {
                    GeneratedPlanView(plan: plan, saved: $saved) {
                        if let p = generated {
                            appState.saveWorkoutPlan(p)
                            saved = true
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func generate() {
        guard let user = appState.currentUser else { return }
        let orderedKeys = allMuscleGroups.map(\.key).filter { selectedGroups.contains($0) }
        let plan = AIWorkoutGenerator.generate(
            level: user.level,
            goals: Array(user.goals),
            injuries: Array(user.injuries),
            duration: duration,
            selectedGroups: orderedKeys,
            availableDays: Array(user.availability)
        )
        generated = plan
        saved = false
    }
}

private struct GeneratedPlanView: View {
    let plan: WorkoutPlan
    @Binding var saved: Bool
    let onSave: () -> Void
    @State private var showYouTube: URL? = nil

    var body: some View {
        VStack(spacing: 12) {
            if !plan.injuryAdvice.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Injury Safety Advice", systemImage: "cross.case.fill")
                        .font(.subheadline).fontWeight(.bold).foregroundStyle(.orange)
                    ForEach(plan.injuryAdvice, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundStyle(.orange)
                            Text(tip).font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            ForEach(plan.muscleGroups) { group in
                MuscleGroupCard(group: group, showYouTube: $showYouTube)
            }

            if !plan.formTips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beginner Form Tips").font(.subheadline).fontWeight(.bold).foregroundStyle(.blue)
                    ForEach(plan.formTips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundStyle(.blue)
                            Text(tip).font(.caption)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text(plan.disclaimer)
                .font(.caption2).foregroundStyle(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: onSave) {
                Text(saved ? "Saved to My Plans" : "Save Workout Plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity).padding()
                    .background(saved ? Color(.secondarySystemBackground) : Color(hex: "#00D47A"))
                    .foregroundColor(saved ? .secondary : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(saved)
            .buttonStyle(.plain)
        }
        .sheet(item: Binding(
            get: { showYouTube.map { YouTubeLink(url: $0) } },
            set: { showYouTube = $0?.url }
        )) { link in
            SafariSheet(url: link.url)
        }
    }
}

private struct MuscleGroupCard: View {
    let group: WorkoutMuscleGroup
    @Binding var showYouTube: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(group.name).font(.subheadline).fontWeight(.bold)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                Spacer()
            }
            .background(Color(hex: "#00D47A").opacity(0.12))

            ForEach(group.exercises) { ex in
                ExerciseRow(exercise: ex, showYouTube: $showYouTube)
                if ex.id != group.exercises.last?.id { Divider().padding(.leading, 14) }
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ExerciseRow: View {
    let exercise: WorkoutExercise
    @Binding var showYouTube: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                Circle().fill(Color(hex: "#00D47A")).frame(width: 7, height: 7)
                    .padding(.top, 6)
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name).font(.subheadline)
                    if !exercise.tip.isEmpty {
                        Text(exercise.tip).font(.caption).foregroundStyle(.secondary)
                    }
                    if !exercise.injuryModification.isEmpty {
                        Text(exercise.injuryModification).font(.caption2).foregroundStyle(.orange)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(exercise.sets).font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "#00D47A"))
                    if let url = exercise.youtubeSearchURL {
                        Button {
                            showYouTube = url
                        } label: {
                            Text("Link to exercise")
                                .font(.caption2)
                                .underline()
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

private struct SessionsTab: View {
    @Environment(AppState.self) private var appState
    @State private var ratingSession: GymSession? = nil
    @State private var ratingValue = 0

    var body: some View {
        let sessions = appState.upcomingSessions()
        ScrollView {
            if sessions.isEmpty {
                EmptyState(icon: "calendar",
                           title: "No upcoming sessions",
                           message: "Schedule gym sessions with your matches from the chat screen.")
                .padding(.top, 60)
            } else {
                VStack(spacing: 12) {
                    ForEach(sessions) { session in
                        UpcomingSessionCard(session: session,
                                           ratingSession: $ratingSession) {
                            appState.confirmSession(id: session.id)
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $ratingSession) { session in
            RatingSheet(session: session) { rating in
                appState.rateSession(id: session.id, rating: rating)
                ratingSession = nil
            }
        }
    }
}

private struct UpcomingSessionCard: View {
    @Environment(AppState.self) private var appState
    let session: GymSession
    @Binding var ratingSession: GymSession?
    let onConfirm: () -> Void

    private var partner: GymUser? {
        session.participants
            .first { $0 != appState.currentUserId }
            .flatMap { id in appState.users.first { $0.id == id } }
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(session.dateTime.formatted(.dateTime.day()))
                    .font(.title2).bold().foregroundStyle(Color(hex: "#00D47A"))
                Text(session.dateTime.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .frame(width: 44).padding(.vertical, 10)
            .background(Color(hex: "#00D47A").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text("With \(partner?.username ?? "Partner")").font(.subheadline).bold()
                Text(session.dateTime.formatted(.dateTime.hour().minute()))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                StatusBadge(status: session.status)
                if session.status == "pending" && session.createdBy != appState.currentUserId {
                    Button("Confirm", action: onConfirm)
                        .font(.caption).fontWeight(.semibold)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color(hex: "#00D47A"))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                        .buttonStyle(.plain)
                }
                if session.status == "confirmed" && session.rating == nil {
                    Button("Rate") { ratingSession = session }
                        .font(.caption).fontWeight(.semibold)
                        .buttonStyle(.bordered)
                }
                if let r = session.rating {
                    Text("\(r)/5").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct StatusBadge: View {
    let status: String
    var body: some View {
        let (label, color): (String, Color) = switch status {
        case "confirmed": ("Confirmed", Color(hex: "#00D47A"))
        case "declined":  ("Declined",  .red)
        default:          ("Pending",   .orange)
        }
        Text(label).font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

private struct RatingSheet: View {
    @Environment(\.dismiss) private var dismiss
    let session: GymSession
    let onSubmit: (Int) -> Void
    @State private var rating = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Rate Your Session").font(.title3).bold()
            Text("How was your training session?").foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { s in
                    Image(systemName: s <= rating ? "star.fill" : "star")
                        .font(.system(size: 40))
                        .foregroundStyle(s <= rating ? Color.yellow : Color(.systemGray4))
                        .onTapGesture { rating = s }
                }
            }
            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .buttonStyle(.plain)

                Button("Submit") { onSubmit(rating) }
                    .frame(maxWidth: .infinity).padding()
                    .background(rating > 0 ? Color(hex: "#00D47A") : Color(.systemGray4))
                    .foregroundColor(rating > 0 ? .black : .secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(rating == 0)
                    .buttonStyle(.plain)
            }
        }
        .padding(28)
        .presentationDetents([.height(300)])
    }
}

private struct WorkoutPlanCard: View {
    let plan: WorkoutPlan
    @Binding var expandedId: String?
    let onDelete: () -> Void

    @State private var showYouTube: URL? = nil

    private var isExpanded: Bool { expandedId == plan.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedId = isExpanded ? nil : plan.id
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(plan.level) · \(plan.duration) min")
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#00D47A"))
                        Text(plan.muscleGroups.map { $0.name }.joined(separator: " · "))
                            .font(.caption).foregroundStyle(.secondary)
                        Text("Saved \(plan.createdAt.formatted(.dateTime.day().month().year()))")
                            .font(.caption2).foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary).font(.caption)
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash").font(.caption).foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 8)
                }
                .padding()
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                VStack(spacing: 0) {
                    if !plan.injuryAdvice.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Injury Safety Advice", systemImage: "cross.case.fill")
                                .font(.caption).fontWeight(.bold).foregroundStyle(.orange)
                            ForEach(Array(plan.injuryAdvice.prefix(3)), id: \.self) { tip in
                                Text("• \(tip)").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.06))
                    }

                    ForEach(plan.muscleGroups) { group in
                        MuscleGroupCard(group: group, showYouTube: $showYouTube)
                            .padding(.horizontal).padding(.vertical, 4)
                    }

                    Text(plan.disclaimer).font(.caption2).foregroundStyle(.secondary)
                        .padding()
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .sheet(item: Binding(
            get: { showYouTube.map { YouTubeLink(url: $0) } },
            set: { showYouTube = $0?.url }
        )) { link in
            SafariSheet(url: link.url)
        }
    }
}

struct YouTubeLink: Identifiable {
    let id = UUID()
    let url: URL
}

struct SafariSheet: View {
    let url: URL
    var body: some View {
        if #available(iOS 16.4, *) {
            SafariWrapper(url: url)
                .ignoresSafeArea()
        } else {
            VStack(spacing: 16) {
                Text("Watch on YouTube").font(.headline)
                Link("Open in YouTube", destination: url)
                    .font(.subheadline)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
            }
            .padding()
        }
    }
}

private struct SafariWrapper: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

