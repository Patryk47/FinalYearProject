// AICoachView.swift

import SwiftUI
import RealmSwift


private struct ExerciseInfo {
    let name: String
    let keywords: [String]
    let description: String
    let formTips: [String]
    let youtubeQuery: String
    var youtubeURL: URL? {
        let query = "\(youtubeQuery) tutorial"
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.youtube.com/results?search_query=\(encoded)")
        else { return nil }
        return url
    }
}

private let exerciseDB: [ExerciseInfo] = [
    ExerciseInfo(
        name: "Bench Press",
        keywords: ["bench press","bench","barbell bench","chest press"],
        description: "The barbell bench press is a compound upper-body exercise that primarily targets the pectorals, anterior deltoids, and triceps.",
        formTips: ["Plant feet flat on the floor","Retract and depress shoulder blades onto the bench","Grip slightly wider than shoulder-width","Lower bar to mid-chest in a controlled arc","Drive bar up and slightly back toward your face"],
        youtubeQuery: "bench press proper form tutorial"
    ),
    ExerciseInfo(
        name: "Squat",
        keywords: ["squat","back squat","barbell squat","squats"],
        description: "The barbell back squat is a fundamental lower-body compound lift that targets quads, glutes, and hamstrings.",
        formTips: ["Stand feet shoulder-width apart, toes slightly out","Brace core and take a big breath before descending","Break at hips and knees simultaneously","Keep chest up, avoid excessive forward lean","Drive through the whole foot on the way up"],
        youtubeQuery: "barbell squat perfect form tutorial"
    ),
    ExerciseInfo(
        name: "Deadlift",
        keywords: ["deadlift","dead lift","conventional deadlift"],
        description: "The conventional deadlift is a full-body hinge movement targeting the posterior chain — glutes, hamstrings, and back.",
        formTips: ["Bar over mid-foot, feet hip-width apart","Hinge at hips to grip the bar","Neutral spine from head to tailbone","Drive the floor away rather than pulling up","Lock hips forward at the top, not hyperextend"],
        youtubeQuery: "conventional deadlift form tutorial"
    ),
    ExerciseInfo(
        name: "Pull-Up",
        keywords: ["pull up","pull-up","pullup","chin up","chinup","chin-up"],
        description: "Pull-ups are a bodyweight compound exercise targeting the lats, biceps, and rear deltoids.",
        formTips: ["Start from a dead hang","Initiate by depressing shoulder blades","Pull elbows down toward hip pockets","Chin clears the bar at the top","Lower under control — the negative builds strength"],
        youtubeQuery: "pull ups proper form tutorial"
    ),
    ExerciseInfo(
        name: "Push-Up",
        keywords: ["push up","push-up","pushup","press up"],
        description: "Push-ups are a foundational bodyweight exercise for chest, triceps, and anterior deltoids.",
        formTips: ["Hands slightly wider than shoulder-width","Body forms a straight line (plank) throughout","Lower until chest nearly touches the floor","Elbows at roughly 45° from torso","Exhale forcefully on the push"],
        youtubeQuery: "push ups proper form tutorial"
    ),
    ExerciseInfo(
        name: "Overhead Press",
        keywords: ["overhead press","ohp","shoulder press","military press","standing press"],
        description: "The overhead press is a vertical pushing movement primarily targeting the deltoids and triceps.",
        formTips: ["Bar starts at collarbone level with a full grip","Elbows slightly forward of the bar","Press straight up — head moves back slightly to allow bar path","Squeeze glutes and brace core throughout","Lock elbows out at the top"],
        youtubeQuery: "overhead press proper form tutorial"
    ),
    ExerciseInfo(
        name: "Romanian Deadlift",
        keywords: ["romanian deadlift","rdl","romanian","stiff leg"],
        description: "The RDL is a hip-hinge movement that isolates the hamstrings and glutes with minimal knee flexion.",
        formTips: ["Start standing with bar at hip height","Push hips back, not down","Keep bar close to body throughout the movement","Feel a strong stretch in hamstrings at the bottom","Maintain a neutral spine — never round the lower back"],
        youtubeQuery: "romanian deadlift RDL form tutorial"
    ),
    ExerciseInfo(
        name: "Plank",
        keywords: ["plank","planks","core plank"],
        description: "The plank is an isometric core exercise that builds stability in the abs, lower back, and glutes.",
        formTips: ["Elbows directly under shoulders","Body forms a straight line — no sagging or piking hips","Squeeze glutes and brace abs as if expecting a punch","Look at the floor to keep neck neutral","Breathe in a controlled, rhythmic pattern"],
        youtubeQuery: "plank proper form tutorial"
    ),
    ExerciseInfo(
        name: "Lat Pulldown",
        keywords: ["lat pulldown","pulldown","lat pull"],
        description: "The lat pulldown is a cable machine exercise targeting the latissimus dorsi (lats) for back width.",
        formTips: ["Grip slightly wider than shoulder-width","Lean back slightly — about 10–15°","Pull elbows down and back toward your hip pockets","Avoid shrugging shoulders at the top","Controlled return to full arm extension"],
        youtubeQuery: "lat pulldown proper form tutorial"
    ),
    ExerciseInfo(
        name: "Bicep Curl",
        keywords: ["bicep curl","curl","curls","dumbbell curl","barbell curl","arm curl"],
        description: "Bicep curls isolate the biceps brachii for arm size and strength.",
        formTips: ["Keep upper arms fixed against your sides","Full range — all the way down to full extension","Squeeze at the top of the curl","Avoid swinging the body for momentum","Slow the eccentric (lowering) phase for maximum stimulus"],
        youtubeQuery: "bicep curl proper form tutorial"
    ),
    ExerciseInfo(
        name: "Tricep Pushdown",
        keywords: ["tricep pushdown","pushdown","tricep cable","cable pushdown"],
        description: "The cable tricep pushdown isolates all three heads of the triceps brachii.",
        formTips: ["Hinge slightly forward at the waist","Elbows tucked tight to your sides — do not flare","Push bar or rope straight down to full extension","Squeeze triceps at the bottom","Controlled return — do not let elbows travel behind torso"],
        youtubeQuery: "tricep pushdown cable form tutorial"
    ),
    ExerciseInfo(
        name: "Lunge",
        keywords: ["lunge","lunges","walking lunge","forward lunge"],
        description: "Lunges are a unilateral lower-body exercise targeting quads, glutes, and hamstrings.",
        formTips: ["Step forward far enough that front shin stays vertical","Keep torso upright throughout","Back knee drops toward (but does not hit) the floor","Drive through front heel to return","Step the foot you lunged with back to starting position"],
        youtubeQuery: "lunge proper form tutorial"
    ),
    ExerciseInfo(
        name: "Face Pull",
        keywords: ["face pull","face pulls","rear delt","rotator cuff"],
        description: "Face pulls are a cable exercise targeting the rear deltoids and external rotators — vital for shoulder health.",
        formTips: ["Set cable at face height or slightly above","Use a rope attachment — pull ends toward ears","Keep elbows high and wide (at least shoulder height)","Focus on squeezing rear delts and external rotating at the end","Light weight, high reps — this is a corrective exercise"],
        youtubeQuery: "face pulls rear delt shoulder health tutorial"
    ),
    ExerciseInfo(
        name: "Dumbbell Row",
        keywords: ["dumbbell row","db row","single arm row","one arm row"],
        description: "Single-arm dumbbell rows are a unilateral back exercise emphasising the lats and rhomboids.",
        formTips: ["Support opposite hand on bench; neutral spine","Row elbow straight back — not out to the side","Allow the shoulder to drop at the bottom for a full lat stretch","Pull until elbow is roughly at hip height","Avoid rotating the torso to generate momentum"],
        youtubeQuery: "dumbbell row single arm proper form"
    ),
    ExerciseInfo(
        name: "Hip Thrust",
        keywords: ["hip thrust","hip thrusts","glute bridge","barbell hip thrust"],
        description: "Hip thrusts are a glute isolation exercise with the upper back supported on a bench.",
        formTips: ["Bench edge at shoulder-blade level","Bar padded across hips — drive straight up","At the top, shins vertical, torso parallel to floor","Squeeze glutes hard at the top — don't hyperextend lower back","Lower with control — don't crash down"],
        youtubeQuery: "hip thrust glutes proper form tutorial"
    ),
]


