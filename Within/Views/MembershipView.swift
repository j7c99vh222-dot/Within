import SwiftUI

struct MembershipView: View {
    @EnvironmentObject private var app: AppModel
    @StateObject private var purchase = PurchaseManager()
    @State private var referralCode = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "crown")
                        .font(.largeTitle)
                        .foregroundStyle(palette.gold)
                    Eyebrow(text: "Three-day free trial")
                    Text("Support that stays within reach.")
                        .font(.system(size: 36, weight: .medium, design: .serif))
                    Text("Full learning paths, the guide, meditation library, nutrition tools, community circles, and Spiritual night.")
                        .foregroundStyle(palette.secondaryText)
                }

                VStack(alignment: .leading, spacing: 14) {
                    feature("Full public-domain library and guided lesson decks")
                    feature("AI guide through a protected server")
                    feature("Meditation narration and ambient backgrounds")
                    feature("Nutrition, private journal, and progress tools")
                    feature("Small moderated rooms and mentor progression")
                    Divider().overlay(palette.line)
                    HStack(alignment: .firstTextBaseline) {
                        Text(purchase.product?.displayPrice ?? "$9.99")
                            .font(.system(size: 36, weight: .medium, design: .serif))
                        Text("per month")
                            .foregroundStyle(palette.secondaryText)
                    }
                    Text("The three-day introductory trial, renewal terms, and exact local price must be configured and displayed by Apple before purchase.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                    Button {
                        Task { await purchase.purchase() }
                    } label: {
                        Label(purchase.isEntitled ? "Membership active" : "Start with Apple", systemImage: "apple.logo")
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(purchase.product == nil || purchase.isEntitled)
                    Button("Restore purchases") {
                        Task { await purchase.restore() }
                    }
                    .font(.caption.weight(.semibold))
                }
                .padding(20)
                .withinSurface(emphasized: app.theme == .spiritual)

                VStack(alignment: .leading, spacing: 10) {
                    Eyebrow(text: "Referral code")
                    TextField("Enter a friend's code", text: $referralCode)
                        .textInputAutocapitalization(.characters)
                        .padding(12)
                        .background(palette.surface)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                    Text("Friend discounts require server validation and Apple-compliant campaign terms before launch. Creator partnerships live under Account → Work with us.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }

                Link(destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/support")!) {
                    Label("Request financial access from human support", systemImage: "person.crop.circle.badge.questionmark")
                        .font(.subheadline.weight(.semibold))
                }

                if let message = purchase.message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }

                Link("Apple subscription terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Membership")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
        .task { await purchase.prepare() }
    }

    private func feature(_ text: String) -> some View {
        Label(text, systemImage: "checkmark")
            .font(.subheadline)
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
