import SwiftUI

struct SleepView: View {
    @EnvironmentObject private var app: AppModel
    @EnvironmentObject private var ambient: AmbientPlayer
    @State private var section: Section = .week
    @State private var sleepEntries: [SleepEntry] = []
    @State private var dreams: [DreamEntry] = []
    @State private var bedtime = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var wakeTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var refreshed = 3
    @State private var timerMinutes = 30
    @State private var dreamTitle = ""
    @State private var dreamText = ""

    enum Section: String, CaseIterable, Identifiable {
        case week = "Week"
        case sounds = "Sounds"
        case dreams = "Dreams"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    Picker("Sleep section", selection: $section) {
                        ForEach(Section.allCases) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch section {
                    case .week: weekView
                    case .sounds: soundView
                    case .dreams: dreamView
                    }
                }
                .padding(.horizontal, 17)
                .padding(.top, 18)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .withinScreen()
            .task { await loadPrivateData() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(text: "Rest and rhythm")
            Text("Learn from the week, not one night.")
                .font(.system(size: 34, weight: .medium, design: .serif))
            Text("Track timing, duration, and how restored you feel. Scores are wellness estimates, never diagnoses.")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryText)
        }
    }

    private var weekView: some View {
        VStack(alignment: .leading, spacing: 18) {
            weeklySummary
            logSleep
            sleepSources
        }
    }

    private var weeklySummary: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "Seven-day sleep estimate")
                    Text(sleepEntries.isEmpty ? "Start with tonight" : "\(weeklyScore)")
                        .font(.system(size: sleepEntries.isEmpty ? 29 : 48, weight: .medium, design: .serif))
                    if !sleepEntries.isEmpty {
                        Text("out of 100")
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                    }
                }
                Spacer()
                Image(systemName: "moon.stars")
                    .font(.title)
                    .foregroundStyle(palette.accent)
            }

            VStack(spacing: 9) {
                ForEach(lastSevenDays, id: \.self) { day in
                    sleepDayRow(day)
                }
            }

            Divider().overlay(palette.line)
            VStack(alignment: .leading, spacing: 8) {
                Label("Within pattern guide", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.accent)
                Text(sleepRecommendation)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryText)
                    .lineSpacing(4)
                if !sleepEntries.isEmpty {
                    NavigationLink(destination: GuideView(initialPrompt: guidePrompt)) {
                        Label("Review this summary with the guide", systemImage: "arrow.right")
                            .font(.caption.weight(.semibold))
                    }
                    Text("Your private log is only summarized into the draft after you choose this link. Review it before sending.")
                        .font(.system(size: 9))
                        .foregroundStyle(palette.secondaryText)
                }
            }
        }
        .padding(20)
        .withinSurface(emphasized: app.theme == .spiritual)
    }

    private func sleepDayRow(_ day: Date) -> some View {
        let entry = entry(on: day)
        let hours = entry?.durationHours ?? 0
        return HStack(spacing: 10) {
            Text(day.formatted(.dateTime.weekday(.narrow)))
                .font(.caption.weight(.bold))
                .frame(width: 18)
            ZStack(alignment: .leading) {
                Capsule().fill(palette.line).frame(height: 7)
                Capsule()
                    .fill(entry == nil ? Color.clear : palette.accent)
                    .frame(width: max(0, min(172, 172 * hours / 10)), height: 7)
            }
            .frame(width: 172)
            Spacer()
            Text(entry == nil ? "—" : "\(hours, format: .number.precision(.fractionLength(1)))h")
                .font(.caption.monospacedDigit())
                .foregroundStyle(entry == nil ? palette.secondaryText : palette.text)
            if let entry {
                Text("\(entry.refreshed)/5")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(palette.secondaryText)
                    .frame(width: 25, alignment: .trailing)
            } else {
                Text(" ").frame(width: 25)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var logSleep: some View {
        VStack(alignment: .leading, spacing: 17) {
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "Log last night")
                Text("Timing, duration, restoration")
                    .font(.system(.title3, design: .serif))
            }
            DatePicker("Fell asleep", selection: $bedtime, displayedComponents: .hourAndMinute)
            Divider().overlay(palette.line)
            DatePicker("Woke up", selection: $wakeTime, displayedComponents: .hourAndMinute)
            Divider().overlay(palette.line)
            VStack(alignment: .leading, spacing: 10) {
                Text("How refreshed did you feel?")
                    .font(.caption.weight(.semibold))
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            refreshed = value
                        } label: {
                            VStack(spacing: 5) {
                                Text("\(value)")
                                    .font(.headline)
                                Text(["Drained", "Tired", "Okay", "Rested", "Fresh"][value - 1])
                                    .font(.system(size: 8))
                            }
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(refreshed == value ? palette.accentSoft : palette.background)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(refreshed == value ? palette.accent : palette.line))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Button {
                saveSleepEntry()
            } label: {
                Label("Save today's sleep", systemImage: "checkmark")
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .withinSurface()
    }

    private var sleepSources: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Adults ages 18–60 are generally advised to get at least seven hours. A sleep diary can help a clinician understand timing, quality, medicines, caffeine, alcohol, and daytime sleepiness.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
            Link("CDC · About sleep", destination: URL(string: "https://www.cdc.gov/sleep/about/index.html")!)
            Link("NHLBI · Sleep diary", destination: URL(string: "https://www.nhlbi.nih.gov/resources/sleep-diary")!)
            Text("Regular loud snoring, gasping, unsafe sleepiness, persistent insomnia, or long unrefreshing sleep deserves professional assessment.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .font(.caption.weight(.semibold))
    }

    private var soundView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 7) {
                Eyebrow(text: "Sleep sound room")
                Text("Choose the sound your mind can stop following.")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                Text("Keep volume low enough that alarms and important sounds remain audible.")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                ForEach(AmbientPlayer.Sound.allCases.filter { $0 != .none }) { sound in
                    Button {
                        ambient.selected = sound
                        if ambient.isPlaying { ambient.play() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: sound.symbol)
                                .foregroundStyle(palette.accent)
                            Text(sound.title)
                                .font(.caption.weight(.semibold))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                        .background(ambient.selected == sound ? palette.accentSoft : palette.surface)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(ambient.selected == sound ? palette.accent : palette.line))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        if ambient.isPlaying {
                            ambient.stop()
                        } else {
                            ambient.play()
                            ambient.stop(afterMinutes: timerMinutes)
                        }
                    } label: {
                        Label(ambient.isPlaying ? "Stop" : "Play", systemImage: ambient.isPlaying ? "stop.fill" : "play.fill")
                            .frame(minWidth: 92, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    Picker("Timer", selection: $timerMinutes) {
                        Text("15 min").tag(15)
                        Text("30 min").tag(30)
                        Text("60 min").tag(60)
                        Text("2 hours").tag(120)
                    }
                    .pickerStyle(.menu)
                }
                HStack {
                    Image(systemName: "speaker.wave.1")
                    Slider(value: $ambient.volume, in: 0...0.45)
                    Image(systemName: "speaker.wave.3")
                }
                .foregroundStyle(palette.secondaryText)
            }
            .padding(18)
            .withinSurface()
            .onChange(of: timerMinutes) { _, minutes in
                if ambient.isPlaying { ambient.stop(afterMinutes: minutes) }
            }

            VStack(alignment: .leading, spacing: 9) {
                Text("About these recordings")
                    .font(.headline)
                Text("Every audio loop in this folder was generated specifically for Within, including the original classical-style arpeggio. No third-party recording license is required. The 432 Hz option is a tuning preference; the app does not claim that 432 Hz has unique medical effects.")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                Link("NCCIH · Sleep approaches and evidence", destination: URL(string: "https://www.nccih.nih.gov/health/sleep-disorders-and-complementary-health-approaches")!)
                    .font(.caption.weight(.semibold))
            }
        }
    }

    private var dreamView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Eyebrow(text: "Private dream journal")
                Text("Record first. Interpret carefully.")
                    .font(.system(size: 29, weight: .medium, design: .serif))
                Text("Dreams can reflect many ordinary influences. The app does not diagnose or claim a fixed symbolic meaning.")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }

            VStack(alignment: .leading, spacing: 13) {
                TextField("Short title (optional)", text: $dreamTitle)
                    .padding(11)
                    .background(palette.background)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                TextEditor(text: $dreamText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 180)
                    .padding(10)
                    .background(palette.background)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                Button {
                    saveDream()
                } label: {
                    Label("Save privately", systemImage: "lock.fill")
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .buttonStyle(.borderedProminent)
                .disabled(dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Text("Stored on this device with iOS complete file protection. Dreams are never posted to Community.")
                    .font(.system(size: 9))
                    .foregroundStyle(palette.secondaryText)
            }
            .padding(18)
            .withinSurface()

            if !dreams.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Eyebrow(text: "Recent dreams")
                        .padding(.bottom, 10)
                    ForEach(dreams.sorted { $0.date > $1.date }) { dream in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(dream.title)
                                        .font(.headline)
                                    Text(dream.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(palette.secondaryText)
                                }
                                Spacer()
                                Button(role: .destructive) { deleteDream(dream.id) } label: {
                                    Image(systemName: "trash")
                                }
                            }
                            Text(dream.text)
                                .font(.subheadline)
                                .foregroundStyle(palette.secondaryText)
                                .lineLimit(5)
                        }
                        .padding(.vertical, 13)
                        Divider().overlay(palette.line)
                    }
                }
            }
        }
    }

    private var lastSevenDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }

    private func entry(on day: Date) -> SleepEntry? {
        sleepEntries.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    private func score(for entry: SleepEntry) -> Int {
        let hours = entry.durationHours
        let durationScore: Int
        switch hours {
        case 7...9: durationScore = 60
        case 6.5..<7, 9..<9.5: durationScore = 50
        case 6..<6.5, 9.5..<10: durationScore = 40
        case 5..<6, 10..<11: durationScore = 25
        default: durationScore = 10
        }
        return min(100, durationScore + entry.refreshed * 5 + consistencyPoints)
    }

    private var consistencyPoints: Int {
        let recent = recentEntries
        guard recent.count >= 2 else { return 8 }
        let minutes = recent.map { entry -> Double in
            let components = Calendar.current.dateComponents([.hour, .minute], from: entry.bedtime)
            var value = Double((components.hour ?? 0) * 60 + (components.minute ?? 0))
            if value < 12 * 60 { value += 24 * 60 }
            return value
        }
        let average = minutes.reduce(0, +) / Double(minutes.count)
        let deviation = minutes.map { abs($0 - average) }.reduce(0, +) / Double(minutes.count)
        switch deviation {
        case ...30: return 15
        case ...60: return 10
        case ...120: return 5
        default: return 0
        }
    }

    private var recentEntries: [SleepEntry] {
        sleepEntries.filter { entry in
            guard let earliest = lastSevenDays.first else { return false }
            return entry.date >= earliest
        }
    }

    private var weeklyScore: Int {
        guard !recentEntries.isEmpty else { return 0 }
        return recentEntries.map(score).reduce(0, +) / recentEntries.count
    }

    private var averageHours: Double {
        guard !recentEntries.isEmpty else { return 0 }
        return recentEntries.map(\.durationHours).reduce(0, +) / Double(recentEntries.count)
    }

    private var averageRefreshed: Double {
        guard !recentEntries.isEmpty else { return 0 }
        return Double(recentEntries.map(\.refreshed).reduce(0, +)) / Double(recentEntries.count)
    }

    private var sleepRecommendation: String {
        guard !recentEntries.isEmpty else {
            return "Log a few mornings before drawing conclusions. Timing, duration, and restoration become more useful as a pattern."
        }
        if averageRefreshed <= 2 && recentEntries.count >= 3 {
            return "You are often waking unrefreshed. Protect enough sleep opportunity, and consider professional assessment if this persists, especially with loud snoring, gasping, headaches, or unsafe daytime sleepiness."
        }
        if averageHours < 7 {
            return "The current average is below seven hours. Try moving the wind-down earlier in a realistic step while keeping wake time steady. Do not drive when dangerously sleepy."
        }
        if averageHours > 9.5 && averageRefreshed < 3.5 {
            return "Long sleep is not automatically restorative. If extended, unrefreshing sleep persists, discuss it with a qualified clinician instead of only adding more time in bed."
        }
        if consistencyPoints <= 5 {
            return "Duration is only part of the pattern. A steadier wake time may help anchor the week; shift work and caregiving may require a more individualized strategy."
        }
        return "Your recent duration and timing are fairly steady. Keep observing how daytime energy, caffeine, alcohol, stress, and symptoms relate to the pattern."
    }

    private var guidePrompt: String {
        "My last \(recentEntries.count) sleep logs averaged \(averageHours.formatted(.number.precision(.fractionLength(1)))) hours and \(averageRefreshed.formatted(.number.precision(.fractionLength(1)))) out of 5 refreshed, with an app wellness score of \(weeklyScore). Help me choose one evidence-aware next step without diagnosing me."
    }

    private func saveSleepEntry() {
        let today = Calendar.current.startOfDay(for: Date())
        let newEntry = SleepEntry(id: UUID(), date: today, bedtime: bedtime, wakeTime: wakeTime, refreshed: refreshed)
        sleepEntries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: today) }
        sleepEntries.append(newEntry)
        sleepEntries.sort { $0.date > $1.date }
        Task { try? await PrivateStore.shared.saveSleep(sleepEntries) }
    }

    private func saveDream() {
        let clean = dreamText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        let title = dreamTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        dreams.append(DreamEntry(id: UUID(), date: Date(), title: title.isEmpty ? "Untitled dream" : title, text: clean))
        dreamTitle = ""
        dreamText = ""
        Task { try? await PrivateStore.shared.saveDreams(dreams) }
    }

    private func deleteDream(_ id: UUID) {
        dreams.removeAll { $0.id == id }
        Task { try? await PrivateStore.shared.saveDreams(dreams) }
    }

    private func loadPrivateData() async {
        sleepEntries = await PrivateStore.shared.loadSleep()
        dreams = await PrivateStore.shared.loadDreams()
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
