import SwiftUI

struct BreathingView: View {
    struct Method: Identifiable {
        let id: String
        let title: String
        let use: String
        let phases: [(label: String, seconds: Int)]
    }

    @EnvironmentObject private var app: AppModel
    @StateObject private var ambient = AmbientPlayer()
    @State private var selected = 0
    @State private var phaseIndex = 0
    @State private var phaseRemaining = 4
    @State private var isRunning = false

    private let methods = [
        Method(id: "exhale", title: "Longer exhale", use: "General settling", phases: [("Breathe in gently", 4), ("Breathe out slowly", 6)]),
        Method(id: "resonance", title: "Easy rhythm", use: "Steady attention", phases: [("Breathe in", 5), ("Breathe out", 5)]),
        Method(id: "box", title: "Box breathing", use: "Focus; skip holds if uncomfortable", phases: [("Breathe in", 4), ("Pause softly", 4), ("Breathe out", 4), ("Rest softly", 4)]),
        Method(id: "humming", title: "Humming exhale", use: "Yoga-inspired settling", phases: [("Breathe in gently", 4), ("Hum softly out", 6)])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Eyebrow(text: methods[selected].use)
                    Text(methods[selected].title)
                        .font(.system(size: 35, weight: .medium, design: .serif))
                    Text("Choose ease over depth. Normal-sized breaths are enough.")
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                        .multilineTextAlignment(.center)
                }

                Picker("Breathing method", selection: $selected) {
                    ForEach(methods.indices, id: \.self) { index in
                        Text(methods[index].title).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selected) { _, _ in reset() }

                ZStack {
                    Circle()
                        .stroke(palette.line, lineWidth: 1)
                        .frame(width: 240, height: 240)
                    Circle()
                        .fill(palette.accentSoft)
                        .frame(width: circleSize, height: circleSize)
                        .animation(.easeInOut(duration: Double(currentPhase.seconds)), value: phaseIndex)
                    VStack(spacing: 8) {
                        Text(currentPhase.label)
                            .font(.system(.title3, design: .serif))
                        Text("\(phaseRemaining)")
                            .font(.system(.largeTitle, design: .monospaced))
                    }
                }

                Button {
                    isRunning.toggle()
                    if isRunning { ambient.play() } else { ambient.stop() }
                } label: {
                    Label(isRunning ? "Pause" : "Begin", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)

                VStack(alignment: .leading, spacing: 13) {
                    Text("Background")
                        .font(.subheadline.weight(.semibold))
                    Picker("Background sound", selection: $ambient.selected) {
                        ForEach(AmbientPlayer.Sound.allCases) { sound in
                            Label(sound.title, systemImage: sound.symbol).tag(sound)
                        }
                    }
                    HStack {
                        Image(systemName: "speaker.wave.1")
                        Slider(value: $ambient.volume, in: 0...0.5)
                    }
                    .foregroundStyle(palette.secondaryText)
                }
                .padding(18)
                .withinSurface()

                Link(destination: URL(string: "https://www.nccih.nih.gov/health/relaxation-techniques-what-you-need-to-know")!) {
                    Label("NCCIH relaxation safety", systemImage: "arrow.up.right.square")
                        .font(.caption.weight(.semibold))
                }

                Text("Stop and return to ordinary breathing if you feel dizzy, numb, panicked, or short of breath. Seek medical care for new or severe breathing symptoms.")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
        .task(id: isRunning) {
            guard isRunning else { return }
            while isRunning {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, isRunning else { return }
                if phaseRemaining > 1 {
                    phaseRemaining -= 1
                } else {
                    phaseIndex = (phaseIndex + 1) % methods[selected].phases.count
                    phaseRemaining = currentPhase.seconds
                }
            }
        }
        .onDisappear { ambient.stop() }
        .onChange(of: ambient.selected) { _, _ in
            if isRunning { ambient.play() }
        }
    }

    private var currentPhase: (label: String, seconds: Int) { methods[selected].phases[phaseIndex] }
    private var circleSize: CGFloat {
        currentPhase.label.lowercased().contains("in") ? 198 : currentPhase.label.lowercased().contains("out") || currentPhase.label.lowercased().contains("hum") ? 132 : 164
    }
    private func reset() {
        isRunning = false
        ambient.stop()
        phaseIndex = 0
        phaseRemaining = methods[selected].phases[0].seconds
    }
    private var palette: WithinPalette { .palette(for: app.theme) }
}
