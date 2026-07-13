import SwiftUI

struct LearnView: View {
    @EnvironmentObject private var app: AppModel
    @State private var section: Section = .course
    @State private var cardIndex = 0
    @State private var seededDailyLesson = false

    enum Section: String, CaseIterable, Identifiable {
        case course = "Course"
        case books = "Books"
        case nutrition = "Nutrition"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Eyebrow(text: "Learning studio · \(app.focus.title)")
                        Text("Understand the pattern. Practice the alternative.")
                            .font(.system(size: 34, weight: .medium, design: .serif))
                        Text("A source-linked course with a different lesson waiting each day. Progress stays on this device.")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryText)
                    }

                    Picker("Learning section", selection: $section) {
                        ForEach(Section.allCases) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch section {
                    case .course: courseDeck
                    case .books: bookLibrary
                    case .nutrition: nutritionCourse
                    }
                }
                .padding(.horizontal, 17)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
            .withinScreen()
            .onAppear { seedDailyLessonIfNeeded() }
            .onChange(of: app.focus) { _, _ in
                seededDailyLesson = false
                seedDailyLessonIfNeeded()
            }
        }
    }

    private var courseDeck: some View {
        let cards = app.lessonCards
        let index = cards.isEmpty ? 0 : min(cardIndex, cards.count - 1)
        let completed = cards.filter { app.completedLessonIDs.contains($0.id) }.count

        return VStack(alignment: .leading, spacing: 18) {
            if cards.isEmpty {
                Text("This course is being prepared.")
                    .foregroundStyle(palette.secondaryText)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Eyebrow(text: "Course progress")
                        Spacer()
                        Text("\(completed) of \(cards.count) reviewed")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.secondaryText)
                    }
                    ProgressView(value: Double(completed), total: Double(cards.count))
                        .tint(palette.accent)
                    Text("Today's lesson opens automatically. You can move through the full course in any order.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }

                lessonCard(cards[index], index: index, total: cards.count)
                moduleMap(cards)
            }
        }
    }

    private func lessonCard(_ card: LessonCard, index: Int, total: Int) -> some View {
        let isComplete = app.completedLessonIDs.contains(card.id)
        return VStack(alignment: .leading, spacing: 22) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Eyebrow(text: index == app.dailyLessonIndex ? "Today's lesson" : card.module)
                    Text("Lesson \(index + 1) of \(total)")
                        .font(.caption2)
                        .foregroundStyle(palette.secondaryText)
                }
                Spacer()
                Label("Evidence linked", systemImage: "checkmark.shield")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
            Image(systemName: app.focus.symbol)
                .font(.title2)
                .foregroundStyle(palette.accent)
            Text(card.title)
                .font(.system(size: 29, weight: .medium, design: .serif))
            Text(card.body)
                .font(.body)
                .foregroundStyle(palette.secondaryText)
                .lineSpacing(5)
            VStack(alignment: .leading, spacing: 8) {
                Eyebrow(text: "Try this")
                Text(card.practice)
                    .font(.headline)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(palette.accentSoft)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            Link(destination: card.sourceURL) {
                Label(card.sourceLabel, systemImage: "arrow.up.right.square")
                    .font(.caption.weight(.semibold))
            }
            Button {
                app.toggleLesson(card.id)
            } label: {
                Label(isComplete ? "Reviewed" : "Mark lesson reviewed", systemImage: isComplete ? "checkmark.circle.fill" : "circle")
                    .frame(maxWidth: .infinity, minHeight: 45)
            }
            .buttonStyle(.borderedProminent)
            HStack {
                Button {
                    cardIndex = max(0, index - 1)
                } label: {
                    Image(systemName: "arrow.left")
                        .frame(width: 42, height: 42)
                        .overlay(Circle().stroke(palette.line))
                }
                .disabled(index == 0)
                Spacer()
                Button {
                    cardIndex = (index + 1) % total
                } label: {
                    Label(index == total - 1 ? "Start again" : "Next lesson", systemImage: "arrow.right")
                        .font(.subheadline.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(21)
        .withinSurface()
    }

    private func moduleMap(_ cards: [LessonCard]) -> some View {
        let modules = cards.reduce(into: [String]()) { result, card in
            if !result.contains(card.module) { result.append(card.module) }
        }
        return VStack(alignment: .leading, spacing: 0) {
            Eyebrow(text: "Course map")
                .padding(.bottom, 10)
            ForEach(modules, id: \.self) { module in
                let moduleCards = cards.filter { $0.module == module }
                let reviewed = moduleCards.filter { app.completedLessonIDs.contains($0.id) }.count
                Button {
                    if let next = cards.firstIndex(where: { $0.module == module && !app.completedLessonIDs.contains($0.id) })
                        ?? cards.firstIndex(where: { $0.module == module }) {
                        cardIndex = next
                    }
                } label: {
                    HStack(spacing: 13) {
                        Image(systemName: reviewed == moduleCards.count ? "checkmark.circle.fill" : "circle.dotted")
                            .foregroundStyle(palette.accent)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(module)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(palette.text)
                            Text("\(reviewed) of \(moduleCards.count) reviewed")
                                .font(.caption2)
                                .foregroundStyle(palette.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                    }
                    .frame(minHeight: 58)
                }
                .buttonStyle(.plain)
                if module != modules.last { Divider().overlay(palette.line) }
            }
        }
    }

    private var bookLibrary: some View {
        LazyVStack(spacing: 10) {
            HStack {
                Text("\(SampleContent.books.count) guided public-domain readers")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.secondaryText)
                Spacer()
            }
            ForEach(SampleContent.books) { book in
                NavigationLink(destination: BookReaderView(book: book)) {
                    HStack(spacing: 15) {
                        Image(systemName: book.symbol)
                            .font(.title2)
                            .frame(width: 50, height: 66)
                            .background(palette.accentSoft)
                            .foregroundStyle(palette.accent)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(book.title)
                                .font(.system(.headline, design: .serif))
                            Text("\(book.author) · \(book.year)")
                                .font(.caption)
                                .foregroundStyle(palette.secondaryText)
                            Text("\(book.lessons.count) guided lessons · \(book.category)")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(palette.accent)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding(14)
                    .withinSurface()
                }
                .buttonStyle(.plain)
            }

            Text("Source links identify the exact edition. Project Gutenberg marks these editions public domain in the United States; copyright rules can differ elsewhere. Ancient works remain part of living traditions, and translations carry their own historical perspective.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
                .padding(.top, 8)
        }
    }

    private var nutritionCourse: some View {
        VStack(spacing: 12) {
            ForEach(Array(nutritionLessons.enumerated()), id: \.offset) { index, lesson in
                courseRow(number: String(format: "%02d", index + 1), lesson: lesson)
            }
        }
    }

    private func courseRow(number: String, lesson: NutritionLesson) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .top, spacing: 15) {
                Text(number)
                    .font(.system(.caption, design: .serif).italic())
                    .foregroundStyle(palette.accent)
                VStack(alignment: .leading, spacing: 7) {
                    Text(lesson.title)
                        .font(.system(.title3, design: .serif))
                    Text(lesson.text)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                        .lineSpacing(4)
                }
            }
            Link(destination: lesson.source) {
                Label(lesson.sourceLabel, systemImage: "arrow.up.right.square")
                    .font(.caption.weight(.semibold))
            }
            .padding(.leading, 35)
        }
        .padding(18)
        .withinSurface()
    }

    private func seedDailyLessonIfNeeded() {
        guard !seededDailyLesson else { return }
        cardIndex = app.dailyLessonIndex
        seededDailyLesson = true
    }

    private var nutritionLessons: [NutritionLesson] {
        [
            NutritionLesson("The gut-brain axis", "Neural, immune, endocrine, metabolic, and microbial pathways connect digestive and brain function. The relationship is important and complex; one food does not cure mental illness.", "NIDDK · Digestive health", "https://www.niddk.nih.gov/health-information/digestive-diseases"),
            NutritionLesson("Fiber feeds an ecosystem", "Different plant fibers support different microbes and bowel function. Increase gradually and seek care for persistent pain or major bowel changes.", "Dietary Guidelines", "https://www.dietaryguidelines.gov/"),
            NutritionLesson("Protein supports more than muscle", "Protein supplies amino acids used throughout the body. Needs vary with size, age, activity, pregnancy, health, and total energy intake.", "Dietary Guidelines", "https://www.dietaryguidelines.gov/"),
            NutritionLesson("Low added sugar is not no carbohydrate", "Added sugar guidance does not make fruit, plain dairy, legumes, and whole grains equivalent to sweetened drinks or candy.", "Dietary Guidelines", "https://www.dietaryguidelines.gov/"),
            NutritionLesson("Fermented is not automatically probiotic", "Some fermented foods contain live microbes, while others do not. Product strains and health effects differ, and evidence is specific rather than universal.", "NCCIH · Probiotics", "https://www.nccih.nih.gov/health/probiotics-what-do-we-know"),
            NutritionLesson("Food variety matters", "Different foods bring different fibers and micronutrients. Variety over time is more defensible than dependence on one superfood.", "MyPlate · Food groups", "https://www.myplate.gov/eat-healthy/what-is-myplate"),
            NutritionLesson("Hydration includes food", "Total water includes beverages and water in food. Needs change with climate, activity, pregnancy, illness, and medical conditions.", "National Academies · Water", "https://www.nationalacademies.org/read/10925/chapter/2"),
            NutritionLesson("Meal timing is context, not magic", "Regular eating can support steadiness for many people, but no single timing pattern fits shift work, diabetes treatment, pregnancy, sport, or eating-disorder recovery.", "Dietary Guidelines", "https://www.dietaryguidelines.gov/"),
            NutritionLesson("Supplements are not risk-free", "Supplements can interact with medicines and may not match their label. Food-first is not an absolute rule, but supplementation should have a reason.", "NIH · Dietary supplements", "https://ods.od.nih.gov/factsheets/WYNTK-Consumer/"),
            NutritionLesson("Symptoms need assessment", "Persistent bleeding, severe pain, trouble swallowing, dehydration, unexplained weight change, or ongoing bowel changes should not be treated with increasingly restrictive internet diets.", "NIDDK · Digestive health", "https://www.niddk.nih.gov/health-information/digestive-diseases"),
        ]
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}

private struct NutritionLesson {
    let title: String
    let text: String
    let sourceLabel: String
    let source: URL

    init(_ title: String, _ text: String, _ sourceLabel: String, _ source: String) {
        self.title = title
        self.text = text
        self.sourceLabel = sourceLabel
        self.source = URL(string: source)!
    }
}
