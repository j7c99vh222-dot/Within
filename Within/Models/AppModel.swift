import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var profile: AccountProfile {
        didSet { save(profile, key: Keys.profile) }
    }
    @Published var focus: FocusArea {
        didSet {
            defaults.set(focus.rawValue, forKey: Keys.focus)
            completedTasks = Array(repeating: false, count: dailyTasks.count)
            persistDailyState()
        }
    }
    @Published var companion: CompanionChoice {
        didSet { defaults.set(companion.rawValue, forKey: Keys.companion) }
    }
    @Published var theme: ThemeMode {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }
    @Published var isOnboarded: Bool {
        didSet { defaults.set(isOnboarded, forKey: Keys.onboarded) }
    }
    @Published var dailyFeeling: DailyFeeling {
        didSet { persistDailyState() }
    }
    @Published var mood: Int {
        didSet { persistDailyState() }
    }
    @Published var completedTasks: [Bool] {
        didSet { persistDailyState() }
    }
    @Published var workoutStatus: String {
        didSet { persistDailyState() }
    }
    @Published var completedWorkoutAreas: Set<WorkoutArea> {
        didSet { persistDailyState() }
    }
    @Published var guideMessages: [GuideMessage]
    @Published var guideIsReplying = false
    @Published var completedLessonIDs: Set<String> {
        didSet { save(completedLessonIDs, key: Keys.completedLessons) }
    }
    @Published var healthWeightKilograms: Double {
        didSet { defaults.set(healthWeightKilograms, forKey: Keys.healthWeight) }
    }
    @Published var waterGoalLiters: Double {
        didSet { defaults.set(waterGoalLiters, forKey: Keys.waterGoal) }
    }
    @Published var waterMilestones: Int {
        didSet {
            defaults.set(waterMilestones, forKey: Keys.waterMilestones)
            persistDailyState()
        }
    }
    @Published var relationship: RelationshipProfile {
        didSet { save(relationship, key: Keys.relationship) }
    }
    @Published var selectedTab = 0
    @Published var presentedDestination: AppDestination?

    private let defaults: UserDefaults
    private let guideService = GuideService()

    init(defaults: UserDefaults = .standard) {
        let storedFocus = FocusArea(rawValue: defaults.string(forKey: Keys.focus) ?? "") ?? .growth
        let storedCompanion = CompanionChoice(rawValue: defaults.string(forKey: Keys.companion) ?? "") ?? .capy
        let snapshot = Self.decode(DailySnapshot.self, from: defaults.data(forKey: Keys.dailyState))
        let today = Self.dayStamp()
        let activeSnapshot = snapshot?.stamp == today ? snapshot : nil

        self.defaults = defaults
        profile = Self.decode(AccountProfile.self, from: defaults.data(forKey: Keys.profile)) ?? AccountProfile()
        focus = storedFocus
        companion = storedCompanion
        theme = ThemeMode(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .minimal
        isOnboarded = defaults.bool(forKey: Keys.onboarded)
        dailyFeeling = activeSnapshot?.feeling ?? .steady
        mood = activeSnapshot?.intensity ?? 0
        let storedTasks = activeSnapshot?.completedTasks ?? []
        completedTasks = Array(0..<4).map { storedTasks.indices.contains($0) ? storedTasks[$0] : false }
        workoutStatus = activeSnapshot?.workoutStatus ?? ""
        completedWorkoutAreas = activeSnapshot?.workoutAreas ?? []
        guideMessages = [
            GuideMessage(role: .guide, text: "\(storedCompanion.greeting) What feels most important right now?")
        ]
        completedLessonIDs = Self.decode(Set<String>.self, from: defaults.data(forKey: Keys.completedLessons)) ?? []
        let storedWeight = defaults.object(forKey: Keys.healthWeight) == nil ? 70 : defaults.double(forKey: Keys.healthWeight)
        healthWeightKilograms = max(35, storedWeight)
        let storedWaterGoal = defaults.double(forKey: Keys.waterGoal)
        waterGoalLiters = storedWaterGoal > 0 ? storedWaterGoal : 2.25
        waterMilestones = activeSnapshot?.waterMilestones ?? 0
        relationship = Self.decode(RelationshipProfile.self, from: defaults.data(forKey: Keys.relationship)) ?? RelationshipProfile()
        defaults.set(today, forKey: Keys.dailyDate)
    }

    var displayName: String {
        let first = profile.name.split(separator: " ").first.map(String.init) ?? ""
        return first.isEmpty ? "there" : first
    }

    var dailyQuote: DailyWisdomQuote {
        let qualified = WisdomLibrary.all.filter { $0.qualityScore >= 9 }
        let pool = qualified.isEmpty ? WisdomLibrary.featured : qualified
        return pool[stableIndex(salt: "wisdom", count: pool.count)]
    }

    var dailyFact: String {
        let lessonFacts = FocusArea.allCases.flatMap { area in
            (LearningContent.cards[area] ?? []).map(\.body)
        }
        let pool = SampleContent.facts + lessonFacts
        return pool[stableIndex(salt: "science", count: pool.count)]
    }

    var dailyRitualTitle: String { dailyFeeling.ritualTitle }

    var dailyAction: String {
        let actions = [
            "Drink a glass of water, then let ten breaths pass without asking them to fix you.",
            "Write one fact, one fear, and one choice that still belongs to you.",
            "Walk for five unhurried minutes and let movement be company, not punishment.",
            "Put one useful action in sight and move one automatic distraction farther away.",
            "Complete one small task whose only purpose is to make tomorrow kinder.",
            "Give the body food, water, rest, or movement before demanding a philosophical answer from it.",
            "Put the phone down long enough to hear one complete thought of your own.",
            "Name the need hiding beneath the irritation before you act from it."
        ]
        return actions[stableIndex(salt: "action", count: actions.count)]
    }

    var dailyTasks: [String] {
        let base = focus.tasks
        let offset = stableIndex(salt: "tasks", count: base.count)
        let closing = [
            "Write one sentence your future self should not have to rediscover",
            "Prepare tomorrow's first kind decision",
            "Notice one thing that changed after you began",
            "End the day without demanding a perfect explanation"
        ]
        var result = [dailyFeeling.firstAction]
        result.append(base[offset])
        result.append(base[(offset + 1) % base.count])
        result.append(closing[stableIndex(salt: "closing", count: closing.count)])
        return result
    }

    var dailyIntensityCopy: String {
        if mood >= 4 { return "Keep the plan protective and small. High intensity calls for support, not a heroic performance." }
        if mood > 0 && mood <= 2 { return "There is enough room today to practice before the moment becomes difficult." }
        return "Let the plan meet the day as it is, without asking it to become a different day first."
    }

    var dailyEditionNumber: Int { stableIndex(salt: "edition", count: 100_000) }

    var lessonCards: [LessonCard] {
        LearningContent.cards[focus] ?? LearningContent.cards[.growth] ?? []
    }

    var dailyLessonIndex: Int {
        guard !lessonCards.isEmpty else { return 0 }
        return stableIndex(salt: "lesson-\(focus.rawValue)", count: lessonCards.count)
    }

    var waterConsumedLiters: Double {
        waterGoalLiters * Double(waterMilestones) / 4
    }

    var completedTaskCount: Int { completedTasks.filter { $0 }.count }

    var relationshipFeatureEnabled: Bool {
        relationship.hasSignificantOther
    }

    var dailyRelationshipPrompt: (title: String, body: String) {
        let name = relationship.displayName
        let prompts = [
            ("Small repair", "Ask \(name) one question you can listen to without preparing a defense."),
            ("Warm contact", "Offer \(name) a hug, a hand squeeze, or a kind sentence without making it a transaction."),
            ("Noticing practice", "Name one thing \(name) did recently that made life easier, and say it plainly."),
            ("Less heat", "If tension shows up, pause long enough to say the need beneath the complaint."),
            ("Future kindness", "Do one small thing today that tomorrow's version of your relationship will thank you for."),
            ("Shared attention", "Put the phone down for ten minutes and let \(name) have your full attention."),
            ("Soft check-in", "Ask \(name), \"What would help you feel loved this week?\" Then write down the answer.")
        ]
        return prompts[stableIndex(salt: "relationship-prompt", count: prompts.count)]
    }

    var relationshipAnniversarySummary: String {
        guard relationship.hasSignificantOther else { return "No partner calendar yet" }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: relationship.startedOn)
        var components = calendar.dateComponents([.month, .day], from: start)
        components.year = calendar.component(.year, from: today)

        guard var next = calendar.date(from: components) else {
            return "Anniversary date saved"
        }

        if next < today {
            components.year = (components.year ?? calendar.component(.year, from: today)) + 1
            next = calendar.date(from: components) ?? next
        }

        let days = calendar.dateComponents([.day], from: today, to: next).day ?? 0
        let years = max(0, calendar.dateComponents([.year], from: start, to: next).year ?? 0)
        let label = relationship.isMarried ? "Wedding anniversary" : "Anniversary"

        if days == 0 {
            return "\(label) today · \(years) years"
        }
        if days == 1 {
            return "\(label) tomorrow · \(years) years"
        }
        return "\(label) in \(days) days · \(years) years"
    }

    func completeOnboarding(profile: AccountProfile, focus: FocusArea, companion: CompanionChoice, theme: ThemeMode, relationship: RelationshipProfile) {
        self.profile = profile
        self.focus = focus
        self.companion = companion
        self.theme = theme
        self.relationship = relationship
        guideMessages = [GuideMessage(role: .guide, text: "\(companion.greeting) What feels most important right now?")]
        isOnboarded = true
    }

    func resetDemo() {
        profile = AccountProfile()
        focus = .growth
        companion = .capy
        theme = .minimal
        dailyFeeling = .steady
        mood = 0
        completedTasks = Array(repeating: false, count: 4)
        workoutStatus = ""
        completedWorkoutAreas = []
        guideMessages = [GuideMessage(role: .guide, text: CompanionChoice.capy.greeting)]
        completedLessonIDs = []
        healthWeightKilograms = 70
        waterGoalLiters = 2.25
        waterMilestones = 0
        relationship = RelationshipProfile()
        isOnboarded = false
    }

    func chooseFeeling(_ feeling: DailyFeeling) {
        refreshDailyState()
        dailyFeeling = feeling
    }

    func chooseCompanion(_ choice: CompanionChoice) {
        companion = choice
        guideMessages = [GuideMessage(role: .guide, text: "\(choice.greeting) What feels most important right now?")]
    }

    func toggleTask(_ index: Int) {
        refreshDailyState()
        guard completedTasks.indices.contains(index) else { return }
        completedTasks[index].toggle()
    }

    func setWorkoutStatus(_ status: String) {
        refreshDailyState()
        workoutStatus = status
        if status != "trained" { completedWorkoutAreas = [] }
    }

    func toggleWorkoutArea(_ area: WorkoutArea) {
        refreshDailyState()
        if completedWorkoutAreas.contains(area) { completedWorkoutAreas.remove(area) }
        else { completedWorkoutAreas.insert(area) }
    }

    func toggleLesson(_ id: String) {
        if completedLessonIDs.contains(id) { completedLessonIDs.remove(id) }
        else { completedLessonIDs.insert(id) }
    }

    func updateHydrationGoal(for weightKilograms: Double) {
        healthWeightKilograms = min(300, max(35, weightKilograms))
        let estimate = min(4, max(1.5, healthWeightKilograms * 0.03))
        waterGoalLiters = (estimate * 4).rounded() / 4
    }

    func setWaterMilestone(_ milestone: Int) {
        refreshDailyState()
        waterMilestones = min(4, max(0, milestone))
    }

    func updatePartnerLink(_ handle: String) {
        relationship.linkedPartnerHandle = handle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func sendThinkingOfYouPing() {
        relationship.lastThinkingOfYouSentAt = Date()
    }

    func refreshDailyState() {
        let today = Self.dayStamp()
        guard defaults.string(forKey: Keys.dailyDate) != today else { return }
        defaults.set(today, forKey: Keys.dailyDate)
        dailyFeeling = .steady
        mood = 0
        completedTasks = Array(repeating: false, count: 4)
        workoutStatus = ""
        completedWorkoutAreas = []
        waterMilestones = 0
        persistDailyState()
    }

    func sendGuideMessage(_ text: String) async {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, !guideIsReplying else { return }
        guideMessages.append(GuideMessage(role: .user, text: clean))
        guideIsReplying = true
        let reply = await guideService.reply(to: clean, focus: focus, companion: companion)
        guideMessages.append(GuideMessage(role: .guide, text: reply))
        guideIsReplying = false
    }

    private func stableIndex(salt: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let identity = profile.username.isEmpty ? profile.email : profile.username
        return Int(Self.stableHash("\(Self.dayStamp()):\(identity.lowercased()):\(focus.rawValue):\(salt)") % UInt64(count))
    }

    private static func stableHash(_ value: String) -> UInt64 {
        value.utf8.reduce(UInt64(14_695_981_039_346_656_037)) { partial, byte in
            (partial ^ UInt64(byte)) &* 1_099_511_628_211
        }
    }

    private static func dayStamp(_ date: Date = Date()) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    private func persistDailyState() {
        guard defaults.string(forKey: Keys.dailyDate) == Self.dayStamp() else { return }
        let snapshot = DailySnapshot(stamp: Self.dayStamp(), feeling: dailyFeeling, intensity: mood, completedTasks: completedTasks, workoutStatus: workoutStatus, workoutAreas: completedWorkoutAreas, waterMilestones: waterMilestones)
        save(snapshot, key: Keys.dailyState)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private struct DailySnapshot: Codable {
        let stamp: String
        let feeling: DailyFeeling
        let intensity: Int
        let completedTasks: [Bool]
        let workoutStatus: String
        let workoutAreas: Set<WorkoutArea>
        let waterMilestones: Int
    }

    private enum Keys {
        static let profile = "within.native.profile"
        static let focus = "within.native.focus"
        static let companion = "within.native.companion"
        static let theme = "within.native.theme"
        static let onboarded = "within.native.onboarded"
        static let completedLessons = "within.native.completed-lessons"
        static let healthWeight = "within.native.health-weight"
        static let waterGoal = "within.native.water-goal"
        static let waterMilestones = "within.native.water-milestones"
        static let relationship = "within.native.relationship"
        static let dailyDate = "within.native.daily-date"
        static let dailyState = "within.native.daily-state-v2"
    }
}
