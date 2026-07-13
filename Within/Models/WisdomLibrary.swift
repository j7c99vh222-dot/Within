import Foundation

enum WisdomLibrary {
    static let all: [DailyWisdomQuote] = {
        let nestedURL = Bundle.main.url(
                forResource: "daily-wisdom",
                withExtension: "json",
                subdirectory: "Wisdom"
            )
        let url = nestedURL ?? Bundle.main.url(forResource: "daily-wisdom", withExtension: "json")
        guard
            let url,
            let data = try? Data(contentsOf: url),
            let entries = try? JSONDecoder().decode([DailyWisdomQuote].self, from: data),
            !entries.isEmpty
        else {
            return fallback
        }
        return entries
    }()

    static let featured: [DailyWisdomQuote] = {
        let selected = all.filter(\.featured)
        return selected.isEmpty ? all : selected
    }()

    private static let fallback = [
        DailyWisdomQuote(
            id: "fallback-meditations",
            text: "The happiness of your life depends upon the quality of your thoughts.",
            attribution: "Marcus Aurelius · George Long translation",
            work: "Meditations",
            sourceURL: "https://www.gutenberg.org/ebooks/2680",
            qualityScore: 12,
            featured: true
        )
    ]
}