private struct SupplementInfo {
    let name: String
    let keywords: [String]
    let description: String
    let generalDosage: String
    let timing: String
    let bestFor: [String]
    let youtubeQuery: String
    var youtubeURL: URL? {
        guard let encoded = youtubeQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return nil }
        return URL(string: "https://www.youtube.com/results?search_query=\(encoded)")
    }
}

private let supplementDB: [SupplementInfo] = [
    SupplementInfo(
        name: "Creatine Monohydrate",
        keywords: ["creatine","creatine monohydrate"],
        description: "Creatine is one of the best-studied supplements in sports science. It replenishes phosphocreatine stores in muscles, boosting strength, power output, and muscle volume over time.",
        generalDosage: "3–5 g per day (maintenance). Optional loading phase: 20 g/day split into 4 doses for 5–7 days to saturate muscles faster — skipping loading just takes ~3 weeks longer to see effects.",
        timing: "Timing matters very little. Post-workout with a meal is popular but any consistent time works.",
        bestFor: ["muscle","powerlifting","performance","strength","build confidence"],
        youtubeQuery: "creatine monohydrate benefits dosage explained"
    ),
    SupplementInfo(
        name: "Whey Protein",
        keywords: ["whey","whey protein","protein powder","protein shake","protein supplement"],
        description: "Whey is a fast-digesting dairy protein ideal for hitting daily protein targets and accelerating post-workout recovery.",
        generalDosage: "1 scoop (20–30 g protein) post-workout, or whenever needed to meet your daily goal of 1.6–2.2 g protein per kg body weight.",
        timing: "Within 1–2 hours of training is ideal, but total daily intake matters far more than timing.",
        bestFor: ["muscle","weight loss","maintain","cardio","build confidence"],
        youtubeQuery: "whey protein benefits how to use beginners guide"
    ),
    SupplementInfo(
        name: "Casein Protein",
        keywords: ["casein","casein protein","slow protein","night protein","before bed protein","overnight protein"],
        description: "Casein is a slow-digesting dairy protein that releases amino acids gradually over 5–7 hours — making it ideal before sleep to support overnight muscle repair.",
        generalDosage: "1 scoop (25–35 g) before bed.",
        timing: "30–60 minutes before sleep.",
        bestFor: ["muscle","maintain"],
        youtubeQuery: "casein protein before bed muscle recovery benefits"
    ),
    SupplementInfo(
        name: "Pre-Workout",
        keywords: ["pre workout","pre-workout","preworkout","caffeine supplement","energy before gym"],
        description: "Pre-workouts typically combine caffeine (energy/focus), beta-alanine (endurance buffer), and citrulline (blood flow) to boost training performance.",
        generalDosage: "Caffeine: 3–6 mg per kg body weight. Most pre-workouts contain 150–300 mg caffeine per serving — check the label.",
        timing: "30–45 minutes before training. Do not take within 6 hours of sleep.",
        bestFor: ["powerlifting","performance","muscle","cardio"],
        youtubeQuery: "pre workout supplement explained is it worth it"
    ),
    SupplementInfo(
        name: "BCAAs",
        keywords: ["bcaa","bcaas","branched chain","amino acid supplement","leucine","isoleucine"],
        description: "BCAAs (leucine, isoleucine, valine) are essential amino acids. If you already hit your daily protein target through food and shakes, additional BCAAs add very little benefit. They are most useful if training fasted.",
        generalDosage: "5–10 g if used — but adequate total protein (1.6–2.2 g/kg) largely makes BCAAs unnecessary.",
        timing: "During or around training.",
        bestFor: ["muscle","injury recovery"],
        youtubeQuery: "BCAAs explained are they worth it science"
    ),
    SupplementInfo(
        name: "Omega-3 Fish Oil",
        keywords: ["omega 3","omega-3","fish oil","omega","epa","dha","fish oil supplement"],
        description: "Omega-3 fatty acids reduce systemic inflammation, support joint health, and improve recovery — especially valuable when training with injuries.",
        generalDosage: "2–3 g of combined EPA+DHA per day. The total fish oil dose on the bottle will be higher — check the EPA+DHA content specifically.",
        timing: "With a meal to reduce the aftertaste and improve absorption.",
        bestFor: ["injury recovery","maintain","build confidence"],
        youtubeQuery: "omega 3 fish oil gym benefits recovery joints"
    ),
    SupplementInfo(
        name: "Vitamin D",
        keywords: ["vitamin d","vitamin d3","vit d","sunshine vitamin","vitamin d supplement"],
        description: "Vitamin D is essential for muscle function, bone density, and testosterone. Many people — especially in the UK and northern climates — are chronically deficient.",
        generalDosage: "1,000–4,000 IU per day. Ideally get blood levels checked with a GP first.",
        timing: "With a fat-containing meal for better absorption.",
        bestFor: ["injury recovery","maintain","build confidence","muscle"],
        youtubeQuery: "vitamin D deficiency gym performance muscles explained"
    ),
    SupplementInfo(
        name: "Magnesium",
        keywords: ["magnesium","mag supplement","sleep supplement","recovery mineral"],
        description: "Magnesium supports muscle relaxation, sleep quality, and energy metabolism. Athletes commonly become depleted through sweat.",
        generalDosage: "200–400 mg per day. Magnesium glycinate or citrate are best absorbed.",
        timing: "Before bed — promotes sleep quality and overnight recovery.",
        bestFor: ["injury recovery","maintain","performance","muscle"],
        youtubeQuery: "magnesium supplement benefits athletes sleep recovery"
    ),
]


