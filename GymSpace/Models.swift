// Models.swift

import Foundation
import RealmSwift

class GymUser: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var username: String = ""
    @Persisted var email: String = ""
    @Persisted var password: String = ""
    @Persisted var isAdmin: Bool = false
    @Persisted var level: String = ""
    @Persisted var gym: String = ""
    @Persisted var availability: List<String>
    @Persisted var goals: List<String>
    @Persisted var injuries: List<String>
    @Persisted var bio: String = ""
    @Persisted var profileColor: String = ""
    @Persisted var matches: List<String>
    @Persisted var isBanned: Bool = false
    @Persisted var warnings: Int = 0
    @Persisted var createdAt: Date = Date()
    @Persisted var ageGroup: String = "Prefer not to say"
    @Persisted var gender: String = "Prefer not to say"
    @Persisted var preferredWorkoutTime: String = "Any"

    convenience init(id: String, username: String, email: String, password: String,
                     isAdmin: Bool, level: String, gym: String,
                     availability: [String], goals: [String], injuries: [String],
                     bio: String, profileColor: String, matches: [String],
                     isBanned: Bool, warnings: Int, createdAt: Date,
                     ageGroup: String = "Prefer not to say",
                     gender: String = "Prefer not to say",
                     preferredWorkoutTime: String = "Any") {
        self.init()
        self.id = id; self.username = username; self.email = email
        self.password = password; self.isAdmin = isAdmin; self.level = level
        self.gym = gym; self.bio = bio; self.profileColor = profileColor
        self.isBanned = isBanned; self.warnings = warnings; self.createdAt = createdAt
        self.ageGroup = ageGroup; self.gender = gender
        self.preferredWorkoutTime = preferredWorkoutTime
        self.availability.append(objectsIn: availability)
        self.goals.append(objectsIn: goals)
        self.injuries.append(objectsIn: injuries)
        self.matches.append(objectsIn: matches)
    }

    var initials: String { String(username.prefix(2)).uppercased() }
}

class ChatMessage: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var chatId: String = ""
    @Persisted var senderId: String = ""
    @Persisted var text: String = ""
    @Persisted var timestamp: Date = Date()
    @Persisted var isDeleted: Bool = false
    @Persisted var sessionId: String?
    @Persisted var imagePath: String?

    convenience init(id: String, chatId: String, senderId: String, text: String,
                     timestamp: Date, isDeleted: Bool,
                     sessionId: String? = nil, imagePath: String? = nil) {
        self.init()
        self.id = id; self.chatId = chatId; self.senderId = senderId
        self.text = text; self.timestamp = timestamp; self.isDeleted = isDeleted
        self.sessionId = sessionId; self.imagePath = imagePath
    }
}

class GymNotification: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var userId: String = ""
    @Persisted var type: String = ""
    @Persisted var content: String = ""
    @Persisted var isRead: Bool = false
    @Persisted var timestamp: Date = Date()

    convenience init(id: String, userId: String, type: String, content: String,
                     isRead: Bool, timestamp: Date) {
        self.init()
        self.id = id; self.userId = userId; self.type = type
        self.content = content; self.isRead = isRead; self.timestamp = timestamp
    }
}

class WorkoutExercise: EmbeddedObject, Identifiable {
    @Persisted var id: String = ""
    @Persisted var name: String = ""
    @Persisted var sets: String = ""
    @Persisted var tip: String = ""
    @Persisted var injuryModification: String = ""
    @Persisted var youtubeQuery: String = ""

    convenience init(id: String, name: String, sets: String, tip: String,
                     injuryModification: String, youtubeQuery: String) {
        self.init()
        self.id = id; self.name = name; self.sets = sets; self.tip = tip
        self.injuryModification = injuryModification; self.youtubeQuery = youtubeQuery
    }

    var youtubeSearchURL: URL? {
        let query = "\(youtubeQuery) proper form tutorial"
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.youtube.com/results?search_query=\(encoded)")
        else { return nil }
        return url
    }
}

class WorkoutMuscleGroup: EmbeddedObject, Identifiable {
    @Persisted var id: String = ""
    @Persisted var name: String = ""
    @Persisted var exercises: List<WorkoutExercise>

    convenience init(id: String, name: String, exercises: [WorkoutExercise]) {
        self.init()
        self.id = id; self.name = name
        self.exercises.append(objectsIn: exercises)
    }
}

class WorkoutPlan: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var userId: String = ""
    @Persisted var level: String = ""
    @Persisted var goals: List<String>
    @Persisted var injuries: List<String>
    @Persisted var duration: Int = 0
    @Persisted var muscleGroups: List<WorkoutMuscleGroup>
    @Persisted var injuryAdvice: List<String>
    @Persisted var formTips: List<String>
    @Persisted var disclaimer: String = ""
    @Persisted var createdAt: Date = Date()

    convenience init(id: String, userId: String, level: String,
                     goals: [String], injuries: [String], duration: Int,
                     muscleGroups: [WorkoutMuscleGroup], injuryAdvice: [String],
                     formTips: [String], disclaimer: String, createdAt: Date) {
        self.init()
        self.id = id; self.userId = userId; self.level = level
        self.duration = duration; self.disclaimer = disclaimer; self.createdAt = createdAt
        self.goals.append(objectsIn: goals)
        self.injuries.append(objectsIn: injuries)
        self.muscleGroups.append(objectsIn: muscleGroups)
        self.injuryAdvice.append(objectsIn: injuryAdvice)
        self.formTips.append(objectsIn: formTips)
    }
}

class GymSession: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var createdBy: String = ""
    @Persisted var participants: List<String>
    @Persisted var dateTime: Date = Date()
    @Persisted var status: String = "pending"
    @Persisted var rating: Int?
    @Persisted var createdAt: Date = Date()

    convenience init(id: String, createdBy: String, participants: [String],
                     dateTime: Date, status: String, rating: Int? = nil, createdAt: Date) {
        self.init()
        self.id = id; self.createdBy = createdBy; self.dateTime = dateTime
        self.status = status; self.rating = rating; self.createdAt = createdAt
        self.participants.append(objectsIn: participants)
    }
}

struct AIMessage: Identifiable {
    let id = UUID()
    var role: AIRole
    var text: String
    var youtubeURL: URL?
    var timestamp: Date = Date()

    enum AIRole { case user, assistant }
}
