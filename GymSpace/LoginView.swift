// LoginView.swift

import SwiftUI

let gymList         = ["Fitness First London","PureGym Canary Wharf",
                       "Anytime Fitness Manchester","The Gym Group Birmingham",
                       "Virgin Active Oxford Street","David Lloyd Leeds",
                       "GymSpace HQ","Other"]
let allDays         = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
let allGoals        = ["Weight Loss","Muscle Gain","Build Confidence","Cardio Fitness",
                       "Powerlifting","Performance","Injury Recovery","Maintain Fitness"]
let allInjuries     = ["Shoulder","Knee","Back","Hip","Elbow","Ankle"]
let profileColors   = ["#f59e0b","#ec4899","#8b5cf6","#3b82f6","#ef4444","#10b981","#06b6d4","#f97316"]
let allAgeGroups    = ["18-24","25-34","35-44","45+","Prefer not to say"]
let allGenders      = ["Male","Female","Non-binary","Prefer not to say"]
let allWorkoutTimes = ["Morning","Afternoon","Evening","Any"]

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var tab: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 56))
                        .foregroundStyle(Color(hex: "#00D47A"))
                    Text("GymSpace")
                        .font(.largeTitle).bold()
                    Text("Find your perfect training partner")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.top, 48)
                .padding(.bottom, 28)

                Picker("", selection: $tab) {
                    Text("Log In").tag(0)
                    Text("Sign Up").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                if tab == 0 {
                    LoginForm()
                        .padding(.horizontal, 24)
                } else {
                    RegisterForm()
                        .padding(.horizontal, 24)
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemBackground))
    }
}

private struct LoginForm: View {
    @Environment(AppState.self) private var appState
    @State private var username = ""
    @State private var password = ""
    @State private var errorMsg  = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            if !errorMsg.isEmpty {
                ErrorBanner(message: errorMsg)
            }
            GSTextField("Username or Email", text: $username, icon: "person")
            GSTextField("Password", text: $password, icon: "lock", secure: true)

