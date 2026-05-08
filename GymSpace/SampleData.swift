// SampleData.swift

import Foundation

enum SeedData {

    static func makeUsers() -> [GymUser] {
        [
            GymUser(id: "admin_001",
                    username: "Patrykadmin", email: "admin@gymspace.com", password: "admin123",
                    isAdmin: true, level: "Advanced", gym: "GymSpace HQ",
                    availability: ["Mon","Wed","Fri"], goals: ["Maintenance"],
                    injuries: [], bio: "GymSpace Administrator",
                    profileColor: "#10b981", matches: [], isBanned: false, warnings: 0,
                    createdAt: ISO8601DateFormatter().date(from: "2026-01-01T00:00:00Z") ?? Date(),
                    ageGroup: "25-34", gender: "Male", preferredWorkoutTime: "Morning"),

            GymUser(id: "user_001",
                    username: "MaxNewbie", email: "max@example.com", password: "demo123",
                    isAdmin: false, level: "Beginner", gym: "Fitness First London",
                    availability: ["Mon","Wed","Sat"],
                    goals: ["Build Confidence","Weight Loss"],
                    injuries: [],
                    bio: "Just started gym! Looking for a beginner buddy. I have social anxiety so prefer to connect online first.",
                    profileColor: "#f59e0b", matches: ["user_002"], isBanned: false, warnings: 0,
                    createdAt: ISO8601DateFormatter().date(from: "2026-04-08T09:00:00Z") ?? Date(),
                    ageGroup: "18-24", gender: "Male", preferredWorkoutTime: "Morning"),

            GymUser(id: "user_002",
                    username: "EmmaFit", email: "emma@example.com", password: "demo123",
                    isAdmin: false, level: "Beginner", gym: "Fitness First London",
                    availability: ["Mon","Thu","Sat"],
                    goals: ["Build Confidence","Cardio Fitness"],
                    injuries: [],
                    bio: "Beginner here! Love cardio and starting weights. Would love a gym buddy for motivation!",
                    profileColor: "#ec4899", matches: ["user_001"], isBanned: false, warnings: 0,
                    createdAt: ISO8601DateFormatter().date(from: "2026-04-09T11:00:00Z") ?? Date(),
                    ageGroup: "18-24", gender: "Female", preferredWorkoutTime: "Morning"),

            GymUser(id: "user_003",
                    username: "MiaElite", email: "mia@example.com", password: "demo123",
                    isAdmin: false, level: "Advanced", gym: "PureGym Canary Wharf",
                    availability: ["Tue","Thu","Sat"],
                    goals: ["Performance","Muscle Gain"],
                    injuries: [],
                    bio: "Advanced lifter, 6 years training. Busy schedule – need reliable partners. Prefer 30-45 min sessions.",
                    profileColor: "#8b5cf6", matches: [], isBanned: false, warnings: 0,
                    createdAt: ISO8601DateFormatter().date(from: "2026-04-07T14:00:00Z") ?? Date(),
                    ageGroup: "25-34", gender: "Female", preferredWorkoutTime: "Afternoon"),

            GymUser(id: "user_004",
                    username: "MikeRecovery", email: "mike@example.com", password: "demo123",
                    isAdmin: false, level: "Intermediate", gym: "Anytime Fitness Manchester",
                    availability: ["Mon","Wed","Fri"],
                    goals: ["Injury Recovery","Maintain Fitness"],
                    injuries: ["Shoulder"],
                    bio: "Returning after shoulder injury. Need safe workout plans and understanding training partners.",
                    profileColor: "#3b82f6", matches: [], isBanned: false, warnings: 0,
                    createdAt: ISO8601DateFormatter().date(from: "2026-04-06T08:30:00Z") ?? Date(),
                    ageGroup: "35-44", gender: "Male", preferredWorkoutTime: "Evening"),

            GymUser(id: "user_005",
                    username: "JakeStrong", email: "jake@example.com", password: "demo123",
                    isAdmin: false, level: "Advanced", gym: "PureGym Canary Wharf",
                    availability: ["Tue","Thu","Sat","Sun"],
                    goals: ["Powerlifting","Muscle Gain"],
                    injuries: [],
                    bio: "5 years lifting. Compete in powerlifting. Looking for serious training partners.",
                    profileColor: "#ef4444", matches: [], isBanned: false, warnings: 0,
                    createdAt: ISO8601DateFormatter().date(from: "2026-04-05T17:00:00Z") ?? Date(),
                    ageGroup: "25-34", gender: "Male", preferredWorkoutTime: "Afternoon"),
        ]
    }

    static func makeMessages() -> [ChatMessage] {
        let fmt = ISO8601DateFormatter()
        return [
            ChatMessage(id: "msg_001", chatId: "user_001_user_002", senderId: "user_001",
                        text: "Hey Emma! I saw we matched. Are you also a beginner at Fitness First?",
                        timestamp: fmt.date(from: "2026-04-10T10:30:00Z") ?? Date(), isDeleted: false),
            ChatMessage(id: "msg_002", chatId: "user_001_user_002", senderId: "user_002",
                        text: "Hi Max! Yes I am! I usually go Monday and Saturday mornings. When do you go?",
                        timestamp: fmt.date(from: "2026-04-10T10:32:00Z") ?? Date(), isDeleted: false),
            ChatMessage(id: "msg_003", chatId: "user_001_user_002", senderId: "user_001",
                        text: "Same! Monday mornings work for me. Maybe we could do a session together sometime?",
                        timestamp: fmt.date(from: "2026-04-10T10:35:00Z") ?? Date(), isDeleted: false),
            ChatMessage(id: "msg_004", chatId: "user_001_user_002", senderId: "user_002",
                        text: "That would be great! Looking forward to it",
                        timestamp: fmt.date(from: "2026-04-10T10:36:00Z") ?? Date(), isDeleted: false),
        ]
    }

    static func makeNotifications() -> [GymNotification] {
        let fmt = ISO8601DateFormatter()
        return [
            GymNotification(id: "notif_001", userId: "user_001", type: "match",
                            content: "You matched with EmmaFit! Start a conversation.",
                            isRead: false,
                            timestamp: fmt.date(from: "2026-04-10T10:29:00Z") ?? Date()),
            GymNotification(id: "notif_002", userId: "user_001", type: "message",
                            content: "EmmaFit sent you a message",
                            isRead: true,
                            timestamp: fmt.date(from: "2026-04-10T10:32:00Z") ?? Date()),
        ]
    }
}
