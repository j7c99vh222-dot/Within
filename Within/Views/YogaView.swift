import SwiftUI

struct YogaView: View {
    struct Pose: Identifiable {
        let id: String
        let name: String
        let sanskrit: String
        let cue: String
        let safety: String
        let image: String
        let tutorial: URL
    }

    @EnvironmentObject private var app: AppModel

    private let poses = [
        Pose(id: "mountain", name: "Mountain", sanskrit: "Tadasana", cue: "Stand tall with feet grounded, knees soft, and breath easy. Notice balance without forcing stillness.", safety: "Use a wall or chair if balance is uncertain.", image: "YogaMountain", tutorial: URL(string: "https://www.yogajournal.com/collection/how-to-do-mountain-pose/")!),
        Pose(id: "child", name: "Child's pose", sanskrit: "Balasana", cue: "Kneel and fold forward comfortably, supporting the head or hips as needed. Keep breathing unrestricted.", safety: "Skip or modify for knee, hip, or pregnancy concerns.", image: "YogaChild", tutorial: URL(string: "https://www.yogajournal.com/practice/beginners/how-to/balasana/")!),
        Pose(id: "catcow", name: "Cat-cow", sanskrit: "Marjaryasana-Bitilasana", cue: "On hands and knees, move the spine gently between rounding and opening with the breath.", safety: "Keep the motion small with wrist or spine pain.", image: "YogaCatCow", tutorial: URL(string: "https://www.yogajournal.com/poses/types/backbends/cow-pose/")!),
        Pose(id: "tree", name: "Tree pose", sanskrit: "Vrksasana", cue: "Root through one standing foot, place the other foot below or above the knee, and use a steady point of focus.", safety: "Keep toes down or use a wall whenever balance is uncertain.", image: "YogaTree", tutorial: URL(string: "https://www.yogajournal.com/poses/tree-pose-2/")!)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: "Gentle yoga foundations")
                    Text("Posture, breath, attention.")
                        .font(.system(size: 34, weight: .medium, design: .serif))
                    Text("Move in a pain-free range. Seek qualified guidance for injuries, pregnancy, balance concerns, or medical conditions.")
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                }

                ForEach(poses) { pose in
                    VStack(alignment: .leading, spacing: 13) {
                        Image(pose.image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 210)
                            .frame(maxWidth: .infinity)
                            .clipped()
                        Eyebrow(text: pose.sanskrit)
                        Text(pose.name)
                            .font(.system(.title2, design: .serif))
                        Text(pose.cue)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryText)
                        Label(pose.safety, systemImage: "checkmark.shield")
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                        Link(destination: pose.tutorial) {
                            Label("Open real tutorial", systemImage: "arrow.up.right.square")
                                .font(.caption.weight(.bold))
                        }
                    }
                    .padding(16)
                    .withinSurface()
                }

                Link(destination: URL(string: "https://www.nccih.nih.gov/health/yoga-effectiveness-and-safety")!) {
                    Label("Read the NCCIH yoga safety guide", systemImage: "arrow.up.right.square")
                        .font(.caption.weight(.semibold))
                }
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Yoga")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
