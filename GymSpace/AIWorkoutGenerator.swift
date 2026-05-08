// AIWorkoutGenerator.swift

import Foundation


private struct ExerciseEntry {
    let name: String
    let sets: String
    let tip: String
    let youtubeQuery: String
}

private let BEGINNER: [String: [ExerciseEntry]] = [
    "chest": [
        ExerciseEntry(name: "Push-Ups",                sets: "3x8–12",  tip: "Keep core tight, elbows at 45°",              youtubeQuery: "push ups proper form beginner"),
        ExerciseEntry(name: "Knee Push-Ups",            sets: "3x10–15", tip: "Great starting point for building strength",   youtubeQuery: "knee push ups beginner"),
        ExerciseEntry(name: "Chest Press Machine",      sets: "3x10",    tip: "Use a weight you can control through full ROM", youtubeQuery: "chest press machine proper form"),
        ExerciseEntry(name: "Dumbbell Floor Press",     sets: "3x10",    tip: "Keep lower back flat on the floor",            youtubeQuery: "dumbbell floor press tutorial"),
    ],
    "back": [
        ExerciseEntry(name: "Lat Pulldown (light)",     sets: "3x10",    tip: "Pull elbows down and back, avoid shrugging",   youtubeQuery: "lat pulldown proper form"),
        ExerciseEntry(name: "Seated Cable Row",         sets: "3x10",    tip: "Sit tall, pull to lower chest",                youtubeQuery: "seated cable row form"),
        ExerciseEntry(name: "Assisted Pull-Ups",        sets: "3x8",     tip: "Use assistance to learn the movement",         youtubeQuery: "assisted pull ups machine"),
        ExerciseEntry(name: "Dumbbell Row (light)",     sets: "3x10",    tip: "Support your back, keep spine neutral",        youtubeQuery: "dumbbell row proper form"),
    ],
    "legs": [
        ExerciseEntry(name: "Bodyweight Squats",        sets: "3x15",    tip: "Feet shoulder-width, sit back into the squat", youtubeQuery: "bodyweight squat perfect form"),
        ExerciseEntry(name: "Leg Press (light)",        sets: "3x12",    tip: "Do not lock out knees at the top",             youtubeQuery: "leg press proper form"),
        ExerciseEntry(name: "Step-Ups",                 sets: "3x10",    tip: "Use a low box, drive through your heel",       youtubeQuery: "step ups exercise tutorial"),
        ExerciseEntry(name: "Lying Hamstring Curl",     sets: "3x12",    tip: "Slow and controlled throughout",              youtubeQuery: "lying hamstring curl form"),
        ExerciseEntry(name: "Standing Calf Raises",     sets: "3x15",    tip: "Full ROM, pause at top",                       youtubeQuery: "standing calf raises tutorial"),
    ],
    "shoulders": [
        ExerciseEntry(name: "Lateral Raises (light)",   sets: "3x12",    tip: "Control the weight, slight bend in elbows",    youtubeQuery: "lateral raises proper form"),
        ExerciseEntry(name: "Shoulder Press Machine",   sets: "3x10",    tip: "Core engaged, do not arch your back",          youtubeQuery: "shoulder press machine tutorial"),
        ExerciseEntry(name: "Face Pulls (light)",       sets: "3x12",    tip: "Great for shoulder health and rear delts",     youtubeQuery: "face pulls shoulder health"),
    ],
    "arms": [
        ExerciseEntry(name: "Dumbbell Bicep Curls",     sets: "3x10",    tip: "Keep elbows fixed at your sides",              youtubeQuery: "dumbbell bicep curl form"),
        ExerciseEntry(name: "Tricep Pushdowns",         sets: "3x12",    tip: "Keep elbows tucked in",                        youtubeQuery: "tricep pushdown cable form"),
        ExerciseEntry(name: "Hammer Curls",             sets: "3x10",    tip: "Neutral grip, great for forearms too",         youtubeQuery: "hammer curl proper form"),
    ],
    "core": [
        ExerciseEntry(name: "Plank",                    sets: "3x20–30s", tip: "Keep hips level, breathe steadily",           youtubeQuery: "plank proper form tutorial"),
        ExerciseEntry(name: "Dead Bug",                 sets: "3x8",      tip: "Lower back stays pressed to floor",           youtubeQuery: "dead bug exercise core"),
        ExerciseEntry(name: "Crunches",                 sets: "3x15",     tip: "Exhale as you crunch, do not pull neck",      youtubeQuery: "crunches proper form"),
        ExerciseEntry(name: "Bird Dog",                 sets: "3x8",      tip: "Move slow, maintain balance",                  youtubeQuery: "bird dog exercise tutorial"),
    ],
    "cardio": [
        ExerciseEntry(name: "Treadmill Walk/Jog",       sets: "15–20 min", tip: "Use incline for extra challenge",            youtubeQuery: "treadmill walk jog beginner"),
        ExerciseEntry(name: "Stationary Bike (easy)",   sets: "15 min",   tip: "Maintain consistent cadence",                 youtubeQuery: "stationary bike cardio workout"),
        ExerciseEntry(name: "Elliptical (easy)",        sets: "15 min",   tip: "Low impact, great for joints",                youtubeQuery: "elliptical machine workout"),
    ],
]