private func extractWeightKg(from text: String) -> Double? {
    let lower = text.lowercased()
    let tokens = lower.components(separatedBy: .whitespacesAndNewlines)
    for (i, token) in tokens.enumerated() {
        let num = Double(token.filter { $0.isNumber || $0 == "." })
        guard let value = num, value > 20 else { continue }
        let next = i + 1 < tokens.count ? tokens[i + 1] : ""
        let combined = token + next
        if combined.contains("kg") || next.hasPrefix("kg") || next.hasPrefix("kilo") { return value }
        if combined.contains("lb") || next.hasPrefix("lb") || next.hasPrefix("pound") { return value / 2.205 }
        if token.hasSuffix("kg") { return value }
        if token.hasSuffix("lb") || token.hasSuffix("lbs") { return value / 2.205 }
    }
    let hasWeightContext = lower.contains("weigh") || lower.contains("my weight")
        || lower.contains("i am") || lower.contains("i'm") || lower.contains("im ")
    if hasWeightContext {
        for token in tokens {
            let num = Double(token.filter { $0.isNumber || $0 == "." })
            if let value = num, value >= 30, value <= 250 { return value }
        }
    }
    return nil
}


private func supplementDetailResponse(for supp: SupplementInfo, weightKg: Double?, user: GymUser?) -> AIResponse {
    var text = "**\(supp.name)**\n\n"
    text += "\(supp.description)\n\n"
    text += "**Dosage:**\n\(supp.generalDosage)\n\n"

    if let w = weightKg {
        let wStr = String(format: "%.0f", w)
        if supp.name == "Whey Protein" || supp.name == "Casein Protein" {
            let low = Int(w * 1.6); let high = Int(w * 2.2)
            text += "**For your weight (\(wStr) kg):**\n"
            text += "Total daily protein target: \(low)–\(high) g from all food + supplements\n\n"
        } else if supp.name == "Pre-Workout" {
            let low = Int(w * 3); let high = min(Int(w * 6), 400)
            text += "**For your weight (\(wStr) kg):**\n"
            text += "Caffeine target: \(low)–\(high) mg per session (capped at 400 mg — FDA safe daily limit)\n\n"
        } else if supp.name == "Creatine Monohydrate" {
            text += "**For your weight (\(wStr) kg):**\n"
            text += "Maintenance dose: 3–5 g/day (same for all body weights)\n"
            let loadTotal = Int(w * 0.3)
            text += "Loading (optional): ~\(max(20, loadTotal)) g/day for 5–7 days\n\n"
        }
    } else {
        text += "Tip: Tell me your weight (e.g. \"I weigh 80 kg\") for personalised dosages.\n\n"
    }

    text += "**Timing:**\n\(supp.timing)"
    text += supplementDisclaimer
    return AIResponse(text: text, youtubeURL: supp.youtubeURL)
}

