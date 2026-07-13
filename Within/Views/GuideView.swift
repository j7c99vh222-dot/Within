import SwiftUI

struct GuideView: View {
    @EnvironmentObject private var app: AppModel
    @State private var draft: String

    init(initialPrompt: String = "") {
        _draft = State(initialValue: initialPrompt)
    }

    var body: some View {
        VStack(spacing: 0) {
            crisisBar
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        intro
                        ForEach(app.guideMessages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }
                        if app.guideIsReplying {
                            HStack {
                                ProgressView()
                                Text("\(app.companion.name) is reading the moment carefully...")
                                    .font(.caption)
                                    .foregroundStyle(palette.secondaryText)
                                Spacer()
                            }
                            .padding(14)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: app.guideMessages.count) { _, _ in
                    if let id = app.guideMessages.last?.id {
                        withAnimation { proxy.scrollTo(id, anchor: .bottom) }
                    }
                }
            }
            quickPrompts
            composer
        }
        .navigationTitle(app.companion.name)
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
    }

    private var crisisBar: some View {
        Link(destination: URL(string: "https://988lifeline.org/")!) {
            HStack(spacing: 9) {
                Image(systemName: "heart.text.square")
                Text("Immediate danger or thoughts of self-harm? Call emergency services or contact 988.")
                    .font(.caption.weight(.semibold))
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 48)
            .background(palette.danger.opacity(0.15))
            .foregroundStyle(palette.text)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CompanionAvatar(companion: app.companion, size: 42)
                Label("\(app.companion.name) · safety-aware support", systemImage: "checkmark.shield")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.accent)
            }
            Text("I can help make a coping step smaller, explain a lesson, or point toward support. I cannot diagnose, treat, or replace emergency care.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(15)
        .withinSurface()
    }

    private func messageBubble(_ message: GuideMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 42) }
            VStack(alignment: .leading, spacing: 6) {
                Text(message.role == .guide ? app.companion.name.uppercased() : "YOU")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(message.role == .guide ? palette.accent : palette.secondaryText)
                Text(message.text)
                    .font(.subheadline)
                    .lineSpacing(4)
            }
            .padding(14)
            .background(message.role == .user ? palette.accentSoft : palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.line))
            if message.role == .guide { Spacer(minLength: 42) }
        }
    }

    private var quickPrompts: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                prompt("I feel overwhelmed")
                prompt("I have a strong urge")
                prompt("Guide today's route")
                prompt("Help me reframe a thought")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
        }
        .scrollIndicators(.hidden)
        .background(palette.background)
    }

    private func prompt(_ text: String) -> some View {
        Button(text) { draft = text }
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
    }

    private var composer: some View {
        VStack(spacing: 7) {
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Tell \(app.companion.name) what is happening...", text: $draft, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(12)
                    .background(palette.surface)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.line))
                Button {
                    let message = draft
                    draft = ""
                    Task { await app.sendGuideMessage(message) }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || app.guideIsReplying)
            }
            Text("AI credentials belong on the secure server, never in the iPhone app.")
                .font(.system(size: 9))
                .foregroundStyle(palette.secondaryText)
        }
        .padding(12)
        .background(palette.background)
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
