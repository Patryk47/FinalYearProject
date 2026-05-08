// AppState.swift

import SwiftUI
import RealmSwift

@Observable
final class AppState {

    var currentUserId: String?
    var users:         [GymUser]         = []
    var messages:      [ChatMessage]     = []
    var notifications: [GymNotification] = []
    var workoutPlans:  [WorkoutPlan]     = []
    var sessions:      [GymSession]      = []
    var isDarkMode:    Bool              = UserDefaults.standard.bool(forKey: "gs_dark_mode") {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "gs_dark_mode") }
    }
    var isLoading:     Bool              = false

    var isLoggedIn: Bool    { currentUserId != nil }
    var currentUser: GymUser? { users.first { $0.id == currentUserId } }

    private var realm: Realm!
    private let kCurrentId = "gs_current_user_id"

    init() {
        setupRealm()
    }

    private func setupRealm() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Realm failed to initialise: \(error)")
        }
        seedIfEmpty()
        refreshAll()
        currentUserId = UserDefaults.standard.string(forKey: kCurrentId)
    }

    private func seedIfEmpty() {
        guard realm.objects(GymUser.self).isEmpty else { return }
        try! realm.write {
            SeedData.makeUsers().forEach        { realm.add($0) }
            SeedData.makeMessages().forEach     { realm.add($0) }
            SeedData.makeNotifications().forEach { realm.add($0) }
        }
    }

    private func refreshAll() {
        users         = Array(realm.objects(GymUser.self))
        messages      = Array(realm.objects(ChatMessage.self).sorted(byKeyPath: "timestamp"))
        notifications = Array(realm.objects(GymNotification.self).sorted(byKeyPath: "timestamp", ascending: false))
        workoutPlans  = Array(realm.objects(WorkoutPlan.self).sorted(byKeyPath: "createdAt", ascending: false))
        sessions      = Array(realm.objects(GymSession.self))
    }

    private func refreshUsers()    { users         = Array(realm.objects(GymUser.self)) }
    private func refreshMessages() { messages      = Array(realm.objects(ChatMessage.self).sorted(byKeyPath: "timestamp")) }
    private func refreshNotifs()   { notifications = Array(realm.objects(GymNotification.self).sorted(byKeyPath: "timestamp", ascending: false)) }
    private func refreshWorkouts() { workoutPlans  = Array(realm.objects(WorkoutPlan.self).sorted(byKeyPath: "createdAt", ascending: false)) }
    private func refreshSessions() { sessions      = Array(realm.objects(GymSession.self)) }


    enum AuthError: LocalizedError {
        case invalidCredentials, banned, usernameTaken, emailTaken
        var errorDescription: String? {
            switch self {
            case .invalidCredentials: return "Invalid username or password."
            case .banned:             return "Your account has been suspended."
            case .usernameTaken:      return "Username already taken."
            case .emailTaken:         return "Email already registered."
            }
        }
    }

    func login(usernameOrEmail: String, password: String) async -> Result<GymUser, AuthError> {
        let lower = usernameOrEmail.lowercased()
        guard let user = users.first(where: {
            ($0.username.lowercased() == lower || $0.email.lowercased() == lower)
                && $0.password == password
        }) else { return .failure(.invalidCredentials) }
        if user.isBanned { return .failure(.banned) }
        setCurrentUser(user.id)
        return .success(user)
    }

    func register(username: String, email: String, password: String,
                  level: String, gym: String,
                  availability: [String], goals: [String],
                  injuries: [String], bio: String,
                  profileColor: String,
                  ageGroup: String = "Prefer not to say",
                  gender: String = "Prefer not to say",
                  preferredWorkoutTime: String = "Any") async -> Result<GymUser, AuthError> {
        if users.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            return .failure(.usernameTaken)
        }
        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            return .failure(.emailTaken)
        }
        let userId = "user_\(UUID().uuidString.prefix(8))"
        let newUser = GymUser(
            id: userId,
            username: username, email: email, password: password,
            isAdmin: false, level: level, gym: gym,
            availability: availability, goals: goals,
            injuries: injuries, bio: bio,
            profileColor: profileColor, matches: [],
            isBanned: false, warnings: 0, createdAt: Date(),
            ageGroup: ageGroup, gender: gender,
            preferredWorkoutTime: preferredWorkoutTime
        )
        try! realm.write { realm.add(newUser) }
        refreshUsers()
        setCurrentUser(newUser.id)
        return .success(newUser)
    }

    func logout() {
        currentUserId = nil
        UserDefaults.standard.removeObject(forKey: kCurrentId)
        realm = try! Realm()
        refreshAll()
    }

    func updateUser(id: String, username: String, gym: String, level: String, bio: String,
                    goals: [String], injuries: [String], availability: [String],
                    profileColor: String, ageGroup: String, gender: String,
                    preferredWorkoutTime: String) {
        try! realm.write {
            guard let user = realm.object(ofType: GymUser.self, forPrimaryKey: id) else { return }
            user.username = username; user.gym = gym; user.level = level; user.bio = bio
            user.profileColor = profileColor; user.ageGroup = ageGroup
            user.gender = gender; user.preferredWorkoutTime = preferredWorkoutTime
            user.goals.removeAll();        user.goals.append(objectsIn: goals)
            user.injuries.removeAll();     user.injuries.append(objectsIn: injuries)
            user.availability.removeAll(); user.availability.append(objectsIn: availability)
        }
        refreshUsers()
    }

    private func setCurrentUser(_ id: String) {
        currentUserId = id
        UserDefaults.standard.set(id, forKey: kCurrentId)
    }


    func matchUser(targetId: String) {
        guard let myId = currentUserId else { return }
        try! realm.write {
            if let me = realm.object(ofType: GymUser.self, forPrimaryKey: myId),
               !me.matches.contains(targetId) {
                me.matches.append(targetId)
            }
            if let target = realm.object(ofType: GymUser.self, forPrimaryKey: targetId),
               !target.matches.contains(myId) {
                target.matches.append(myId)
            }
        }
        refreshUsers()
        let targetName = users.first(where: { $0.id == targetId })?.username ?? "Someone"
        let myName = currentUser?.username ?? "Someone"
        addNotification(userId: myId,     type: "match", content: "You matched with \(targetName)! Start a conversation.")
        addNotification(userId: targetId, type: "match", content: "\(myName) matched with you!")
    }

    func unmatchUser(targetId: String) {
        guard let myId = currentUserId else { return }
        try! realm.write {
            if let me = realm.object(ofType: GymUser.self, forPrimaryKey: myId),
               let idx = me.matches.firstIndex(of: targetId) {
                me.matches.remove(at: idx)
            }
            if let target = realm.object(ofType: GymUser.self, forPrimaryKey: targetId),
               let idx = target.matches.firstIndex(of: myId) {
                target.matches.remove(at: idx)
            }
        }
        refreshUsers()
    }


    func chatId(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "_")
    }

    func getMessages(for otherUserId: String) -> [ChatMessage] {
        guard let myId = currentUserId else { return [] }
        let cid = chatId(myId, otherUserId)
        return messages.filter { $0.chatId == cid }
    }

    func sendMessage(to otherUserId: String, text: String) {
        guard let myId = currentUserId else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let msg = ChatMessage(
            id: UUID().uuidString,
            chatId: chatId(myId, otherUserId),
            senderId: myId,
            text: trimmed,
            timestamp: Date(),
            isDeleted: false
        )
        try! realm.write { realm.add(msg) }
        refreshMessages()
        let name = currentUser?.username ?? "Someone"
        addNotification(userId: otherUserId, type: "message", content: "\(name) sent you a message")
    }

    func sendImageMessage(to otherUserId: String, imageData: Data) {
        guard let myId = currentUserId else { return }
        guard let filename = saveImageData(imageData) else { return }
        let msg = ChatMessage(
            id: UUID().uuidString,
            chatId: chatId(myId, otherUserId),
            senderId: myId,
            text: "",
            timestamp: Date(),
            isDeleted: false,
            imagePath: filename
        )
        try! realm.write { realm.add(msg) }
        refreshMessages()
        let name = currentUser?.username ?? "Someone"
        addNotification(userId: otherUserId, type: "message", content: "\(name) sent you a photo")
    }

    func deleteMessage(id: String) {
        try! realm.write {
            if let msg = realm.object(ofType: ChatMessage.self, forPrimaryKey: id) {
                msg.isDeleted = true
                msg.text = "[Message deleted]"
            }
        }
        refreshMessages()
    }

    struct ChatPreview {
        let chatId: String
        let otherUser: GymUser
        let lastMessage: ChatMessage
    }

    func getChats() -> [ChatPreview] {
        guard let myId = currentUserId else { return [] }
        var latest: [String: ChatMessage] = [:]
        for msg in messages where msg.chatId.contains(myId) {
            if let prev = latest[msg.chatId] {
                if msg.timestamp > prev.timestamp { latest[msg.chatId] = msg }
            } else { latest[msg.chatId] = msg }
        }
        return latest.values.compactMap { last -> ChatPreview? in
            guard let other = users.first(where: { $0.id != myId && chatId(myId, $0.id) == last.chatId })
            else { return nil }
            return ChatPreview(chatId: last.chatId, otherUser: other, lastMessage: last)
        }.sorted { $0.lastMessage.timestamp > $1.lastMessage.timestamp }
    }

    func deleteChat(with otherUserId: String) {
        guard let myId = currentUserId else { return }
        let cid = chatId(myId, otherUserId)
        try! realm.write {
            let toDelete = realm.objects(ChatMessage.self).filter("chatId == %@", cid)
            realm.delete(toDelete)
        }
        refreshMessages()
    }


    func addNotification(userId: String, type: String, content: String) {
        let n = GymNotification(
            id: UUID().uuidString, userId: userId,
            type: type, content: content,
            isRead: false, timestamp: Date()
        )
        try! realm.write { realm.add(n) }
        refreshNotifs()
    }

    func markAllRead() {
        guard let myId = currentUserId else { return }
        try! realm.write {
            let mine = realm.objects(GymNotification.self).filter("userId == %@", myId)
            mine.forEach { $0.isRead = true }
        }
        refreshNotifs()
    }

    var unreadCount: Int {
        guard let myId = currentUserId else { return 0 }
        return notifications.filter { $0.userId == myId && !$0.isRead }.count
    }

    func myNotifications() -> [GymNotification] {
        guard let myId = currentUserId else { return [] }
        return notifications.filter { $0.userId == myId }
    }


    func saveWorkoutPlan(_ plan: WorkoutPlan) {
        guard let myId = currentUserId else { return }
        plan.userId = myId
        try! realm.write { realm.add(plan) }
        refreshWorkouts()
    }

    func deleteWorkoutPlan(id: String) {
        try! realm.write {
            if let plan = realm.object(ofType: WorkoutPlan.self, forPrimaryKey: id) {
                realm.delete(plan)
            }
        }
        refreshWorkouts()
    }

    func myWorkoutPlans() -> [WorkoutPlan] {
        guard let myId = currentUserId else { return [] }
        return workoutPlans.filter { $0.userId == myId }
    }


    func scheduleSession(with partnerId: String, dateTime: Date) {
        guard let myId = currentUserId else { return }
        let sessionId = UUID().uuidString
        let session = GymSession(
            id: sessionId,
            createdBy: myId,
            participants: [myId, partnerId],
            dateTime: dateTime,
            status: "pending",
            createdAt: Date()
        )
        let cid = chatId(myId, partnerId)
        let formatted = dateTime.formatted(.dateTime.weekday(.wide).day().month(.wide).hour().minute())
        let msg = ChatMessage(
            id: UUID().uuidString,
            chatId: cid,
            senderId: myId,
            text: "Gym session proposed for \(formatted)",
            timestamp: Date(),
            isDeleted: false,
            sessionId: sessionId
        )
        try! realm.write {
            realm.add(session)
            realm.add(msg)
        }
        refreshAll()
        let myName = currentUser?.username ?? "Someone"
        addNotification(userId: partnerId, type: "match",
                        content: "\(myName) proposed a gym session — check your chat!")
    }

    func confirmSession(id: String) {
        try! realm.write {
            if let session = realm.object(ofType: GymSession.self, forPrimaryKey: id) {
                session.status = "confirmed"
            }
        }
        refreshSessions()
        if let session = sessions.first(where: { $0.id == id }) {
            let myName = currentUser?.username ?? "Someone"
            addNotification(userId: session.createdBy, type: "match",
                            content: "\(myName) accepted your gym session!")
        }
    }

    func declineSession(id: String) {
        try! realm.write {
            if let session = realm.object(ofType: GymSession.self, forPrimaryKey: id) {
                session.status = "declined"
            }
        }
        refreshSessions()
        if let session = sessions.first(where: { $0.id == id }) {
            let myName = currentUser?.username ?? "Someone"
            addNotification(userId: session.createdBy, type: "match",
                            content: "\(myName) declined your gym session.")
        }
    }

    func rateSession(id: String, rating: Int) {
        try! realm.write {
            if let session = realm.object(ofType: GymSession.self, forPrimaryKey: id) {
                session.rating = rating
            }
        }
        refreshSessions()
    }

    func upcomingSessions() -> [GymSession] {
        guard let myId = currentUserId else { return [] }
        return sessions
            .filter { $0.participants.contains(myId)
                   && $0.dateTime >= Date()
                   && $0.status != "declined" }
            .sorted { $0.dateTime < $1.dateTime }
    }


    func matchScore(with other: GymUser) -> Int {
        guard let me = currentUser else { return 0 }
        var score = 0
        if me.gym == other.gym { score += 30 }
        let sharedDays  = Set(me.availability).intersection(Set(other.availability)).count
        score += min(sharedDays * 8, 24)
        let sharedGoals = Set(me.goals).intersection(Set(other.goals)).count
        score += min(sharedGoals * 10, 20)
        let levels = ["Beginner", "Intermediate", "Advanced"]
        let myLvl    = levels.firstIndex(of: me.level)    ?? 0
        let otherLvl = levels.firstIndex(of: other.level) ?? 0
        let diff = abs(myLvl - otherLvl)
        score += diff == 0 ? 20 : diff == 1 ? 10 : 0
        if me.preferredWorkoutTime == other.preferredWorkoutTime
            || me.preferredWorkoutTime == "Any"
            || other.preferredWorkoutTime == "Any" {
            score += 6
        }
        if me.ageGroup == other.ageGroup,
           me.ageGroup != "Prefer not to say",
           other.ageGroup != "Prefer not to say" {
            score += 10
        }
        return min(score, 98)
    }

    func suggestedPartners() -> [(user: GymUser, score: Int)] {
        guard let myId = currentUserId else { return [] }
        return users
            .filter { $0.id != myId && !$0.isAdmin && !$0.isBanned }
            .map    { ($0, matchScore(with: $0)) }
            .sorted { $0.1 > $1.1 }
    }


    var imagesDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir  = docs.appendingPathComponent("ChatImages", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func saveImageData(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = imagesDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch { return nil }
    }

    func loadImageData(filename: String) -> Data? {
        let url = imagesDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: url)
    }
}