private let INTERMEDIATE: [String: [ExerciseEntry]] = [
    "chest": [
        ExerciseEntry(name: "Barbell Bench Press",      sets: "4x8",     tip: "Arch back slightly, feet flat",               youtubeQuery: "barbell bench press form"),
        ExerciseEntry(name: "Incline Dumbbell Press",   sets: "3x10",    tip: "30–45° incline for upper chest",               youtubeQuery: "incline dumbbell press tutorial"),
        ExerciseEntry(name: "Cable Flyes",              sets: "3x12",    tip: "Keep slight bend in elbows throughout",        youtubeQuery: "cable fly chest form"),
        ExerciseEntry(name: "Dips (chest variation)",   sets: "3x8–10",  tip: "Lean forward to target chest more",           youtubeQuery: "dips chest form tutorial"),
    ],
    "back": [
        ExerciseEntry(name: "Pull-Ups / Chin-Ups",      sets: "4x6–8",   tip: "Full dead hang to full lock-out",             youtubeQuery: "pull ups proper form"),
        ExerciseEntry(name: "Barbell Bent-Over Row",    sets: "4x8",     tip: "Hinge at hip, keep back flat",                youtubeQuery: "bent over row form"),
        ExerciseEntry(name: "Single-Arm DB Row",        sets: "3x10",    tip: "Stretch the lats at the bottom",              youtubeQuery: "single arm dumbbell row"),
        ExerciseEntry(name: "T-Bar Row",                sets: "3x10",    tip: "Great for mid-back thickness",                youtubeQuery: "t bar row form"),
    ],
    "legs": [
        ExerciseEntry(name: "Barbell Back Squat",       sets: "4x6–8",   tip: "Brace core, break at hips and knees together", youtubeQuery: "barbell back squat form"),
        ExerciseEntry(name: "Romanian Deadlift",        sets: "3x10",    tip: "Push hips back, keep back flat",              youtubeQuery: "romanian deadlift form"),
        ExerciseEntry(name: "Bulgarian Split Squat",    sets: "3x8",     tip: "Rear foot elevated, front knee tracks toe",   youtubeQuery: "bulgarian split squat tutorial"),
        ExerciseEntry(name: "Leg Press",                sets: "3x12",    tip: "Vary foot position to target different areas", youtubeQuery: "leg press form tutorial"),
    ],
    "shoulders": [
        ExerciseEntry(name: "Overhead Press (BB)",      sets: "4x6–8",   tip: "Bar path goes slightly back overhead",        youtubeQuery: "overhead press barbell form"),
        ExerciseEntry(name: "Arnold Press",             sets: "3x10",    tip: "Rotational movement, great for full delts",   youtubeQuery: "arnold press tutorial"),
        ExerciseEntry(name: "Lateral Raises",           sets: "4x12–15", tip: "Lead with elbows, slight forward lean",       youtubeQuery: "lateral raise proper form"),
        ExerciseEntry(name: "Rear Delt Fly",            sets: "3x15",    tip: "Flat back, retract shoulder blades",          youtubeQuery: "rear delt fly form"),
    ],
    "arms": [
        ExerciseEntry(name: "Barbell Curl",             sets: "3x10",    tip: "Full range, no momentum",                     youtubeQuery: "barbell curl form"),
        ExerciseEntry(name: "Skull Crushers",           sets: "3x10",    tip: "Keep elbows fixed, lower to forehead",        youtubeQuery: "skull crushers triceps form"),
        ExerciseEntry(name: "Close-Grip Bench Press",   sets: "3x8",     tip: "Elbows at 45 degrees",                        youtubeQuery: "close grip bench press"),
        ExerciseEntry(name: "Cable Curl",               sets: "3x12",    tip: "Constant tension throughout",                 youtubeQuery: "cable curl biceps form"),
    ],
    "core": [
        ExerciseEntry(name: "Hanging Knee Raises",      sets: "3x12",    tip: "Control the swing, curl the pelvis",          youtubeQuery: "hanging knee raises tutorial"),
        ExerciseEntry(name: "Cable Crunches",           sets: "3x15",    tip: "Round the spine, do not hip flex",            youtubeQuery: "cable crunch form"),
        ExerciseEntry(name: "Russian Twists",           sets: "3x20",    tip: "Keep feet off floor for extra challenge",     youtubeQuery: "russian twists core exercise"),
        ExerciseEntry(name: "Ab Wheel Rollout",         sets: "3x8",     tip: "Keep core braced throughout",                 youtubeQuery: "ab wheel rollout tutorial"),
    ],
    "cardio": [
        ExerciseEntry(name: "Interval Treadmill Run",   sets: "20 min HIIT", tip: "1 min sprint, 2 min jog",               youtubeQuery: "treadmill interval running HIIT"),
        ExerciseEntry(name: "Row Machine",              sets: "15–20 min",   tip: "Great full-body conditioning",            youtubeQuery: "rowing machine technique"),
        ExerciseEntry(name: "Stair Climber",            sets: "15 min",      tip: "Maintain upright posture",               youtubeQuery: "stair climber workout"),
    ],
]

