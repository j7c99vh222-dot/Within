import Foundation

actor PrivateStore {
    static let shared = PrivateStore()

    private let journalURL: URL
    private let photoURL: URL
    private let sleepURL: URL
    private let dreamURL: URL
    private let nutritionURL: URL

    init(fileManager: FileManager = .default) {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("WithinPrivate", isDirectory: true)
        try? fileManager.createDirectory(at: base, withIntermediateDirectories: true)
        journalURL = base.appendingPathComponent("journal.json")
        photoURL = base.appendingPathComponent("progress-photo.data")
        sleepURL = base.appendingPathComponent("sleep.json")
        dreamURL = base.appendingPathComponent("dreams.json")
        nutritionURL = base.appendingPathComponent("nutrition-log.json")
    }

    func loadJournal() -> [JournalEntry] {
        guard let data = try? Data(contentsOf: journalURL) else { return [] }
        return (try? JSONDecoder.within.decode([JournalEntry].self, from: data)) ?? []
    }

    func saveJournal(_ entries: [JournalEntry]) throws {
        let data = try JSONEncoder.within.encode(entries)
        try protectedWrite(data, to: journalURL)
    }

    func loadProgressPhoto() -> Data? {
        try? Data(contentsOf: photoURL)
    }

    func saveProgressPhoto(_ data: Data) throws {
        try protectedWrite(data, to: photoURL)
    }

    func deleteProgressPhoto() throws {
        guard FileManager.default.fileExists(atPath: photoURL.path) else { return }
        try FileManager.default.removeItem(at: photoURL)
    }

    func loadSleep() -> [SleepEntry] {
        guard let data = try? Data(contentsOf: sleepURL) else { return [] }
        return (try? JSONDecoder.within.decode([SleepEntry].self, from: data)) ?? []
    }

    func saveSleep(_ entries: [SleepEntry]) throws {
        let data = try JSONEncoder.within.encode(entries)
        try protectedWrite(data, to: sleepURL)
    }

    func loadDreams() -> [DreamEntry] {
        guard let data = try? Data(contentsOf: dreamURL) else { return [] }
        return (try? JSONDecoder.within.decode([DreamEntry].self, from: data)) ?? []
    }

    func saveDreams(_ entries: [DreamEntry]) throws {
        let data = try JSONEncoder.within.encode(entries)
        try protectedWrite(data, to: dreamURL)
    }

    func loadFoodLog(for date: Date = Date()) -> [FoodLogItem] {
        guard let data = try? Data(contentsOf: nutritionURL),
              let days = try? JSONDecoder.within.decode([String: [FoodLogItem]].self, from: data) else { return [] }
        return days[Self.dayKey(date)] ?? []
    }

    func saveFoodLog(_ entries: [FoodLogItem], for date: Date = Date()) throws {
        let existingData = try? Data(contentsOf: nutritionURL)
        var days = existingData.flatMap { try? JSONDecoder.within.decode([String: [FoodLogItem]].self, from: $0) } ?? [:]
        days[Self.dayKey(date)] = entries
        let data = try JSONEncoder.within.encode(days)
        try protectedWrite(data, to: nutritionURL)
    }

    func deleteAllPrivateData() throws {
        for url in [journalURL, photoURL, sleepURL, dreamURL, nutritionURL] {
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            try FileManager.default.removeItem(at: url)
        }
    }

    private static func dayKey(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    private func protectedWrite(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
    }
}

private extension JSONEncoder {
    static var within: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var within: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
