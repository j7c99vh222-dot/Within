import SwiftUI

struct BookReaderView: View {
    @EnvironmentObject private var app: AppModel
    let book: WithinBook
    @State private var lessonIndex = 0
    @State private var showOverview = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                bookHeader

                if showOverview {
                    overview
                } else {
                    lesson
                }
            }
            .padding(.horizontal, 17)
            .padding(.bottom, 34)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
    }

    private var bookHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 17) {
                Image(systemName: book.symbol)
                    .font(.largeTitle)
                    .frame(width: 88, height: 116)
                    .background(palette.accentSoft)
                    .foregroundStyle(palette.accent)
                VStack(alignment: .leading, spacing: 7) {
                    Eyebrow(text: "\(book.category) · public domain")
                    Text(book.title)
                        .font(.system(size: 31, weight: .medium, design: .serif))
                    Text("\(book.author) · \(book.year)")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                    Link(destination: book.sourceURL) {
                        Label("Open full public text", systemImage: "arrow.up.right.square")
                            .font(.caption.weight(.semibold))
                    }
                    Text("U.S. public-domain edition; local laws may differ.")
                        .font(.caption2)
                        .foregroundStyle(palette.secondaryText)
                }
            }

            Picker("Reader mode", selection: $showOverview) {
                Text("Overview").tag(true)
                Text("Lesson deck").tag(false)
            }
            .pickerStyle(.segmented)
        }
        .padding(.top, 14)
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 18) {
            Eyebrow(text: "The central argument")
            Text(book.overview)
                .font(.system(size: 21, design: .serif))
                .lineSpacing(6)
            Divider().overlay(palette.line)
            Text("What this course includes")
                .font(.headline)
            ForEach(Array(book.lessons.enumerated()), id: \.offset) { index, lesson in
                Button {
                    lessonIndex = index
                    showOverview = false
                } label: {
                    HStack {
                        Text(String(format: "%02d", index + 1))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(palette.accent)
                        Text(lesson.title)
                            .foregroundStyle(palette.text)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .frame(minHeight: 46)
                }
                .buttonStyle(.plain)
                Divider().overlay(palette.line)
            }
        }
        .padding(21)
        .withinSurface()
    }

    private var lesson: some View {
        let current = book.lessons[lessonIndex]
        return VStack(alignment: .leading, spacing: 24) {
            HStack {
                Eyebrow(text: "Lesson \(lessonIndex + 1) of \(book.lessons.count)")
                Spacer()
                Text(book.category)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
            Text(current.title)
                .font(.system(size: 34, weight: .medium, design: .serif))
            Text(current.summary)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(palette.secondaryText)
                .lineSpacing(6)
            VStack(alignment: .leading, spacing: 9) {
                Eyebrow(text: "From the text")
                Text("“\(current.quotation)”")
                    .font(.system(size: 24, design: .serif).italic())
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x071A38))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 8) {
                Eyebrow(text: "How to read it")
                Text(current.interpretation)
                    .lineSpacing(5)
            }
            VStack(alignment: .leading, spacing: 8) {
                Eyebrow(text: "Practice")
                Text(current.practice)
                    .font(.headline)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(palette.accentSoft)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            NavigationLink(destination: GuideView(initialPrompt: "Help me apply \(current.title) from \(book.title) to my life.")) {
                Label("Ask the guide about this lesson", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
            }
            Divider().overlay(palette.line)
            HStack {
                Button {
                    lessonIndex = max(0, lessonIndex - 1)
                } label: {
                    Label("Previous", systemImage: "arrow.left")
                }
                .disabled(lessonIndex == 0)
                Spacer()
                Button {
                    lessonIndex = min(book.lessons.count - 1, lessonIndex + 1)
                } label: {
                    Label("Next", systemImage: "arrow.right")
                }
                .disabled(lessonIndex == book.lessons.count - 1)
            }
        }
        .padding(21)
        .withinSurface()
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