private let ADVANCED: [String: [ExerciseEntry]] = [
    "chest": [
        ExerciseEntry(name: "Weighted Dips",            sets: "4x8",     tip: "Add weight via belt, full ROM",               youtubeQuery: "weighted dips chest tutorial"),
        ExerciseEntry(name: "Barbell Bench Press",      sets: "5x5",     tip: "Competition grip, leg drive",                 youtubeQuery: "bench press 5x5 advanced"),
        ExerciseEntry(name: "Incline Barbell Press",    sets: "4x6",     tip: "Keep scapula retracted and depressed",        youtubeQuery: "incline barbell press advanced"),
        ExerciseEntry(name: "Cable Crossovers",         sets: "4x15",    tip: "Squeeze and hold at contraction point",       youtubeQuery: "cable crossover chest exercise"),
    ],
    "back": [
        ExerciseEntry(name: "Weighted Pull-Ups",        sets: "5x6",     tip: "Full range, control the negative",            youtubeQuery: "weighted pull ups tutorial"),
        ExerciseEntry(name: "Barbell Row (heavy)",      sets: "5x5",     tip: "Touch bar to lower chest",                    youtubeQuery: "heavy barbell row advanced"),
        ExerciseEntry(name: "Rack Pulls",               sets: "4x5",     tip: "From knee height for upper back",             youtubeQuery: "rack pulls exercise form"),
        ExerciseEntry(name: "Chest-Supported Row",      sets: "4x10",    tip: "Eliminates momentum, strict form",            youtubeQuery: "chest supported row tutorial"),
    ],
    "legs": [
        ExerciseEntry(name: "Barbell Back Squat (heavy)", sets: "5x5",   tip: "Belt usage appropriate at working weights",   youtubeQuery: "heavy squat powerlifting form"),
        ExerciseEntry(name: "Romanian Deadlift (heavy)", sets: "4x6",    tip: "Full hip hinge, feel hamstring stretch",      youtubeQuery: "heavy RDL deadlift form"),
        ExerciseEntry(name: "Hack Squat",               sets: "4x10",    tip: "Deep range, great quad development",          youtubeQuery: "hack squat machine tutorial"),
        ExerciseEntry(name: "Nordic Hamstring Curl",    sets: "3x6",     tip: "Very demanding, control the eccentric",       youtubeQuery: "nordic hamstring curl tutorial"),
    ],
    "shoulders": [
        ExerciseEntry(name: "Push Press",               sets: "4x5",     tip: "Use leg drive to overload the press",         youtubeQuery: "push press tutorial"),
        ExerciseEntry(name: "Seated DB Shoulder Press", sets: "4x8",     tip: "Stricter than standing, isolates delts",      youtubeQuery: "seated dumbbell shoulder press"),
        ExerciseEntry(name: "Cable Lateral Raise",      sets: "4x15",    tip: "Constant tension, supinate slightly",         youtubeQuery: "cable lateral raise form"),
        ExerciseEntry(name: "Reverse Pec Deck",         sets: "4x15",    tip: "Targets rear delts heavily",                  youtubeQuery: "reverse pec deck rear delt"),
    ],
    "arms": [
        ExerciseEntry(name: "Barbell Curl (heavy)",     sets: "4x8",     tip: "Add partial reps at end of each set",         youtubeQuery: "heavy barbell curl advanced"),
        ExerciseEntry(name: "EZ-Bar Skull Crusher",     sets: "4x10",    tip: "Slight back angle for extra stretch",         youtubeQuery: "ez bar skull crusher form"),
        ExerciseEntry(name: "Tricep Dips (weighted)",   sets: "4x8",     tip: "Upright torso for pure tricep focus",         youtubeQuery: "weighted tricep dips tutorial"),
        ExerciseEntry(name: "Preacher Curl",            sets: "3x10",    tip: "Isolates the bicep peak",                     youtubeQuery: "preacher curl form tutorial"),
    ],
    "core": [
        ExerciseEntry(name: "Hanging Leg Raise",        sets: "4x12",    tip: "Fully extend legs, curl pelvis at top",       youtubeQuery: "hanging leg raise tutorial"),
        ExerciseEntry(name: "Dragon Flag",              sets: "3x5",     tip: "Very advanced, keep body rigid",              youtubeQuery: "dragon flag exercise tutorial"),
        ExerciseEntry(name: "Pallof Press",             sets: "3x12",    tip: "Anti-rotation core stability",                youtubeQuery: "pallof press core stability"),
    ],
    "cardio": [
        ExerciseEntry(name: "Battle Ropes",             sets: "5x30s", tip: "Max intensity during work periods",             youtubeQuery: "battle ropes workout technique"),
        ExerciseEntry(name: "Sprint Intervals",         sets: "10x100m", tip: "Near max effort, full recovery between",      youtubeQuery: "sprint interval training"),
        ExerciseEntry(name: "Sled Push/Pull",           sets: "6x20m",  tip: "Explosive power conditioning",                youtubeQuery: "sled push pull conditioning"),
    ],
]


