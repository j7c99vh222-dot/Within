import SwiftUI

struct JournalView: View {
    @EnvironmentObject private var app: AppModel
    @State private var text = ""
    @State private var mood = 3
    @State private var entries: [JournalEntry] = []
    @State private var notice: String?
    @State private var search = ""
    @AppStorage("within.native.journal-font") private var fontChoice = "Literary"
    @AppStorage("within.native.journal-ink") private var inkChoice = "Ink"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: "Daily journal · private")
                    Text("Write until the noise becomes a sentence.")
                        .font(.system(size: 34, weight: .medium, design: .serif))
                    Text("What is true before you edit it? What did the body notice first? What deserves to be carried differently?")
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .bottom, spacing: 14) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("WRITING VOICE").font(.system(size: 9, weight: .bold)).foregroundStyle(palette.secondaryText)
                            Picker("Writing voice", selection: $fontChoice) {
                                ForEach(["Literary", "Clear", "Typewriter", "Humanist"], id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                        }
                        Spacer()
                        HStack(spacing: 7) {
                            ForEach(["Ink", "Forest", "Ocean", "Rose", "Gold"], id: \.self) { ink in
                                Button {
                                    inkChoice = ink
                                } label: {
                                    Circle()
                                        .fill(inkColor(ink))
                                        .frame(width: 19, height: 19)
                                        .padding(4)
                                        .overlay(Circle().stroke(inkChoice == ink ? palette.text : Color.clear))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(ink) journal ink")
                            }
                        }
                    }
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 300)
                        .padding(8)
                        .background(palette.background)
                        .font(journalFont)
                        .foregroundStyle(journalInk)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                    HStack {
                        Text("How heavy or light does today feel?")
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                        Spacer()
                        Picker("Mood", selection: $mood) {
                            ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                    Button {
                        save()
                    } label: {
                        Label("Keep this page", systemImage: "lock.fill")
                            .frame(maxWidth: .infinity, minHeight: 46)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if let notice {
                        Text(notice)
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                    }
                }
                .padding(18)
                .withinSurface()

                if !entries.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Eyebrow(text: "Your living archive · \(entries.count) pages")
                            Text("Nothing is erased because you went quiet.")
                                .font(.system(.title3, design: .serif))
                        }
                        Spacer()
                    }
                    TextField("Find a sentence...", text: $search)
                        .textInputAutocapitalization(.never)
                        .padding(11)
                        .background(palette.surface)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                    ForEach(filteredEntries) { entry in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption.weight(.bold))
                                Spacer()
                                Text("Mood \(entry.mood)/5")
                                    .font(.caption2)
                                    .foregroundStyle(palette.secondaryText)
                            }
                            Text(entry.text)
                                .font(journalFont)
                                .foregroundStyle(journalInk)
                        }
                        .padding(15)
                        .withinSurface()
                    }
                }

                Label("The archive has no app-imposed expiration. Entries use iOS complete file protection and remain on this device in this native demo.", systemImage: "lock.shield")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
        .task {
            entries = await PrivateStore.shared.loadJournal()
        }
    }

    private func save() {
        let entry = JournalEntry(id: UUID(), date: Date(), text: text.trimmingCharacters(in: .whitespacesAndNewlines), mood: mood)
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        entries.append(entry)
        Task {
            do {
                try await PrivateStore.shared.saveJournal(entries)
                notice = "Saved privately on this device."
                text = ""
            } catch {
                notice = "The entry could not be saved."
            }
        }
    }

    private var filteredEntries: [JournalEntry] {
        entries
            .filter { search.isEmpty || $0.text.localizedCaseInsensitiveContains(search) }
            .sorted { $0.date > $1.date }
    }

    private var journalFont: Font {
        switch fontChoice {
        case "Clear": .body
        case "Typewriter": .system(.body, design: .monospaced)
        case "Humanist": .system(.body, design: .rounded)
        default: .system(.body, design: .serif)
        }
    }

    private var journalInk: Color { inkColor(inkChoice) }

    private func inkColor(_ ink: String) -> Color {
        if app.theme == .spiritual {
            switch ink {
            case "Forest": Color(hex: 0x9AD4B8)
            case "Ocean": Color(hex: 0x9CC8EF)
            case "Rose": Color(hex: 0xE8A9BD)
            case "Gold": Color(hex: 0xE6CF7E)
            default: Color(hex: 0xF1F5FF)
            }
        } else {
            switch ink {
            case "Forest": Color(hex: 0x356452)
            case "Ocean": Color(hex: 0x2D5574)
            case "Rose": Color(hex: 0x8F4F66)
            case "Gold": Color(hex: 0x8B682D)
            default: Color(hex: 0x26332D)
            }
        }
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
