import AVFoundation
import SwiftUI

@MainActor
final class SpeechGuide: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.42
        utterance.pitchMultiplier = 0.92
        utterance.volume = 0.88
        utterance.preUtteranceDelay = 0.25
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

struct MeditationSessionView: View {
    @EnvironmentObject private var app: AppModel
    let preset: MeditationPreset
    @StateObject private var ambient = AmbientPlayer()
    @StateObject private var speech = SpeechGuide()
    @State private var isRunning = false
    @State private var narrationOn = true
    @State private var cueIndex = 0
    @State private var remainingSeconds: Int

    init(preset: MeditationPreset) {
        self.preset = preset
        _remainingSeconds = State(initialValue: preset.duration * 60)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Eyebrow(text: preset.purpose)
                    Text(preset.title)
                        .font(.system(size: 34, weight: .medium, design: .serif))
                        .multilineTextAlignment(.center)
                    Text(timeText)
                        .font(.system(.title2, design: .monospaced))
                        .foregroundStyle(palette.secondaryText)
                }

                ZStack {
                    Circle()
                        .stroke(palette.line, lineWidth: 1)
                        .frame(width: 218, height: 218)
                    Circle()
                        .fill(palette.accentSoft.opacity(0.85))
                        .frame(width: isRunning ? 184 : 142, height: isRunning ? 184 : 142)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isRunning)
                    Image(systemName: preset.symbol)
                        .font(.system(size: 31, weight: .light))
                        .foregroundStyle(palette.accent)
                }

                Text(preset.cues[cueIndex])
                    .font(.system(size: 23, design: .serif))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(minHeight: 116)
                    .padding(.horizontal, 12)

                Button {
                    toggleSession()
                } label: {
                    Label(isRunning ? "Pause" : remainingSeconds < preset.duration * 60 ? "Continue" : "Begin", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("Calm device narration", systemImage: "waveform")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Toggle("Narration", isOn: $narrationOn)
                            .labelsHidden()
                    }

                    Picker("Background sound", selection: $ambient.selected) {
                        ForEach(AmbientPlayer.Sound.allCases) { sound in
                            Label(sound.title, systemImage: sound.symbol).tag(sound)
                        }
                    }

                    HStack {
                        Image(systemName: "speaker.wave.1")
                        Slider(value: $ambient.volume, in: 0...0.5)
                        Image(systemName: "speaker.wave.3")
                    }
                    .foregroundStyle(palette.secondaryText)
                }
                .padding(18)
                .withinSurface()

                VStack(alignment: .leading, spacing: 10) {
                    Eyebrow(text: "Session outline")
                    ForEach(Array(preset.cues.enumerated()), id: \.offset) { index, cue in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: index < cueIndex ? "checkmark.circle.fill" : index == cueIndex ? "circle.inset.filled" : "circle")
                                .foregroundStyle(index <= cueIndex ? palette.accent : palette.secondaryText)
                            Text(cue)
                                .font(.caption)
                                .foregroundStyle(index == cueIndex ? palette.text : palette.secondaryText)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .withinSurface()

                Text("Stop if breathing becomes uncomfortable, dizzy, or distressing. Meditation is not emergency or medical care.")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Meditation")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
        .task(id: isRunning) {
            guard isRunning else { return }
            while isRunning && remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, isRunning else { return }
                remainingSeconds -= 1
                updateCueIfNeeded()
            }
            if remainingSeconds == 0 {
                finish()
            }
        }
        .onDisappear { finish(reset: false) }
        .onChange(of: narrationOn) { _, enabled in
            if enabled && isRunning { speech.speak(preset.cues[cueIndex]) }
            if !enabled { speech.stop() }
        }
        .onChange(of: ambient.selected) { _, _ in
            if isRunning { ambient.play() }
        }
    }

    private var timeText: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    private func toggleSession() {
        isRunning.toggle()
        if isRunning {
            ambient.play()
            if narrationOn { speech.speak(preset.cues[cueIndex]) }
        } else {
            ambient.stop()
            speech.stop()
        }
    }

    private func updateCueIfNeeded() {
        let total = max(1, preset.duration * 60)
        let elapsed = total - remainingSeconds
        let next = min(preset.cues.count - 1, elapsed * preset.cues.count / total)
        guard next != cueIndex else { return }
        cueIndex = next
        if narrationOn { speech.speak(preset.cues[cueIndex]) }
    }

    private func finish(reset: Bool = true) {
        isRunning = false
        ambient.stop()
        speech.stop()
        if reset && remainingSeconds == 0 {
            remainingSeconds = preset.duration * 60
            cueIndex = 0
        }
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