private let SHOULDER_SAFE_CHEST: [ExerciseEntry] = [
    ExerciseEntry(name: "Low Incline DB Press (15–20°)", sets: "3x10", tip: "Low incline is safer for shoulder joint",    youtubeQuery: "low incline dumbbell press shoulder safe"),
    ExerciseEntry(name: "Floor Press",                    sets: "3x10", tip: "Limits ROM, reduces shoulder stress",       youtubeQuery: "floor press shoulder friendly"),
    ExerciseEntry(name: "Machine Chest Press",            sets: "3x12", tip: "Guided path reduces shoulder demand",       youtubeQuery: "chest press machine shoulder safe"),
    ExerciseEntry(name: "Cable Fly (low angle)",          sets: "3x12", tip: "Keep arms at shoulder height or below",     youtubeQuery: "cable fly low shoulder safe"),
]

private let SHOULDER_SAFE_BACK: [ExerciseEntry] = [
    ExerciseEntry(name: "Seated Cable Row",       sets: "3x12", tip: "Keep elbows close to body",                        youtubeQuery: "seated cable row shoulder safe"),
    ExerciseEntry(name: "Machine Row",            sets: "3x12", tip: "Controlled, safe movement pattern",               youtubeQuery: "machine row form tutorial"),
    ExerciseEntry(name: "Lat Pulldown (narrow)",  sets: "3x12", tip: "Narrow grip reduces shoulder rotation demand",     youtubeQuery: "lat pulldown narrow grip shoulder safe"),
    ExerciseEntry(name: "Straight-Arm Pulldown",  sets: "3x12", tip: "Minimal shoulder joint involvement",              youtubeQuery: "straight arm pulldown tutorial"),
]