private func supplementPlanResponse(for user: GymUser, weightKg: Double?) -> AIResponse {
    let goals = user.goals.map { $0.lowercased() }

    var scored: [(SupplementInfo, Int)] = supplementDB.map { supp in
        let score = supp.bestFor.filter { bf in
            goals.contains { g in g.contains(bf) || bf.contains(g) }
        }.count
        return (supp, score)
    }.filter { $0.1 > 0 }.sorted { $0.1 > $1.1 }

    let top = Array(scored.prefix(4).map { $0.0 })

    var text = "**Supplement Plan for Your Goals:**\n\n"
    text += "Goals: \(user.goals.joined(separator: ", "))\n\n"

    if top.isEmpty {
        text += "Based on your profile, focus on whole food nutrition first. Supplements fill gaps — they don't replace a good diet.\n\n"
        text += "A solid starting stack for any gym-goer:\n"
        text += "• Whey Protein — hit your daily protein target\n"
        text += "• Vitamin D — especially important in the UK\n"
        text += "• Omega-3 — general health and recovery\n"
    } else {
        text += "**Recommended stack:**\n\n"
        for supp in top {
            text += "**\(supp.name)**\n"
            if let w = weightKg {
                if supp.name == "Whey Protein" || supp.name == "Casein Protein" {
                    let low = Int(w * 1.6); let high = Int(w * 2.2)
                    text += "Dose: \(low)–\(high) g total protein/day (all sources)\n"
                } else if supp.name == "Pre-Workout" {
                    let low = Int(w * 3); let high = min(Int(w * 6), 400)
                    text += "Dose: \(low)–\(high) mg caffeine per session (max 400 mg)\n"
                } else {
                    text += "Dose: \(supp.generalDosage)\n"
                }
            } else {
                text += "Dose: \(supp.generalDosage)\n"
            }
            text += "Timing: \(supp.timing)\n\n"
        }
    }

    if weightKg == nil {
        text += "Tell me your weight (e.g. \"I weigh 75 kg\") for exact personalised dosages."
    } else {
        text += "These dosages are calculated for \(String(format: "%.0f", weightKg!)) kg body weight."
    }

    text += supplementDisclaimer
    return AIResponse(text: text, youtubeURL: nil)
}


