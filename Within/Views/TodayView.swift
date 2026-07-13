import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var app: AppModel
    @State private var guideDraft = ""
    @State private var partnerLinkDraft = ""

    private let cardColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    statusStrip
                    if app.relationshipFeatureEnabled {
                        relationshipPanel
                    }
                    dailyCheckInPanel
                    recommendedPanel
                    guidePanel
                    continueJourneyPanel
                    healthPanel
                    mindLibraryPanel
                    goalsPanel
                    communityPanel
                    insightPanel
                    evidenceFooter
                }
                .padding(.horizontal, 17)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .withinScreen()
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { app.refreshDailyState() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                NavigationLink(destination: SettingsView()) {
                    ZStack(alignment: .bottomTrailing) {
                        CompanionAvatar(companion: app.companion, size: 42, lineWidth: 1.5)
                        Image(systemName: "person.fill")
                            .font(.system(size: 9, weight: .bold))
                            .frame(width: 17, height: 17)
                            .background(palette.surface)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(palette.line, lineWidth: 0.75))
                    }
                }
                .accessibilityLabel("Open account")
                Spacer()
                WithinLogo(compact: true)
            }
            Eyebrow(text: "\(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())) · edition \(String(format: "%05d", app.dailyEditionNumber))")
            VStack(alignment: .leading, spacing: 5) {
                Text("Good \(greeting), \(app.displayName).")
                    .font(.system(size: 37, weight: .medium, design: .serif))
                Text("You deserve peace today.")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(palette.secondaryText)
            }
            Text(app.dailyRitualTitle + ". " + app.dailyAction)
                .font(.subheadline)
                .foregroundStyle(palette.secondaryText)
                .lineSpacing(4)
        }
    }

    private var statusStrip: some View {
        LazyVGrid(columns: cardColumns, spacing: 10) {
            statusTile(
                symbol: app.dailyFeeling.symbol,
                title: "Mood",
                value: app.mood == 0 ? app.dailyFeeling.title : "\(app.dailyFeeling.title) \(app.mood)/5",
                caption: "Daily check-in"
            )

            Button {
                app.setWaterMilestone(app.waterMilestones == 4 ? 0 : app.waterMilestones + 1)
            } label: {
                statusTile(
                    symbol: "drop",
                    title: "Water",
                    value: app.waterConsumedLiters.formatted(.number.precision(.fractionLength(1...2))) + " L",
                    caption: "\(app.waterMilestones)/4 milestones"
                )
            }
            .buttonStyle(.plain)

            statusTile(
                symbol: "flame",
                title: "Streak",
                value: "12 days",
                caption: "Returning"
            )

            statusTile(
                symbol: app.focus.symbol,
                title: "Focus",
                value: app.focus.title,
                caption: "Personalized"
            )
        }
    }

    private var dailyCheckInPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                eyebrow: "Daily check-in",
                title: "What is closest to the truth today?",
                subtitle: "Your dashboard adapts to the mood and intensity you choose."
            )

            LazyVGrid(columns: cardColumns, spacing: 8) {
                ForEach(DailyFeeling.allCases) { feeling in
                    Button {
                        app.chooseFeeling(feeling)
                    } label: {
                        HStack(spacing: 9) {
                            Image(systemName: feeling.symbol)
                                .frame(width: 29, height: 29)
                                .background(app.dailyFeeling == feeling ? palette.accent : palette.background)
                                .foregroundStyle(app.dailyFeeling == feeling ? Color.white : palette.secondaryText)
                                .clipShape(Circle())
                            Text(feeling.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(palette.text)
                                .lineLimit(2)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .padding(.horizontal, 9)
                        .background(app.dailyFeeling == feeling ? palette.accentSoft : palette.background)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(app.dailyFeeling == feeling ? palette.accent : palette.line))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("How strongly is it here?")
                    .font(.caption.weight(.semibold))
                HStack(spacing: 7) {
                    ForEach(1...5, id: \.self) { value in
                        Button("\(value)") { app.mood = value }
                            .font(.caption.weight(.bold))
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .background(app.mood == value ? palette.accent : palette.background)
                            .foregroundStyle(app.mood == value ? Color.white : palette.secondaryText)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(app.mood == value ? palette.accent : palette.line))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                Text(app.mood == 0 ? "Choose only if a number feels useful." : ["At the edge", "Present", "Taking space", "Strong", "Hard to hold alone"][app.mood - 1])
                    .font(.caption2)
                    .foregroundStyle(palette.secondaryText)
            }
        }
        .padding(20)
        .withinSurface()
    }

    private var relationshipPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "heart.circle.fill")
                    .font(.title2)
                    .foregroundStyle(palette.accent)
                VStack(alignment: .leading, spacing: 5) {
                    Eyebrow(text: "Relationship")
                    Text(app.relationship.displayName)
                        .font(.system(.title3, design: .serif))
                    Text(app.relationshipAnniversarySummary)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.secondaryText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(nextAnniversaryDay)
                        .font(.system(.title2, design: .serif))
                    Text("next date")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(palette.secondaryText)
                }
            }

            VStack(alignment: .leading, spacing: 9) {
                Label(app.dailyRelationshipPrompt.title, systemImage: "quote.bubble")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.accent)
                Text(app.dailyRelationshipPrompt.body)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryText)
                    .lineSpacing(4)
            }
            .padding(14)
            .background(palette.background)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))

            if app.relationship.hasLinkedPartner {
                Button {
                    app.sendThinkingOfYouPing()
                } label: {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Send a thinking-of-you ping")
                                .font(.subheadline.weight(.bold))
                            Text(pingStatusText)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.72))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: 0x9C415E))
            } else {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Link partner account")
                        .font(.caption.weight(.bold))
                    HStack(spacing: 8) {
                        TextField("Username or email", text: $partnerLinkDraft)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 11)
                            .frame(minHeight: 42)
                            .background(palette.background)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                        Button {
                            app.updatePartnerLink(partnerLinkDraft)
                            partnerLinkDraft = ""
                        } label: {
                            Image(systemName: "link")
                                .frame(width: 42, height: 42)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(partnerLinkDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    Text("The link is saved locally in this build. Production pings need server account matching and push notifications.")
                        .font(.caption2)
                        .foregroundStyle(palette.secondaryText)
                }
            }
        }
        .padding(20)
        .withinSurface(emphasized: app.theme == .spiritual)
        .onAppear {
            partnerLinkDraft = app.relationship.linkedPartnerHandle
        }
    }

    private var recommendedPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                eyebrow: "Recommended for you",
                title: recommendationTitle,
                subtitle: recommendationSubtitle
            )

            NavigationLink(destination: MeditationSessionView(preset: meditationForFocus)) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Label("Start here", systemImage: meditationForFocus.symbol)
                            .font(.caption.weight(.bold))
                        Spacer()
                        Text("\(meditationForFocus.duration) min")
                            .font(.caption.weight(.semibold))
                    }
                    Text(meditationForFocus.title)
                        .font(.system(size: 28, weight: .medium, design: .serif))
                    Text(meditationForFocus.purpose + ".")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.74))
                    Label("Begin practice", systemImage: "play.fill")
                        .font(.subheadline.weight(.bold))
                        .padding(.horizontal, 14)
                        .frame(height: 42)
                        .background(Color.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .frame(maxWidth: .infinity, minHeight: 218, alignment: .leading)
                .padding(22)
                .background(Color(hex: 0x0A2449))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            LazyVGrid(columns: cardColumns, spacing: 10) {
                featureCard(
                    title: "Breathe",
                    subtitle: "A shorter exhale-based reset.",
                    symbol: "wind",
                    destination: BreathingView()
                )
                featureCard(
                    title: "Journal",
                    subtitle: "Put the honest version somewhere safe.",
                    symbol: "square.and.pencil",
                    destination: JournalView()
                )
                featureCard(
                    title: "AI coach",
                    subtitle: "Talk through one safe next step.",
                    symbol: "sparkles",
                    destination: GuideView()
                )
                if app.dailyFeeling == .craving || app.focus == .addiction {
                    featureCard(
                        title: "Urge support",
                        subtitle: "Create distance before acting.",
                        symbol: "shield.lefthalf.filled",
                        destination: RecoveryView()
                    )
                } else {
                    featureCard(
                        title: "Community",
                        subtitle: "Step into a moderated room.",
                        symbol: "person.3",
                        destination: CommunityView()
                    )
                }
            }
        }
    }

    private var guidePanel: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                NavigationLink(destination: GuideView()) {
                    CompanionAvatar(companion: app.companion, size: 40)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Eyebrow(text: "\(app.companion.name) · your Within guide")
                    Text("Put language around what is happening.")
                        .font(.system(.title3, design: .serif))
                }
                Spacer()
                NavigationLink(destination: GuideView()) {
                    Image(systemName: "arrow.right")
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(palette.line))
                }
            }
            Text(app.guideMessages.last?.text ?? "I am here when you are ready.")
                .font(.subheadline)
                .foregroundStyle(palette.secondaryText)
                .lineSpacing(4)
            HStack(spacing: 0) {
                TextField("Tell \(app.companion.name) the honest version...", text: $guideDraft, axis: .vertical)
                    .lineLimit(1...3)
                    .padding(.horizontal, 13)
                    .frame(minHeight: 46)
                Button {
                    let message = guideDraft
                    guideDraft = ""
                    Task { await app.sendGuideMessage(message) }
                } label: {
                    Group {
                        if app.guideIsReplying { ProgressView() }
                        else { Image(systemName: "arrow.up") }
                    }
                    .frame(width: 44, height: 44)
                }
                .disabled(guideDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || app.guideIsReplying)
            }
            .background(palette.background)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
        }
        .padding(20)
        .withinSurface(emphasized: app.theme == .spiritual)
    }

    private var continueJourneyPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                eyebrow: "Continue journey",
                title: "Return without beginning from zero.",
                subtitle: "The main tools are all reachable from here."
            )

            LazyVGrid(columns: cardColumns, spacing: 10) {
                featureCard(
                    title: "Practice studio",
                    subtitle: "Breathing, meditation, and movement.",
                    symbol: "wind",
                    destination: PracticeView()
                )
                featureCard(
                    title: "Sleep",
                    subtitle: "Log rest or choose a sleep sound.",
                    symbol: "moon.stars",
                    destination: SleepView()
                )
                featureCard(
                    title: "Yoga",
                    subtitle: "Gentle postures with safety notes.",
                    symbol: "figure.yoga",
                    destination: YogaView()
                )
                featureCard(
                    title: "Journal",
                    subtitle: "Continue writing today.",
                    symbol: "book.closed",
                    destination: JournalView()
                )
            }
        }
    }

    private var healthPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                eyebrow: "Health",
                title: "Food, water, recovery, and access.",
                subtitle: "Body basics stay close to the mental health tools."
            )

            LazyVGrid(columns: cardColumns, spacing: 10) {
                featureCard(
                    title: "Nutrition",
                    subtitle: "Food library, calories, macros, and fiber.",
                    symbol: "leaf",
                    destination: NutritionView()
                )
                hydrationCard
                featureCard(
                    title: "Recovery",
                    subtitle: "Urge support and treatment resources.",
                    symbol: "shield.lefthalf.filled",
                    destination: RecoveryView()
                )
                featureCard(
                    title: "Membership",
                    subtitle: "Trial, subscription, and financial access.",
                    symbol: "crown",
                    destination: MembershipView()
                )
            }
        }
    }

    private var mindLibraryPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                eyebrow: "Mind library",
                title: "Lessons, books, and daily wisdom.",
                subtitle: "Learn when you have enough room to go deeper."
            )

            LazyVGrid(columns: cardColumns, spacing: 10) {
                featureCard(
                    title: "Learning path",
                    subtitle: "Today's evidence-linked lesson.",
                    symbol: app.focus.symbol,
                    destination: LearnView()
                )
                featureCard(
                    title: "Books",
                    subtitle: "\(SampleContent.books.count) guided readers.",
                    symbol: "books.vertical",
                    destination: BookReaderView(book: SampleContent.books[0])
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Label("Daily reflection", systemImage: "quote.bubble")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.accent)
                Text("\"\(app.dailyQuote.text)\"")
                    .font(.system(.title3, design: .serif))
                Text("\(app.dailyQuote.attribution) · \(app.dailyQuote.work)")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .padding(18)
            .withinSurface()
        }
    }

    private var goalsPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "Goals")
                    Text("Four promises small enough to keep.")
                        .font(.system(.title3, design: .serif))
                }
                Spacer()
                Text("\(app.completedTaskCount)/\(app.dailyTasks.count)")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(palette.accentSoft)
                    .clipShape(Capsule())
            }

            ForEach(Array(app.dailyTasks.enumerated()), id: \.offset) { index, task in
                Button {
                    app.toggleTask(index)
                } label: {
                    HStack(spacing: 11) {
                        Image(systemName: app.completedTasks[index] ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(app.completedTasks[index] ? palette.accent : palette.secondaryText)
                        Text(task)
                            .strikethrough(app.completedTasks[index])
                            .foregroundStyle(app.completedTasks[index] ? palette.secondaryText : palette.text)
                        Spacer()
                    }
                    .frame(minHeight: 38)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .withinSurface()
    }

    private var communityPanel: some View {
        NavigationLink(destination: CommunityView()) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "person.3")
                    .font(.title3)
                    .frame(width: 42, height: 42)
                    .background(palette.accentSoft)
                    .clipShape(Circle())
                    .foregroundStyle(palette.accent)
                VStack(alignment: .leading, spacing: 6) {
                    Eyebrow(text: "Community")
                    Text("Newest room: Steady Ground")
                        .font(.system(.title3, design: .serif))
                    Text("Small moderated circles, peer support, reporting, and blocking are one tap away from Home.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .padding(18)
            .withinSurface(emphasized: app.theme == .spiritual)
        }
        .buttonStyle(.plain)
    }

    private var hydrationCard: some View {
        Button {
            app.setWaterMilestone(app.waterMilestones == 4 ? 0 : app.waterMilestones + 1)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "drop")
                        .font(.title3)
                        .foregroundStyle(palette.accent)
                    Spacer()
                    Text("\(app.waterMilestones)/4")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(palette.secondaryText)
                }
                Text("Water")
                    .font(.headline)
                    .foregroundStyle(palette.text)
                Text("\(app.waterConsumedLiters, format: .number.precision(.fractionLength(1...2))) of \(app.waterGoalLiters, format: .number.precision(.fractionLength(1...2))) L")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                ProgressView(value: Double(app.waterMilestones), total: 4)
                    .tint(palette.accent)
            }
            .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
            .padding(15)
            .withinSurface()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Log water milestone")
    }

    private var insightPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 18) {
                Eyebrow(text: "Today's reflection")
                Text("\"\(app.dailyQuote.text)\"")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                Text("\(app.dailyQuote.attribution) · \(app.dailyQuote.work)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.66))
                if let source = app.dailyQuote.source {
                    Link("Open public-domain source", destination: source)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(21)
            .background(Color(hex: 0x071A38))
            .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Label("A sourced health fact", systemImage: "lightbulb")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.accent)
                Text(app.dailyFact)
                    .font(.subheadline)
                    .lineSpacing(4)
                Link("Review health evidence", destination: URL(string: "https://www.nih.gov/health-information")!)
                    .font(.caption.weight(.semibold))
            }
            .padding(21)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.line))
    }

    private var evidenceFooter: some View {
        Label {
            Text("Practices are educational and do not replace medical or emergency care.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        } icon: {
            Image(systemName: "checkmark.shield")
                .foregroundStyle(palette.accent)
        }
        .padding(.vertical, 8)
    }

    private func sectionHeader(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Eyebrow(text: eyebrow)
            Text(title)
                .font(.system(.title3, design: .serif))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
                .lineSpacing(3)
        }
    }

    private func statusTile(symbol: String, title: String, value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: symbol)
                    .foregroundStyle(palette.accent)
                Spacer()
            }
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(palette.secondaryText)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.text)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(caption)
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(14)
        .withinSurface()
    }

    private func featureCard<Destination: View>(title: String, subtitle: String, symbol: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: symbol)
                        .font(.title3)
                        .foregroundStyle(palette.accent)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
                Text(title)
                    .font(.headline)
                    .foregroundStyle(palette.text)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
            .padding(15)
            .withinSurface()
        }
        .buttonStyle(.plain)
    }

    private var recommendationTitle: String {
        if app.mood >= 4 { return "Keep the next step small." }
        switch app.dailyFeeling {
        case .anxious: return "Settle the body before solving the thought."
        case .low: return "Make one gentle point of contact."
        case .overwhelmed: return "Put the day down and pick up one hour."
        case .craving: return "Protect the space between urge and action."
        case .disconnected: return "Come back into relationship with the day."
        case .steady: return "Use steadiness while it is here."
        case .hopeful: return "Give hope something practical to hold."
        }
    }

    private var recommendationSubtitle: String {
        "Based on \(app.dailyFeeling.title.lowercased()) and your \(app.focus.title.lowercased()) focus."
    }

    private var nextAnniversaryDay: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: app.relationship.startedOn)
        var components = calendar.dateComponents([.month, .day], from: start)
        components.year = calendar.component(.year, from: today)

        guard var next = calendar.date(from: components) else {
            return start.formatted(.dateTime.month(.abbreviated).day())
        }

        if next < today {
            components.year = (components.year ?? calendar.component(.year, from: today)) + 1
            next = calendar.date(from: components) ?? next
        }

        return next.formatted(.dateTime.month(.abbreviated).day())
    }

    private var pingStatusText: String {
        guard let sentAt = app.relationship.lastThinkingOfYouSentAt else {
            return "Sends to \(app.relationship.linkedPartnerHandle) when push linking is live."
        }

        return "Last tapped \(sentAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))."
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 12 ? "morning" : hour < 18 ? "afternoon" : "evening"
    }

    private var meditationForFocus: MeditationPreset {
        switch app.focus {
        case .anxiety: SampleContent.meditations[0]
        case .addiction: SampleContent.meditations[2]
        default: SampleContent.meditations[3]
        }
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