private let SHOULDER_REHAB: [ExerciseEntry] = [
    ExerciseEntry(name: "Face Pulls (light)",         sets: "3x15", tip: "External rotation for shoulder health and rehab", youtubeQuery: "face pulls shoulder rehab"),
    ExerciseEntry(name: "Band External Rotation",     sets: "3x15", tip: "Key rehab exercise, go very light",              youtubeQuery: "band external rotation shoulder"),
    ExerciseEntry(name: "Wall Slides",                sets: "2x10", tip: "Shoulder mobility and stability work",           youtubeQuery: "wall slides shoulder mobility"),
    ExerciseEntry(name: "Prone Y-T-W",                sets: "2x10", tip: "Activates lower and mid trapezius",             youtubeQuery: "Y T W exercise shoulder rehab"),
    ExerciseEntry(name: "Side-Lying External Rotation", sets: "3x15", tip: "Infraspinatus/teres minor strengthening",     youtubeQuery: "side lying external rotation rotator cuff"),
]

private let KNEE_SAFE_LEGS: [ExerciseEntry] = [
    ExerciseEntry(name: "Leg Press (foot high)",     sets: "3x12", tip: "High foot placement reduces knee stress",         youtubeQuery: "leg press high foot knee safe"),
    ExerciseEntry(name: "Seated Leg Curl",           sets: "3x12", tip: "Isolates hamstrings with no knee impact",        youtubeQuery: "seated leg curl form"),
    ExerciseEntry(name: "Standing Calf Raises",      sets: "3x15", tip: "Low impact, important for knee stability",        youtubeQuery: "standing calf raises tutorial"),
    ExerciseEntry(name: "Terminal Knee Extension",   sets: "3x15", tip: "Resistance band — VMO activation for knee",       youtubeQuery: "terminal knee extension rehab"),
    ExerciseEntry(name: "Step-Ups (low box)",        sets: "3x10", tip: "Low step height to minimise knee flexion",       youtubeQuery: "low step ups knee pain friendly"),
]

private let BACK_SAFE_EXERCISES: [ExerciseEntry] = [
    ExerciseEntry(name: "McGill Curl-Up",            sets: "3x8",  tip: "Lower back pain-friendly core exercise",         youtubeQuery: "mcgill curl up lower back rehab"),
    ExerciseEntry(name: "Bird Dog",                  sets: "3x8",  tip: "Core stability, keep spine neutral",              youtubeQuery: "bird dog exercise back pain"),
    ExerciseEntry(name: "Glute Bridge",              sets: "3x15", tip: "Activates glutes without loading the spine",     youtubeQuery: "glute bridge exercise tutorial"),
    ExerciseEntry(name: "Dead Bug",                  sets: "3x8",  tip: "Press lower back to floor throughout",           youtubeQuery: "dead bug exercise back pain"),
    ExerciseEntry(name: "Wall Sit",                  sets: "3x30s", tip: "Legs only, keeps spine off-load",               youtubeQuery: "wall sit exercise tutorial"),
]