private let supplementDisclaimer = "\n\n⚠️ These are general guidelines based on sports science research. Individual needs vary — consult a doctor or registered dietitian before starting any supplement. This is not medical advice."

private struct AIResponse {
    let text: String
    let youtubeURL: URL?
}

private func buildResponse(for query: String, user: GymUser?) -> AIResponse {
    let q = query.lowercased()

    if q.contains("hello") || q.contains("hi ") || q == "hi" || q.contains("hey") {
        return AIResponse(text: "Hey! I'm your GymSpace AI Coach. Ask me anything about your workout plan, how to perform any exercise, or advice for training with injuries. I can also find YouTube tutorials for you!", youtubeURL: nil)
    }

    if q.contains("what can you do") || q.contains("what do you do") || q.contains("help me") || q.contains("how can you help") {
        return AIResponse(text: """
        I can help you with:
        • **Exercise form** — "how do I do a bench press?"
        • **YouTube tutorials** — "show me a video for squats"
        • **Injury advice** — "what's safe with a shoulder injury?"
        • **Supplement recommendations** — "what supplements should I take?" or ask about creatine, whey, pre-workout, omega-3, and more
        • **Personalised dosages** — tell me your weight (e.g. "I weigh 80 kg") and I'll calculate exact amounts
        • **Nutrition & fat loss** — "how much protein do I need?"
        • **Your workout plan** — "explain my workout plan"
        """, youtubeURL: nil)
    }

    for info in exerciseDB {
        if info.keywords.contains(where: { q.contains($0) }) {
            let tipsText = info.formTips.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            let responseText = """
            **\(info.name)**

            \(info.description)

            **Form Cues:**
            \(tipsText)

            Tap the link below to watch a tutorial.
            """
            return AIResponse(text: responseText, youtubeURL: info.youtubeURL)
        }
    }

    if q.contains("shoulder") && (q.contains("injur") || q.contains("pain") || q.contains("safe") || q.contains("avoid")) {
        return AIResponse(text: """
        **Training with a Shoulder Injury:**

        **Safe to do:**
        • Seated cable rows, machine rows, lat pulldowns (narrow grip)
        • Floor press, machine chest press, low-incline dumbbell press
        • Leg training, core work, cardio on bike/elliptical
        • Face pulls, band external rotations (key rehab)

        **Avoid until cleared:**
        • Overhead pressing (OHP, Arnold press)
        • Upright rows
        • Behind-the-neck movements
        • Lateral raises above shoulder height

        Tip: Use the Generate tab — it will automatically create a shoulder-safe plan for you.
        """, youtubeURL: URL(string: "https://www.youtube.com/results?search_query=shoulder+injury+safe+exercises+gym"))
    }

    if q.contains("knee") && (q.contains("injur") || q.contains("pain") || q.contains("safe") || q.contains("avoid")) {
        return AIResponse(text: """
        **Training with a Knee Injury:**

        **Safe to do:**
        • Leg press (high foot position), seated leg curl
        • Terminal knee extensions (TKE) with a band
        • Upper body work, core training
        • Cycling (low-impact cardio)

        **Avoid until cleared:**
        • Deep squats and heavy lunges
        • Running and jumping
        • Heavy leg extensions if patella tendon is involved

        Tip: Strengthening your glutes reduces knee load significantly.
        """, youtubeURL: URL(string: "https://www.youtube.com/results?search_query=knee+injury+safe+exercises+gym"))
    }

    if q.contains("back") && (q.contains("injur") || q.contains("pain") || q.contains("lower back") || q.contains("safe")) {
        return AIResponse(text: """
        **Training with a Back Injury:**

        **Safe to do (McGill Big-3):**
        • McGill curl-up (spine-safe core flexion)
        • Bird dog (core stability)
        • Side plank (lateral stability)
        • Glute bridges (off-loads the spine)

        **Avoid until cleared:**
        • Heavy deadlifts with a rounded lower back
        • Barbell squats with high load
        • Twisting movements under load

        Keep your spine neutral in all exercises — this is the most important rule.
        """, youtubeURL: URL(string: "https://www.youtube.com/results?search_query=back+injury+safe+exercises+mcgill+big+3"))
    }

    if q.contains("video") || q.contains("youtube") || q.contains("watch") || q.contains("show me") {
        for info in exerciseDB {
            if info.keywords.contains(where: { q.contains($0) }) {
                return AIResponse(text: "Here's a YouTube tutorial for the **\(info.name)**:", youtubeURL: info.youtubeURL)
            }
        }
        let searchTerm = q.replacingOccurrences(of: "show me", with: "")
                          .replacingOccurrences(of: "video", with: "")
                          .replacingOccurrences(of: "youtube", with: "")
                          .replacingOccurrences(of: "how to", with: "")
                          .trimmingCharacters(in: .whitespacesAndNewlines)
        let encoded = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://www.youtube.com/results?search_query=\(encoded)")
        return AIResponse(text: "Here's a YouTube search for what you're looking for:", youtubeURL: url)
    }

    if q.contains("what supplement") || q.contains("which supplement") || q.contains("recommend supplement")
        || q.contains("best supplement") || q.contains("supplement for") || q.contains("supplement plan")
        || (q.contains("supplement") && (q.contains("should i") || q.contains("do i need") || q.contains("what do"))) {
        let weightKg = extractWeightKg(from: q)
        if let user = user {
            return supplementPlanResponse(for: user, weightKg: weightKg)
        }
        return AIResponse(text: """
        **Supplement Basics for Gym-Goers:**

        Here are the most evidence-backed supplements:

        **Essential:**
        • **Creatine Monohydrate** — 3–5 g/day. Best for strength and muscle gain.
        • **Whey Protein** — 1–2 scoops/day to hit protein targets (1.6–2.2 g/kg body weight).
        • **Vitamin D** — 1,000–4,000 IU/day. Most people are deficient.

        **Useful depending on goals:**
        • **Pre-workout (caffeine)** — 3–6 mg/kg body weight, 30–45 min before training.
        • **Omega-3 Fish Oil** — 2–3 g EPA+DHA/day for recovery and joint health.
        • **Magnesium** — 200–400 mg before bed for sleep and muscle recovery.

        Tell me your weight and goals for a personalised plan!\(supplementDisclaimer)
        """, youtubeURL: nil)
    }

    for supp in supplementDB {
        if supp.keywords.contains(where: { q.contains($0) }) {
            return supplementDetailResponse(for: supp, weightKg: extractWeightKg(from: q), user: user)
        }
    }

    if q.contains("protein") && !q.contains("powder") && !q.contains("shake") {
        let weightKg = extractWeightKg(from: q)
        var text = "**Daily Protein Intake:**\n\n"
        text += "For muscle building or body recomposition, aim for **1.6–2.2 g of protein per kg of body weight per day**.\n\n"
        if let w = weightKg {
            let low = Int(w * 1.6); let high = Int(w * 2.2)
            text += "**For your weight (\(String(format: "%.0f", w)) kg): \(low)–\(high) g/day**\n\n"
        } else {
            text += "Examples:\n• 60 kg → 96–132 g/day\n• 75 kg → 120–165 g/day\n• 90 kg → 144–198 g/day\n\n"
            text += "Tell me your weight for a personalised target!\n\n"
        }
        text += "**Good food sources:**\n"
        text += "• Chicken breast (~30 g per 100 g)\n"
        text += "• Eggs (~6 g per egg)\n"
        text += "• Greek yoghurt (~10 g per 100 g)\n"
        text += "• Whey protein (~25 g per scoop)\n"
        text += "• Lentils / beans (~8–9 g per 100 g cooked)\n\n"
        text += "Spread protein across 3–5 meals to maximise muscle protein synthesis."
        return AIResponse(text: text, youtubeURL: nil)
    }

    if q.contains("warm up") || q.contains("warmup") || q.contains("warm-up") {
        return AIResponse(text: """
        **How to Warm Up Properly:**

        A good warm-up should take 5–10 minutes and include:

        1. **General warm-up (3–5 min):** Light cardio — jog, cycle, or row to raise heart rate and body temperature
        2. **Dynamic stretching:** Leg swings, arm circles, hip rotations — move joints through full ROM
        3. **Activation work:** Glute bridges, band pull-aparts, or face pulls depending on what you're training
        4. **Ramp-up sets:** Start with 40–50% of your working weight for 1–2 sets before full intensity

        **Avoid static stretching before lifting** — it can temporarily reduce strength. Save it for your cool-down.
        """, youtubeURL: URL(string: "https://www.youtube.com/results?search_query=how+to+warm+up+properly+gym+tutorial"))
    }

    if q.contains("my plan") || q.contains("my workout") || q.contains("explain") {
        if let user = user {
            var planText = "**Your GymSpace Profile:**\n\n"
            planText += "• **Level:** \(user.level)\n"
            planText += "• **Goals:** \(user.goals.joined(separator: ", "))\n"
            if !user.injuries.isEmpty {
                planText += "• **Injuries:** \(user.injuries.joined(separator: ", "))\n"
            }
            planText += "\n**To generate a personalised AI workout plan**, head to the Generate tab → choose your duration → tap **Generate Workout**.\n\nThe AI will automatically modify exercises for your injuries and create a plan tailored to your goals!"
            return AIResponse(text: planText, youtubeURL: nil)
        }
    }

    if q.contains("rest") && (q.contains("set") || q.contains("between") || q.contains("how long")) {
        return AIResponse(text: """
        **How Long to Rest Between Sets:**

        | Goal | Rest Time |
        |------|-----------|
        | Strength (1–5 reps) | 3–5 minutes |
        | Hypertrophy / Muscle (6–12 reps) | 60–120 seconds |
        | Endurance / Toning (13+ reps) | 30–60 seconds |
        | HIIT / Circuits | 20–45 seconds |

        Beginner tip: If you feel out of breath or form is breaking down, rest longer — it's always better than sacrificing technique.
        """, youtubeURL: nil)
    }

    if q.contains("calorie") || q.contains("lose weight") || q.contains("fat loss") || q.contains("weight loss") {
        return AIResponse(text: """
        **Fat Loss Basics:**

        Fat loss comes down to being in a **caloric deficit** — consuming fewer calories than you burn.

        **Calculating your needs:**
        1. Find your TDEE (Total Daily Energy Expenditure) using an online calculator
        2. Subtract 300–500 calories to create a sustainable deficit
        3. Aim for **0.5–1% of body weight per week** as a safe loss rate

        **Tips:**
        • Prioritise protein (keeps you full & preserves muscle)
        • Strength training + cardio combination is most effective
        • Sleep 7–9 hours (poor sleep increases hunger hormones)
        • Track food for at least 2 weeks to understand your intake

        Crash diets backfire — slow and steady wins the race.
        """, youtubeURL: nil)
    }

    if let w = extractWeightKg(from: q) {
        let wStr = String(format: "%.0f", w)
        let proteinLow = Int(w * 1.6); let proteinHigh = Int(w * 2.2)
        let caffLow = Int(w * 3); let caffHigh = min(Int(w * 6), 400)
        var text = "**Personalised dosages for \(wStr) kg:**\n\n"
        text += "**Protein:** \(proteinLow)–\(proteinHigh) g/day total (food + shakes)\n"
        text += "**Creatine:** 3–5 g/day — dose is the same for all body weights\n"
        text += "**Pre-workout caffeine:** \(caffLow)–\(caffHigh) mg per session (max 400 mg)\n"
        text += "**Omega-3:** 2–3 g EPA+DHA/day\n\n"
        if let user = user, !user.goals.isEmpty {
            text += "Based on your goals (\(user.goals.joined(separator: ", "))), ask me what supplements should I take for a full personalised stack."
        } else {
            text += "Ask me what supplements should I take for a goal-specific recommendation!"
        }
        text += supplementDisclaimer
        return AIResponse(text: text, youtubeURL: nil)
    }

    return AIResponse(
        text: """
        I can help you with:

        • Exercise form — ask how do I do a bench press
        • Supplements — ask what supplements should I take, or about creatine, whey, pre-workout
        • Injury advice — ask what is safe with a shoulder injury
        • Personalised dosages — tell me your weight e.g. I weigh 80 kg
        • Your workout plan — ask explain my workout plan
        • Nutrition — ask how much protein or warm up tips

        What would you like to know?
        """,
        youtubeURL: nil
    )
}