            Button { doLogin() } label: {
                Group {
                    if isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text("Log In").font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#00D47A"))
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(isLoading)

            Text("— demo accounts —")
                .font(.caption).foregroundStyle(.secondary)
                .padding(.top, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach([
                    ("Max (Beginner)",    "MaxNewbie",    "demo123"),
                    ("Emma (Beginner)",   "EmmaFit",      "demo123"),
                    ("Mia (Advanced)",    "MiaElite",     "demo123"),
                    ("Mike (Injury)",     "MikeRecovery", "demo123"),
                ], id: \.0) { name, user, pass in
                    Button {
                        quickLogin(user, pass)
                    } label: {
                        Text(name)
                            .font(.caption).fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func doLogin() {
        errorMsg = ""
        isLoading = true
        Task {
            let result = await appState.login(usernameOrEmail: username, password: password)
            isLoading = false
            if case .failure(let err) = result { errorMsg = err.errorDescription ?? "" }
        }
    }

    private func quickLogin(_ u: String, _ p: String) {
        errorMsg = ""
        isLoading = true
        Task {
            let result = await appState.login(usernameOrEmail: u, password: p)
            isLoading = false
            if case .failure(let err) = result { errorMsg = err.errorDescription ?? "" }
        }
    }
}

private struct RegisterForm: View {
    @Environment(AppState.self) private var appState
    @State private var step = 1

    @State private var username    = ""
    @State private var email       = ""
    @State private var password    = ""
    @State private var confirm     = ""
    @State private var pickedColor = profileColors[0]

    @State private var gym          = ""
    @State private var level        = "Beginner"
    @State private var availability: [String] = []
    @State private var ageGroup     = "Prefer not to say"
    @State private var gender       = "Prefer not to say"
    @State private var workoutTime  = "Any"

    @State private var goals:    [String] = []
    @State private var injuries: [String] = []
    @State private var bio = ""

    @State private var errorMsg  = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                ForEach(1...3, id: \.self) { s in
                    Capsule()
                        .fill(s <= step ? Color(hex: "#00D47A") : Color(.systemGray5))
                        .frame(height: 4)
                }
            }

            if !errorMsg.isEmpty { ErrorBanner(message: errorMsg) }

            switch step {
            case 1: step1
            case 2: step2
            default: step3
            }
        }
    }

    @ViewBuilder
    private var step1: some View {
        VStack(spacing: 14) {
            GSTextField("Username", text: $username, icon: "person")
            GSTextField("Email", text: $email, icon: "envelope")
            GSTextField("Password (min 6 chars)", text: $password, icon: "lock", secure: true)
            GSTextField("Confirm Password", text: $confirm, icon: "lock.fill", secure: true)

            VStack(alignment: .leading, spacing: 8) {
                Text("Profile Colour").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    ForEach(profileColors, id: \.self) { c in
                        Circle()
                            .fill(Color(hex: c))
                            .frame(width: 32, height: 32)
                            .overlay(pickedColor == c
                                ? Circle().stroke(Color.white, lineWidth: 3)
                                : nil)
                            .onTapGesture { pickedColor = c }
                    }
                }
            }

            NavButtons(backLabel: nil, nextLabel: "Continue") { validateStep1() }
        }
    }

    @ViewBuilder
    private var step2: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Gym").font(.caption).foregroundStyle(.secondary)
                Menu {
                    ForEach(gymList, id: \.self) { g in
                        Button(g) { gym = g }
                    }
                } label: {
                    HStack {
                        Text(gym.isEmpty ? "Select gym…" : gym)
                            .foregroundStyle(gym.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Fitness Level").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach(["Beginner","Intermediate","Advanced"], id: \.self) { l in
                        Button { level = l } label: {
                            Text(l).font(.subheadline).fontWeight(.semibold)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(level == l ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                .foregroundColor(level == l ? .black : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            TagPicker(title: "Available Days", options: allDays, selected: $availability)

            VStack(alignment: .leading, spacing: 6) {
                Text("Age Group").font(.caption).foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(allAgeGroups, id: \.self) { ag in
                            Button { ageGroup = ag } label: {
                                Text(ag).font(.caption).fontWeight(.semibold)
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(ageGroup == ag ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                    .foregroundColor(ageGroup == ag ? .black : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Gender").font(.caption).foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(allGenders, id: \.self) { g in
                            Button { gender = g } label: {
                                Text(g).font(.caption).fontWeight(.semibold)
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(gender == g ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                    .foregroundColor(gender == g ? .black : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Preferred Workout Time").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach(allWorkoutTimes, id: \.self) { t in
                        Button { workoutTime = t } label: {
                            Text(t).font(.caption).fontWeight(.semibold)
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(workoutTime == t ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                                .foregroundColor(workoutTime == t ? .black : .primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            NavButtons(backLabel: "Back", nextLabel: "Continue") {
                validateStep2()
            } onBack: { step = 1 }
        }
    }

    @ViewBuilder
    private var step3: some View {
        VStack(spacing: 14) {
            TagPicker(title: "Fitness Goals (pick all that apply)", options: allGoals, selected: $goals)
            TagPicker(title: "Injury Constraints (optional)", options: allInjuries, selected: $injuries)

            VStack(alignment: .leading, spacing: 6) {
                Text("Bio (optional)").font(.caption).foregroundStyle(.secondary)
                TextEditor(text: $bio)
                    .frame(height: 80)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            NavButtons(backLabel: "Back", nextLabel: "Create Account", isLoading: isLoading) {
                validateStep3()
            } onBack: { step = 2 }
        }
    }

    private func validateStep1() {
        errorMsg = ""
        if username.count < 3 { errorMsg = "Username must be at least 3 characters."; return }
        if !email.contains("@") { errorMsg = "Enter a valid email address."; return }
        if password.count < 6  { errorMsg = "Password must be at least 6 characters."; return }
        if password != confirm  { errorMsg = "Passwords do not match."; return }
        step = 2
    }

    private func validateStep2() {
        errorMsg = ""
        if gym.isEmpty  { errorMsg = "Please select your gym."; return }
        step = 3
    }

    private func validateStep3() {
        errorMsg = ""
        if goals.isEmpty { errorMsg = "Select at least one fitness goal."; return }
        isLoading = true
        Task {
            let result = await appState.register(
                username: username, email: email, password: password,
                level: level, gym: gym, availability: availability,
                goals: goals, injuries: injuries, bio: bio,
                profileColor: pickedColor,
                ageGroup: ageGroup, gender: gender,
                preferredWorkoutTime: workoutTime
            )
            isLoading = false
            if case .failure(let err) = result {
                errorMsg = err.errorDescription ?? ""
                step = 1
            }
        }
    }
}


private struct GSTextField: View {
    let label: String
    @Binding var text: String
    let icon: String
    var secure: Bool = false

    init(_ label: String, text: Binding<String>, icon: String, secure: Bool = false) {
        self.label = label; self._text = text; self.icon = icon; self.secure = secure
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(.secondary).frame(width: 20)
            if secure {
                SecureField(label, text: $text)
            } else {
                TextField(label, text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct TagPicker: View {
    let title: String
    let options: [String]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { opt in
                    let on = selected.contains(opt)
                    Button { toggle(opt) } label: {
                        Text(opt).font(.caption).fontWeight(.semibold)
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .background(on ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                            .foregroundColor(on ? .black : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggle(_ v: String) {
        if selected.contains(v) { selected.removeAll { $0 == v } }
        else { selected.append(v) }
    }
}

private struct NavButtons: View {
    var backLabel: String?
    let nextLabel: String
    var isLoading: Bool = false
    let onNext: () -> Void
    var onBack: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let back = backLabel {
                Button { onBack?() } label: {
                    Text(back).font(.subheadline).fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
            }
            Button { onNext() } label: {
                Group {
                    if isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text(nextLabel).font(.headline)
                    }
                }
                .frame(maxWidth: .infinity).padding()
                .background(Color(hex: "#00D47A"))
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
        .padding(.top, 4)
    }
}

private struct ErrorBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.red)
            Text(message).font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
                         .reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(0, height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowH = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowH + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        for subview in subviews {
            let w = subview.sizeThatFits(.unspecified).width
            if rowWidth + w > maxWidth, !rows[rows.endIndex - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.endIndex - 1].append(subview)
            rowWidth += w + spacing
        }
        return rows
    }
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF)          / 255
        self.init(red: r, green: g, blue: b)
    }
}
