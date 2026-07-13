import Foundation

struct GuideService {
    func reply(to message: String, focus: FocusArea, companion: CompanionChoice) async -> String {
        let normalized = message.lowercased()
        if containsImmediateDanger(normalized) {
            return "Your immediate safety matters more than this chat. Call emergency services now if danger is present. In the U.S. or Canada, call or text 988. Move near another person and tell them clearly that you need immediate help."
        }

        if let onlineReply = await requestOnlineReply(message: message, focus: focus, companion: companion) {
            return onlineReply
        }

        if normalized.contains("panic") || normalized.contains("anxious") || normalized.contains("anxiety") {
            return "Let us make the next sixty seconds smaller. Put both feet down, look for three ordinary objects, and breathe out a little longer than you breathe in. Do not force a deep breath. When the wave lowers even slightly, choose one safe person or place to move toward."
        }
        if normalized.contains("urge") || normalized.contains("craving") || normalized.contains("relapse") {
            return "Create distance before debating the urge: leave the room, remove access, set a ten-minute timer, and contact someone safe. An urge can feel urgent without being an instruction. If overdose or withdrawal risk is possible, use professional or emergency support now."
        }
        if normalized.contains("food") || normalized.contains("diet") || normalized.contains("meal") {
            return "Start with steadiness rather than punishment: a regular meal with protein, a fiber-rich plant food, water, and enough total energy. One meal does not determine your health. Persistent digestive, weight, or eating concerns deserve individualized medical care."
        }
        if normalized.contains("sleep") || normalized.contains("insomnia") || normalized.contains("refreshed") {
            return "Use the week as information rather than a grade. Protect enough sleep opportunity and a repeatable wake time, keep the room quiet, cool, and dark, and notice whether caffeine, alcohol, stress, or symptoms track with difficult nights. Persistent insomnia, loud snoring, gasping, or unsafe daytime sleepiness deserves professional assessment."
        }
        if normalized.contains("depress") || normalized.contains("hopeless") || normalized.contains("empty") {
            return "You do not need to solve your whole life from this state. Choose one action under five minutes: open the curtains, drink water, step outside, or message someone you trust. If hopelessness includes thoughts of dying or self-harm, call or text 988 in the U.S. or Canada now."
        }

        return "\(companion.name) here. For your \(focus.title.lowercased()) path, make this concrete: what happened, what did your body do, what story did your mind add, and what is one action small enough to complete in ten minutes? Start with the action that increases safety or support."
    }

    private func requestOnlineReply(message: String, focus: FocusArea, companion: CompanionChoice) async -> String? {
        guard
            let rawBaseURL = Bundle.main.object(forInfoDictionaryKey: "WITHIN_API_BASE_URL") as? String,
            let baseURL = URL(string: rawBaseURL),
            let url = URL(string: "api/guide", relativeTo: baseURL)
        else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(RequestBody(message: message, focus: focus.rawValue, companion: companion.rawValue))

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            return try JSONDecoder().decode(ResponseBody.self, from: data).message
        } catch {
            return nil
        }
    }

    private func containsImmediateDanger(_ text: String) -> Bool {
        ["kill myself", "suicide", "end my life", "hurt myself", "overdose now", "someone will hurt me"].contains { text.contains($0) }
    }

    private struct RequestBody: Encodable {
        let message: String
        let focus: String
        let companion: String
    }

    private struct ResponseBody: Decodable {
        let message: String
    }
}
