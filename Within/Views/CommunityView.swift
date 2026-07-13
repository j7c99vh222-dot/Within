import SwiftUI

struct CommunityView: View {
    struct Message: Identifiable {
        let id = UUID()
        let user: String
        let text: String
        let isMentor: Bool
        var isMine = false
    }

    @EnvironmentObject private var app: AppModel
    @State private var roomName = "Steady Ground · 08"
    @State private var draft = ""
    @State private var messages = [
        Message(user: "quiet.sun", text: "I took a short walk instead of arguing with the panic. It did not fix everything, but the wave came down.", isMentor: true),
        Message(user: "day.one", text: "Today I am trying to make the next decision smaller instead of promising a whole new life.", isMentor: false),
        Message(user: "north.star", text: "That helped me too. I wrote the next safe action on paper before the urge got loud.", isMentor: true)
    ]
    @State private var moderationNotice: String?
    @State private var selectedMessage: Message?
    @State private var blockedUsers = Set<String>()
    @State private var reportSent = false

    var visibleMessages: [Message] {
        messages.filter { !blockedUsers.contains($0.user) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                safetyBanner
                roomHeader
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(visibleMessages) { message in
                            messageRow(message)
                        }
                    }
                    .padding(16)
                }
                composer
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
            .withinScreen()
            .confirmationDialog("Community safety", isPresented: Binding(get: { selectedMessage != nil }, set: { if !$0 { selectedMessage = nil } })) {
                Button("Report privately") {
                    reportSent = true
                    selectedMessage = nil
                }
                Button("Block this member", role: .destructive) {
                    if let user = selectedMessage?.user { blockedUsers.insert(user) }
                    selectedMessage = nil
                }
                Button("Cancel", role: .cancel) { selectedMessage = nil }
            } message: {
                Text("Reports enter the human review queue. Blocking hides this member immediately.")
            }
            .alert("Report received", isPresented: $reportSent) {
                Button("Done", role: .cancel) {}
            } message: {
                Text("A trained human moderator must review production reports. This demo records only the interface action.")
            }
        }
    }

    private var safetyBanner: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.shield")
                .foregroundStyle(palette.accent)
            VStack(alignment: .leading, spacing: 3) {
                Text("Filtering, reporting, blocking, and human review")
                    .font(.caption.weight(.bold))
                Text("Messages expire within 24 hours. Do not post contact details, medical instructions, threats, or encouragement of harm.")
                    .font(.system(size: 10))
                    .foregroundStyle(palette.secondaryText)
            }
        }
        .padding(13)
        .background(palette.accentSoft.opacity(0.7))
    }

    private var roomHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Eyebrow(text: "Random circle · 14 of 18")
                Text(roomName)
                    .font(.system(.title3, design: .serif))
            }
            Spacer()
            Button {
                roomName = ["Steady Ground · 08", "Small Steps · 14", "Clear Morning · 03", "Return Room · 11"].randomElement()!
            } label: {
                Image(systemName: "shuffle")
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(palette.line))
            }
            .accessibilityLabel("Join another random room")
        }
        .padding(15)
        .background(palette.surface)
        .overlay(alignment: .bottom) { Divider().overlay(palette.line) }
    }

    private func messageRow(_ message: Message) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(String(message.user.prefix(1)).uppercased())
                .font(.caption.weight(.bold))
                .frame(width: 34, height: 34)
                .background(palette.accentSoft)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(message.user)
                        .font(.caption.weight(.bold))
                    if message.isMentor {
                        Label("Peer listener", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(palette.accent)
                    }
                    Spacer()
                    if !message.isMine {
                        Button { selectedMessage = message } label: {
                            Image(systemName: "ellipsis")
                        }
                        .accessibilityLabel("Report or block \(message.user)")
                    }
                }
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryText)
                    .lineSpacing(4)
                HStack(spacing: 14) {
                    Button("Support") {}
                    Button("Add friend") {}
                }
                .font(.caption.weight(.semibold))
            }
        }
        .padding(14)
        .withinSurface()
    }

    private var composer: some View {
        VStack(spacing: 6) {
            if let moderationNotice {
                Label(moderationNotice, systemImage: "exclamationmark.shield")
                    .font(.caption)
                    .foregroundStyle(palette.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Speak from your experience...", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(11)
                    .background(palette.surface)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.line))
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.borderedProminent)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Text("Production messages must pass server filtering before publication.")
                .font(.system(size: 9))
                .foregroundStyle(palette.secondaryText)
        }
        .padding(12)
        .background(palette.background)
        .overlay(alignment: .top) { Divider().overlay(palette.line) }
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let safe = CommunityGuard.check(text) else {
            moderationNotice = "This message was paused. Rephrase it around your experience and a safe next step."
            return
        }
        moderationNotice = nil
        draft = ""
        messages.append(Message(user: app.profile.username.isEmpty ? "you" : app.profile.username, text: safe, isMentor: false, isMine: true))
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}

private enum CommunityGuard {
    static func check(_ message: String) -> String? {
        let clean = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = clean.lowercased()
        let blocked = ["kill yourself", "you should die", "how to overdose", "stop taking your medication", "starve yourself"]
        let contact = try? NSRegularExpression(pattern: "(?:\\b[0-9]{3}[-. ]?[0-9]{3}[-. ]?[0-9]{4}\\b|[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,})", options: .caseInsensitive)
        guard !blocked.contains(where: lower.contains) else { return nil }
        guard contact?.firstMatch(in: clean, range: NSRange(clean.startIndex..., in: clean)) == nil else { return nil }
        return clean.isEmpty ? nil : String(clean.prefix(700))
    }
}
