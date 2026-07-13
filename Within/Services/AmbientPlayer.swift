import AVFoundation
import Foundation

@MainActor
final class AmbientPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    enum Sound: String, CaseIterable, Identifiable {
        case none
        case tone432
        case rain
        case ocean
        case birds
        case classical
        case whiteNoise
        case brownNoise
        case forestRain
        case nightCrickets
        case softWind

        var id: String { rawValue }
        var title: String {
            switch self {
            case .none: "Silence"
            case .tone432: "432 Hz tone"
            case .rain: "Gentle rain"
            case .ocean: "Ocean breath"
            case .birds: "Morning birds"
            case .classical: "Classical arpeggio"
            case .whiteNoise: "Soft white noise"
            case .brownNoise: "Deep brown noise"
            case .forestRain: "Rain in a forest"
            case .nightCrickets: "Night crickets"
            case .softWind: "Soft wind"
            }
        }
        var fileName: String? {
            switch self {
            case .none: nil
            case .tone432: "tone-432"
            case .rain: "gentle-rain"
            case .ocean: "ocean-breath"
            case .birds: "morning-birds"
            case .classical: "classical-arpeggio"
            case .whiteNoise: "white-noise"
            case .brownNoise: "brown-noise"
            case .forestRain: "forest-rain"
            case .nightCrickets: "night-crickets"
            case .softWind: "soft-wind"
            }
        }
        var symbol: String {
            switch self {
            case .none: "speaker.slash"
            case .tone432: "waveform"
            case .rain: "cloud.rain"
            case .ocean: "water.waves"
            case .birds: "bird"
            case .classical: "music.note"
            case .whiteNoise: "waveform"
            case .brownNoise: "waveform.path"
            case .forestRain: "tree"
            case .nightCrickets: "moon.stars"
            case .softWind: "wind"
            }
        }
    }

    @Published var selected: Sound = .rain
    @Published var volume: Float = 0.20 {
        didSet { player?.volume = volume }
    }
    @Published private(set) var isPlaying = false

    private var player: AVAudioPlayer?
    private var stopTask: Task<Void, Never>?

    func play() {
        guard let name = selected.fileName,
              let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            stop()
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = volume
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
        } catch {
            stop()
        }
    }

    func stop() {
        stopTask?.cancel()
        stopTask = nil
        player?.stop()
        player = nil
        isPlaying = false
    }

    func stop(afterMinutes minutes: Int?) {
        stopTask?.cancel()
        guard let minutes, minutes > 0 else {
            stopTask = nil
            return
        }
        stopTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(minutes * 60))
            guard !Task.isCancelled else { return }
            self?.stop()
        }
    }
}