private let injuryAdvice: [String: [String]] = [
    "Shoulder": [
        "Avoid all overhead pressing (OHP, upright rows, behind-the-neck press).",
        "Skip lateral raises above shoulder height.",
        "Use chest-safe alternatives — floor press, machine press at neutral angles.",
        "Prioritise shoulder rehab: face pulls, band external rotations, Y-T-W.",
        "Consult a physiotherapist before returning to heavy pressing.",
        "Warm up with 5–10 min rotator-cuff activation before any upper-body work.",
    ],
    "Knee": [
        "Avoid deep squats and lunges until cleared by a healthcare professional.",
        "Use the leg press with a higher foot plate to reduce knee shear.",
        "Perform terminal knee extensions and VMO exercises to rebuild stability.",
        "Avoid high-impact cardio (running, jumping) — switch to cycling or swimming.",
        "Apply RICE (Rest, Ice, Compression, Elevation) after sessions if swelling occurs.",
        "Strengthening glutes reduces knee load — include glute bridges.",
    ],
    "Back": [
        "Avoid heavy spinal loading: deadlifts, barbell squats, good mornings.",
        "Use McGill Big-3: curl-up, bird dog, side plank for spine-safe core work.",
        "Maintain neutral spine during ALL exercises — no rounded lower back.",
        "Switch to goblet squats or leg press to keep load off the spine.",
        "Avoid seated twisting machines and cable crunches with spinal flexion.",
        "Consult a physio — many back injuries respond well to targeted rehab.",
    ],
    "Hip": [
        "Avoid deep hip flexion under load (deep squats, leg press to extreme depth).",
        "Strengthen glutes and hip abductors to stabilise the joint.",
        "Include hip mobility work: 90/90 stretches, pigeon pose.",
        "Avoid activities that cause clicking or impingement pain.",
        "Single-leg work (step-ups) may be tolerated better than bilateral movements.",
    ],
    "Elbow": [
        "Avoid heavy barbell curls and tricep exercises that aggravate the joint.",
        "Use neutral grip (hammer curls, neutral-grip pushdowns) to reduce strain.",
        "Focus on pain-free range — reduce load significantly and rebuild slowly.",
        "Eccentric training can help tendinopathies — consult a physio for protocols.",
        "Check equipment: straight bars put more stress on elbows than EZ-bars or dumbbells.",
    ],
    "Ankle": [
        "Avoid loaded jumping, box jumps, and sprinting until cleared.",
        "Strengthen ankle stability with single-leg balance and resistance-band work.",
        "Upper-body and core exercises can be performed pain-free to maintain fitness.",
        "Seated and machine-based leg exercises reduce ankle demand.",
        "Cycling is low-impact and maintains leg fitness during ankle recovery.",
    ],
]


enum AIWorkoutGenerator {