struct AICoachView: View {
    @Environment(AppState.self) private var appState
    @State private var messages: [AIMessage] = []
    @State private var inputText = ""
    @State private var isTyping  = false
    @State private var showYouTubeURL: URL? = nil

    private let welcomeMessage = AIMessage(
        role: .assistant,
        text: "Hi! I'm your GymSpace AI Coach.\n\nI can help you with:\n• Exercise form & technique\n• Supplement advice & dosages (creatine, whey, pre-workout and more)\n• YouTube workout tutorials\n• Injury-safe exercise advice\n• Your personalised workout plan\n\nTell me your weight for personalised dosages — e.g. \"I weigh 80 kg\". What would you like to know?\n\n⚠️ Supplement and nutrition info is for general guidance only. Always consult a healthcare professional before starting any supplement."
    )

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(([welcomeMessage] + messages)) { msg in
                            AIChatBubble(
                                message: msg,
                                onYouTubeTap: { url in showYouTubeURL = url }
                            )
                            .id(msg.id)
                        }
                        if isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            if messages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestedQuestions, id: \.self) { q in
                            Button { sendMessage(text: q) } label: {
                                Text(q).font(.caption).fontWeight(.semibold)
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(Color(hex: "#00D47A").opacity(0.12))
                                    .foregroundStyle(Color(hex: "#00D47A"))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

            AIInputBar(text: $inputText) { sendMessage(text: inputText) }
        }
        .navigationTitle("AI Coach")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: Binding(
            get: { showYouTubeURL.map { YouTubeLink(url: $0) } },
            set: { showYouTubeURL = $0?.url }
        )) { link in
            SafariSheet(url: link.url)
        }
    }

    private var suggestedQuestions: [String] {
        var base = [
            "What supplements should I take?",
            "Tell me about creatine",
            "How much protein do I need?",
            "How do I do a bench press?",
            "How do I do a squat?",
            "How long should I rest between sets?",
        ]
        if let user = appState.currentUser {
            if !user.injuries.isEmpty {
                for inj in user.injuries {
                    base.insert("What's safe with a \(inj.lowercased()) injury?", at: 0)
                }
            }
            let goals = user.goals.map { $0.lowercased() }
            if goals.contains(where: { $0.contains("muscle") || $0.contains("powerlifting") }) {
                base.insert("Should I take creatine for muscle gain?", at: 0)
            }
            if goals.contains(where: { $0.contains("weight loss") }) {
                base.insert("Best supplements for fat loss?", at: 0)
            }
        }
        return Array(base.prefix(6))
    }

    private func sendMessage(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        messages.append(AIMessage(role: .user, text: trimmed))
        isTyping = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let response = buildResponse(for: trimmed, user: appState.currentUser)
            var reply = AIMessage(role: .assistant, text: response.text)
            reply.youtubeURL = response.youtubeURL
            messages.append(reply)
            isTyping = false
        }
    }
}


