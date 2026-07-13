import Foundation

enum FocusArea: String, CaseIterable, Codable, Identifiable {
    case anxiety
    case depression
    case addiction
    case relationships
    case growth
    case health

    var id: String { rawValue }

    var title: String {
        switch self {
        case .anxiety: "Anxiety"
        case .depression: "Depression"
        case .addiction: "Addiction"
        case .relationships: "Relationships"
        case .growth: "Become better"
        case .health: "Health"
        }
    }

    var symbol: String {
        switch self {
        case .anxiety: "wind"
        case .depression: "sun.max"
        case .addiction: "shield.lefthalf.filled"
        case .relationships: "heart"
        case .growth: "arrow.up.right"
        case .health: "leaf"
        }
    }

    var routeTitle: String {
        switch self {
        case .anxiety: "Steady the body before solving the thought"
        case .depression: "Make one gentle movement toward the day"
        case .addiction: "Create distance from the urge"
        case .relationships: "Respond from clarity, not heat"
        case .growth: "Practice the person you are becoming"
        case .health: "Support energy with food, sleep, and movement"
        }
    }

    var tasks: [String] {
        switch self {
        case .anxiety: ["Practice five unforced, slower exhales", "Test one safe prediction instead of avoiding it", "Reduce one source of unnecessary stimulation", "Write the thought and the evidence it leaves out"]
        case .depression: ["Make contact with daylight", "Eat one adequate meal or snack", "Complete five minutes of meaningful activity", "Let one safe person know how today feels"]
        case .addiction: ["Create distance from the strongest cue", "Delay the urge and watch its intensity change", "Contact recovery support before isolation grows", "Protect sleep, food, and medication routines"]
        case .relationships: ["Pause until your body can listen again", "Name the need beneath the conflict", "Use one clear boundary without punishment", "Ask what repair would look like in behavior"]
        case .growth: ["Study one lesson deeply enough to use it", "Keep one promise small enough to repeat", "Remove friction from tomorrow's first good choice", "Reflect without turning the day into a grade"]
        case .health: ["Include a fiber-rich plant food", "Include a protein food you tolerate", "Move in a way that is not punishment", "Protect a realistic sleep window"]
        }
    }
}

enum CompanionChoice: String, CaseIterable, Codable, Identifiable {
    case capy
    case oreo
    case axel
    case jagy

    var id: String { rawValue }
    var name: String {
        switch self {
        case .capy: "Capy"
        case .oreo: "Oreo"
        case .axel: "Axel"
        case .jagy: "Jags"
        }
    }
    var species: String {
        switch self {
        case .capy: "the Capybara"
        case .oreo: "the Dog"
        case .axel: "the Axolotl"
        case .jagy: "the Jaguar"
        }
    }
    var avatarAssetName: String {
        switch self {
        case .capy: "CompanionCapy"
        case .oreo: "CompanionOreo"
        case .axel: "CompanionAxel"
        case .jagy: "CompanionJagy"
        }
    }
    var symbol: String {
        switch self {
        case .capy: "🐹"
        case .oreo: "🐕"
        case .axel: "🫧"
        case .jagy: "🐆"
        }
    }
    var promise: String {
        switch self {
        case .capy: "Patient company when the nervous system needs room"
        case .oreo: "Warm, direct support when isolation starts closing in"
        case .axel: "Curious guidance for learning, reflection, and beginning again"
        case .jagy: "Grounded courage when a boundary or hard choice is waiting"
        }
    }
    var greeting: String {
        switch self {
        case .capy: "We can make this moment smaller without making your life smaller."
        case .oreo: "You do not need a polished explanation. Start with the truest sentence."
        case .axel: "Let us look closely, stay kind, and find the next useful experiment."
        case .jagy: "Courage does not need to be loud. Tell me what the next honest choice is asking of you."
        }
    }
}

enum DailyFeeling: String, CaseIterable, Codable, Identifiable {
    case anxious
    case low
    case overwhelmed
    case craving
    case disconnected
    case steady
    case hopeful