    static func generate(
        level: String,
        goals: [String],
        injuries: [String],
        duration: Int,
        selectedGroups: [String] = [],
        availableDays: [String]  = []
    ) -> WorkoutPlan {
        let lvl = level.lowercased()
        let db: [String: [ExerciseEntry]]
        switch lvl {
        case "intermediate": db = INTERMEDIATE
        case "advanced":     db = ADVANCED
        default:             db = BEGINNER
        }

        let hasShoulderInjury = injuries.map { $0.lowercased() }.contains("shoulder")
        let hasKneeInjury     = injuries.map { $0.lowercased() }.contains("knee")
        let hasBackInjury     = injuries.map { $0.lowercased() }.contains("back")

        let exercisesPerGroup = duration <= 30 ? 2 : duration <= 45 ? 3 : 4

        let selected: [String]
        if !selectedGroups.isEmpty {
            selected = selectedGroups
        } else {
            let groupCount = duration <= 30 ? 2 : duration <= 45 ? 3 : 4
            let goalSet = Set(goals)
            let targetGroups: [String]
            if goalSet.contains("Weight Loss") || goalSet.contains("Cardio Fitness") {
                targetGroups = ["legs","cardio","core"]
            } else if goalSet.contains("Muscle Gain") || goalSet.contains("Powerlifting") {
                targetGroups = ["chest","back","legs","shoulders"]
            } else if goalSet.contains("Performance") {
                targetGroups = ["legs","back","core","cardio"]
            } else if goalSet.contains("Injury Recovery") || goalSet.contains("Maintain Fitness") {
                targetGroups = ["core","legs","back"]
            } else {
                targetGroups = ["chest","back","legs","core"]
            }
            selected = Array(targetGroups.prefix(groupCount))
        }

        let days = availableDays.isEmpty ? [] : availableDays
        func dayLabel(for index: Int) -> String {
            guard !days.isEmpty else { return "" }
            return days[index % days.count]
        }

        let muscleGroups: [WorkoutMuscleGroup] = selected.enumerated().map { idx, group in
            var pool: [ExerciseEntry]

            if group == "shoulders" && hasShoulderInjury {
                pool = SHOULDER_REHAB
            } else if group == "chest" && hasShoulderInjury {
                pool = SHOULDER_SAFE_CHEST
            } else if group == "back" && hasShoulderInjury {
                pool = SHOULDER_SAFE_BACK
            } else if group == "legs" && hasKneeInjury {
                pool = KNEE_SAFE_LEGS
            } else if (group == "core" || group == "back") && hasBackInjury {
                pool = BACK_SAFE_EXERCISES
            } else {
                pool = db[group] ?? []
            }

            let exercises = Array(pool.shuffled().prefix(exercisesPerGroup))
            let day = dayLabel(for: idx)
            let groupTitle = day.isEmpty ? formatGroupName(group) : "\(day) · \(formatGroupName(group))"

            return WorkoutMuscleGroup(
                id: UUID().uuidString,
                name: groupTitle,
                exercises: exercises.map { e in
                    let mod = injuryModification(exercise: e.name, injuries: injuries)
                    return WorkoutExercise(
                        id: UUID().uuidString,
                        name: e.name,
                        sets: e.sets,
                        tip: e.tip,
                        injuryModification: mod,
                        youtubeQuery: e.youtubeQuery
                    )
                }
            )
        }

        var advice: [String] = []
        for inj in injuries {
            if let tips = injuryAdvice[inj] { advice.append(contentsOf: tips) }
        }

        let formTips: [String] = lvl == "beginner" ? [
            "Always warm up with 5–10 min light cardio before lifting.",
            "Focus on form over weight — you can increase load next session.",
            "Rest 60–90 seconds between sets when starting out.",
            "Breathe OUT on the effort (the hard part) of each rep.",
            "If you feel sharp pain, stop — soreness is normal, pain is not.",
            "Stay hydrated throughout your session.",
            "Don't train the same muscle group two days in a row — rest is when you grow.",
        ] : []

        var disclaimer: String
        if !injuries.isEmpty {
            disclaimer = "⚠️ MEDICAL DISCLAIMER: This workout has been modified for your injury constraints (\(injuries.joined(separator: ", "))). Always consult a qualified healthcare professional before exercising with an injury. Stop any exercise that causes pain. This plan is for general guidance only."
        } else {
            disclaimer = "This workout plan is for general fitness guidance. Always warm up for 5–10 minutes before training. Consult a fitness professional if you are new to exercise."
        }

        return WorkoutPlan(
            id: UUID().uuidString,
            userId: "",
            level: level,
            goals: goals,
            injuries: injuries,
            duration: duration,
            muscleGroups: muscleGroups,
            injuryAdvice: advice,
            formTips: formTips,
            disclaimer: disclaimer,
            createdAt: Date()
        )
    }


    private static func formatGroupName(_ key: String) -> String {
        switch key {
        case "chest":     return "Chest"
        case "back":      return "Back"
        case "legs":      return "Legs & Glutes"
        case "shoulders": return "Shoulders"
        case "arms":      return "Arms"
        case "core":      return "Core & Abs"
        case "cardio":    return "Cardio"
        default:          return key.capitalized
        }
    }

    private static func injuryModification(exercise: String, injuries: [String]) -> String {
        let lowEx = exercise.lowercased()
        for inj in injuries {
            switch inj.lowercased() {
            case "shoulder":
                if lowEx.contains("press") || lowEx.contains("raise") || lowEx.contains("row") {
                    return "Use lighter weight, reduce range of motion, stop at any pain."
                }
            case "knee":
                if lowEx.contains("squat") || lowEx.contains("lunge") || lowEx.contains("step") {
                    return "Use a shallower range, reduce load, or substitute with leg press."
                }
            case "back":
                if lowEx.contains("deadlift") || lowEx.contains("row") || lowEx.contains("squat") {
                    return "Maintain strict neutral spine; reduce load significantly."
                }
            case "elbow":
                if lowEx.contains("curl") || lowEx.contains("extension") || lowEx.contains("dip") {
                    return "Switch to neutral grip; reduce weight and focus on pain-free range."
                }
            case "hip":
                if lowEx.contains("squat") || lowEx.contains("lunge") || lowEx.contains("hip") {
                    return "Reduce depth of movement; avoid any impingement."
                }
            case "ankle":
                if lowEx.contains("calf") || lowEx.contains("squat") || lowEx.contains("lunge") {
                    return "Minimise ankle dorsiflexion; consider seated alternatives."
                }
            default: break
            }
        }
        return ""
    }
}
