import Foundation

enum AffirmationLibrary {
    private static let openings = [
        "You can do this.",
        "You are allowed to begin gently.",
        "You do not have to solve the whole day at once.",
        "You are still here, and that matters.",
        "You can take one honest step.",
        "Your pace can be kind today.",
        "You are not behind your life.",
        "You can return to yourself.",
        "This morning can start small.",
        "You are allowed to need support.",
        "You can choose the next right thing.",
        "You do not need perfect energy to begin.",
        "There is room for you today.",
        "You can meet this day without rushing.",
        "You are more than yesterday's hardest moment.",
        "You can be patient with your nervous system.",
        "You can make today easier to carry.",
        "You are allowed to protect your peace.",
        "You can move with quiet courage.",
        "You are worth steady care.",
        "You can start again without shame.",
        "You can keep one promise to yourself.",
        "You are allowed to be a work in progress.",
        "You can let the day be human-sized.",
        "You can do something kind for future you."
    ]

    private static let actions = [
        "Drink water before judging your mood.",
        "Take three slow breaths and unclench your jaw.",
        "Put one useful action in front of you.",
        "Send one honest message instead of disappearing.",
        "Step into daylight for a minute.",
        "Write the truest sentence you can find.",
        "Make breakfast, or make the next meal simpler.",
        "Stretch your shoulders and soften your hands.",
        "Choose the smallest version of the task.",
        "Notice one thing that is not an emergency.",
        "Give your body food, water, movement, or rest.",
        "Do the next five minutes with care.",
        "Let one thought pass without obeying it.",
        "Make your room one percent easier to live in.",
        "Pause before reacting from fear.",
        "Ask for help before the day gets too loud.",
        "Let effort count even when it is quiet.",
        "Choose repair over self-punishment.",
        "Use your breath as a place to return.",
        "Remember that consistency can be gentle."
    ]

    private static let closings = [
        "Keep it gentle today.",
        "One small step still counts."
    ]

    static let all: [String] = openings.flatMap { opening in
        actions.flatMap { action in
            closings.map { closing in
                "\(opening) \(action) \(closing)"
            }
        }
    }

    static func affirmation(for date: Date = Date(), profile: AccountProfile = AccountProfile()) -> String {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        let identity = profile.username.isEmpty ? profile.email : profile.username
        let seed = Int(stableHash(identity.lowercased()) % UInt64(all.count))
        let message = all[(day + seed) % all.count]
        let firstName = profile.name.split(separator: " ").first.map(String.init) ?? ""

        if firstName.isEmpty {
            return message
        }

        return "\(firstName), \(message.prefix(1).lowercased())\(message.dropFirst())"
    }

    private static func stableHash(_ value: String) -> UInt64 {
        value.utf8.reduce(UInt64(14_695_981_039_346_656_037)) { partial, byte in
            (partial ^ UInt64(byte)) &* 1_099_511_628_211
        }
    }
}