private struct AIChatBubble: View {
    let message: AIMessage
    let onYouTubeTap: (URL) -> Void

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 50) }

            if !isUser {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "#00D47A"))
                    .clipShape(Circle())
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                Text(styledText(message.text))
                    .font(.body)
                    .foregroundColor(isUser ? .white : .primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isUser ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.78, alignment: isUser ? .trailing : .leading)

                if let url = message.youtubeURL {
                    Button {
                        onYouTubeTap(url)
                    } label: {
                        Text("Link to exercise")
                            .font(.caption)
                            .underline()
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Text(message.timestamp, style: .time)
                    .font(.caption2).foregroundStyle(.secondary)
            }

            if !isUser { Spacer(minLength: 50) }
        }
    }

    private func styledText(_ raw: String) -> AttributedString {
        var result = AttributedString()
        let parts = raw.components(separatedBy: "**")
        for (i, part) in parts.enumerated() {
            var attr = AttributedString(part)
            if i % 2 == 1 { attr.font = .body.bold() }
            result += attr
        }
        return result
    }
}


private struct TypingIndicator: View {
    @State private var phase: Int = 0
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 16)).foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color(hex: "#00D47A")).clipShape(Circle())

            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle().fill(Color.secondary)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.3 : 0.8)
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: phase)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()
        }
        .onAppear {
            withAnimation { phase = 0 }
        }
    }
}


private struct AIInputBar: View {
    @Binding var text: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("Ask me anything…", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? .secondary : Color(hex: "#00D47A"))
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}
