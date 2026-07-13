import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Eyebrow(text: "Practice")
                        Text("Settle first. Then choose.")
                            .font(.system(size: 35, weight: .medium, design: .serif))
                        Text("Comfortable breathing, guided meditation, contemplative practice, and gentle movement.")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryText)
                    }

                    NavigationLink(destination: BreathingView()) {
                        HStack(spacing: 15) {
                            Image(systemName: "wind")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(palette.accentSoft)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 5) {
                                Eyebrow(text: "Breathing studio")
                                Text("Four evidence-aware patterns")
                                    .font(.system(.title3, design: .serif))
                                Text("Start with the longer exhale. Never force air or hold through discomfort.")
                                    .font(.caption)
                                    .foregroundStyle(palette.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(18)
                        .withinSurface(emphasized: app.theme == .spiritual)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 12) {
                        Eyebrow(text: "Guided meditations")
                        ForEach(SampleContent.meditations) { preset in
                            NavigationLink(destination: MeditationSessionView(preset: preset)) {
                                HStack(spacing: 14) {
                                    Image(systemName: preset.symbol)
                                        .frame(width: 42, height: 42)
                                        .overlay(Circle().stroke(palette.line))
                                        .foregroundStyle(palette.accent)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.title)
                                            .font(.headline)
                                        Text("\(preset.purpose) · \(preset.duration) min")
                                            .font(.caption)
                                            .foregroundStyle(palette.secondaryText)
                                    }
                                    Spacer()
                                    Image(systemName: "play.fill")
                                        .font(.caption)
                                }
                                .padding(16)
                                .withinSurface()
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    NavigationLink(destination: YogaView()) {
                        HStack(spacing: 15) {
                            Image(systemName: "figure.yoga")
                                .font(.title2)
                                .foregroundStyle(palette.accent)
                            VStack(alignment: .leading, spacing: 5) {
                                Eyebrow(text: "Gentle yoga")
                                Text("Posture, breath, attention")
                                    .font(.system(.title3, design: .serif))
                                Text("Four illustrated foundations with real tutorials and safety notes.")
                                    .font(.caption)
                                    .foregroundStyle(palette.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 18)
                        .overlay(alignment: .top) { Divider().overlay(palette.line) }
                        .overlay(alignment: .bottom) { Divider().overlay(palette.line) }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 17)
                .padding(.top, 18)
                .padding(.bottom, 34)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.inline)
            .withinScreen()
        }
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
