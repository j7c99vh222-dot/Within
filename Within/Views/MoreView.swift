import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Eyebrow(text: "Your whole path")
                        Text("A clear directory for the rest of Within.")
                            .font(.system(size: 34, weight: .medium, design: .serif))
                        Text("Use this when you know where you want to go.")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryText)
                    }

                    directorySection("Daily tools") {
                        destination("Journal", "A protected daily page", "square.and.pencil", JournalView())
                        Divider().overlay(palette.line)
                        destination("Practice studio", "Breathing, guided meditation, and gentle movement", "wind", PracticeView())
                        Divider().overlay(palette.line)
                        destination("Yoga", "Illustrated foundations, tutorials, and safety notes", "figure.yoga", YogaView())
                    }

                    directorySection("Learning and support") {
                        destination("Learn", "Lessons, books, nutrition education, and daily wisdom", "rectangle.stack", LearnView())
                        Divider().overlay(palette.line)
                        destination("Community", "Small moderated rooms, friends, reports, and blocking", "person.3", CommunityView())
                        Divider().overlay(palette.line)
                        destination("Recovery", "Urge support, a safety plan, and treatment resources", "shield.lefthalf.filled", RecoveryView())
                    }

                    directorySection("Account") {
                        destination("Membership", "Trial, subscription, financial access, and referrals", "crown", MembershipView())
                        Divider().overlay(palette.line)
                        destination("Account and settings", "Profile, focus, relationship tools, companions, theme, privacy, and deletion", "gearshape", SettingsView())
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Eyebrow(text: "Human support")
                        Text("Safety, billing, privacy, accessibility, and account requests reach the public support form.")
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryText)
                        Link(destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/support")!) {
                            Label("Contact human support", systemImage: "person.crop.circle.badge.questionmark")
                                .font(.subheadline.weight(.bold))
                        }
                        Link(destination: URL(string: "https://988lifeline.org/")!) {
                            Label("Crisis support", systemImage: "heart.text.square")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(palette.danger)
                        }
                    }
                    .padding(18)
                    .withinSurface(emphasized: app.theme == .spiritual)

                    HStack(spacing: 15) {
                        Link("Privacy", destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/privacy")!)
                        Link("Terms", destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/terms")!)
                        Link("Community standards", destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/community-guidelines")!)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.secondaryText)
                }
                .padding(.horizontal, 17)
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .withinScreen()
        }
    }

    private func destination<Destination: View>(_ title: String, _ subtitle: String, _ symbol: String, _ destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .frame(width: 38, height: 38)
                    .background(palette.accentSoft)
                    .clipShape(Circle())
                    .foregroundStyle(palette.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(palette.text)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .padding(15)
        }
        .buttonStyle(.plain)
    }

    private func directorySection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: title)
            VStack(spacing: 0) {
                content()
            }
            .withinSurface()
        }
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