    var id: String { rawValue }
    var title: String {
        switch self {
        case .anxious: "Anxious"
        case .low: "Low"
        case .overwhelmed: "Overwhelmed"
        case .craving: "Pulled by an urge"
        case .disconnected: "Disconnected"
        case .steady: "Steady"
        case .hopeful: "Hopeful"
        }
    }
    var symbol: String {
        switch self {
        case .anxious: "waveform.path"
        case .low: "minus"
        case .overwhelmed: "square.stack.3d.up"
        case .craving: "arrow.right"
        case .disconnected: "circle.dashed"
        case .steady: "equal"
        case .hopeful: "arrow.up"
        }
    }
    var ritualTitle: String {
        switch self {
        case .anxious: "Return to the room you are already in"
        case .low: "Make one point of contact with the day"
        case .overwhelmed: "Put the whole day down and pick up one hour"
        case .craving: "Protect the space between urge and action"
        case .disconnected: "Come back into relationship with the day"
        case .steady: "Use steadiness while it is here"
        case .hopeful: "Give hope something practical to hold"
        }
    }
    var firstAction: String {
        switch self {
        case .anxious: "Name the feared prediction, then name what is actually happening in the room."
        case .low: "Open the curtains, wash your face, or step outside before asking motivation for permission."
        case .overwhelmed: "Write every demand down, circle one that matters today, and let the page hold the rest."
        case .craving: "Move away from immediate access, delay ten minutes, and contact support before bargaining with the urge."
        case .disconnected: "Send one low-pressure message that contains something true."
        case .steady: "Prepare one support you will be grateful for on a harder day."
        case .hopeful: "Choose one concrete action that gives the hopeful thought evidence."
        }
    }
}

enum WorkoutArea: String, CaseIterable, Codable, Identifiable {
    case cardio = "Cardio"
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case core = "Core"
    case legs = "Legs"
    case mobility = "Mobility"
    var id: String { rawValue }
}

enum ThemeMode: String, CaseIterable, Codable, Identifiable {
    case minimal
    case spiritual

    var id: String { rawValue }
    var title: String { self == .minimal ? "Minimal" : "Spiritual night" }
}

struct AccountProfile: Codable, Equatable {
    var name = ""
    var email = ""
    var username = ""
    var phone = ""
}

struct RelationshipProfile: Codable, Equatable {
    var hasSignificantOther = false
    var partnerName = ""
    var startedOn = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    var isMarried = false
    var linkedPartnerHandle = ""
    var lastThinkingOfYouSentAt: Date?

    var trimmedPartnerName: String {
        partnerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var displayName: String {
        let name = trimmedPartnerName
        return name.isEmpty ? "your person" : name
    }

    var hasLinkedPartner: Bool {
        !linkedPartnerHandle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct GuideMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable { case guide, user }

    let id: UUID
    let role: Role
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), role: Role, text: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

struct LessonCard: Identifiable, Hashable {
    let id: String
    let module: String
    let title: String
    let body: String
    let practice: String
    let sourceLabel: String
    let sourceURL: URL

    init(
        id: String? = nil,
        module: String = "Foundations",
        title: String,
        body: String,
        practice: String,
        sourceLabel: String,
        sourceURL: URL
    ) {
        self.id = id ?? title.lowercased().replacingOccurrences(of: " ", with: "-")
        self.module = module
        self.title = title
        self.body = body
        self.practice = practice
        self.sourceLabel = sourceLabel
        self.sourceURL = sourceURL
    }
}

struct DailyWisdomQuote: Identifiable, Codable, Equatable {
    let id: String
    let text: String
    let attribution: String
    let work: String
    let sourceURL: String
    let qualityScore: Int
    let featured: Bool

    var source: URL? { URL(string: sourceURL) }
}

struct BookLesson: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let summary: String
    let quotation: String
    let interpretation: String
    let practice: String
}

struct WithinBook: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let year: String
    let category: String
    let symbol: String
    let overview: String
    let sourceURL: URL
    let lessons: [BookLesson]
}

struct MeditationPreset: Identifiable, Hashable {
    let id: String
    let title: String
    let purpose: String
    let duration: Int
    let symbol: String
    let cues: [String]
}

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var text: String
    var mood: Int
}

struct FoodLogItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let grams: Double
    let calories: Double
    let protein: Double
    let carbohydrate: Double
    let fat: Double
    let fiber: Double
}

struct SleepEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var bedtime: Date
    var wakeTime: Date
    var refreshed: Int

    var durationHours: Double {
        var interval = wakeTime.timeIntervalSince(bedtime)
        if interval <= 0 { interval += 24 * 60 * 60 }
        return interval / 3_600
    }
}

struct DreamEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var title: String
    var text: String
}

enum AppDestination: Hashable {
    case guide
    case journal
    case nutrition
    case recovery
    case membership
    case settings
}
