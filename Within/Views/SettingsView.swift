import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppModel
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 7) {
                    Eyebrow(text: "Account")
                    Text(app.profile.name.isEmpty ? "Your Within" : app.profile.name)
                        .font(.system(size: 34, weight: .medium, design: .serif))
                    Text(app.profile.email)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Eyebrow(text: "Atmosphere")
                    Picker("Theme", selection: $app.theme) {
                        ForEach(ThemeMode.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(app.theme == .spiritual ? "The entire interface uses the deep-blue night palette." : "Warm, quiet, and clear.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
                .padding(18)
                .withinSurface()

                VStack(alignment: .leading, spacing: 14) {
                    Eyebrow(text: "Personalization")
                    Picker("Primary focus", selection: $app.focus) {
                        ForEach(FocusArea.allCases) { focus in
                            Text(focus.title).tag(focus)
                        }
                    }
                    .pickerStyle(.menu)
                    Text("Changing focus updates daily tasks and lesson cards.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
                .padding(18)
                .withinSurface()

                VStack(alignment: .leading, spacing: 14) {
                    Eyebrow(text: "Relationship tools")
                    Toggle(isOn: $app.relationship.hasSignificantOther) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Show partner tools on Home")
                                .font(.subheadline.weight(.semibold))
                            Text("Available with any primary focus.")
                                .font(.caption)
                                .foregroundStyle(palette.secondaryText)
                        }
                    }
                    .toggleStyle(.switch)

                    if app.relationship.hasSignificantOther {
                        TextField("Partner's name", text: $app.relationship.partnerName)
                            .textContentType(.name)
                            .padding(11)
                            .background(palette.background)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))

                        DatePicker("Together since", selection: $app.relationship.startedOn, in: ...Date(), displayedComponents: .date)

                        Toggle(isOn: $app.relationship.isMarried) {
                            Text("We are married")
                                .font(.subheadline.weight(.semibold))
                        }
                        .toggleStyle(.switch)

                        TextField("Partner username or email", text: $app.relationship.linkedPartnerHandle)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(11)
                            .background(palette.background)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))

                        Text("Heart pings are stored locally until production account linking and push notifications are connected.")
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                    }
                }
                .padding(18)
                .withinSurface()

                VStack(alignment: .leading, spacing: 14) {
                    Eyebrow(text: "Your companion")
                    Text("Choose the presence beside the tools")
                        .font(.system(.title3, design: .serif))
                    HStack(spacing: 8) {
                        ForEach(CompanionChoice.allCases) { companion in
                            Button {
                                app.chooseCompanion(companion)
                            } label: {
                                VStack(spacing: 5) {
                                    CompanionAvatar(companion: companion, size: 42, lineWidth: app.companion == companion ? 2 : 1)
                                    Text(companion.name).font(.system(size: 9, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity, minHeight: 74)
                                .background(app.companion == companion ? palette.accentSoft : palette.background)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(app.companion == companion ? palette.accent : palette.line))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Text(app.companion.promise + ". Every companion uses the same safety rules and evidence-based guide.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
                .padding(18)
                .withinSurface()

                VStack(alignment: .leading, spacing: 12) {
                    Eyebrow(text: "Work with us · content creators")
                    Text("Share access without hiding the business.")
                        .font(.system(.title3, design: .serif))
                    Text("Approved creator codes are planned to earn $2.50 after a verified, non-refunded first payment, with a $25 payout threshold, fraud review, and clear ad disclosure. Friend codes create discounts, not cash.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                    external("Ask about the creator program", "https://within-quiet-way.yvngcxrtek.chatgpt.site/support")
                }
                .padding(18)
                .withinSurface()

                VStack(alignment: .leading, spacing: 12) {
                    Eyebrow(text: "Privacy and safety")
                    external("Privacy policy", "https://within-quiet-way.yvngcxrtek.chatgpt.site/privacy")
                    external("Terms", "https://within-quiet-way.yvngcxrtek.chatgpt.site/terms")
                    external("Community standards", "https://within-quiet-way.yvngcxrtek.chatgpt.site/community-guidelines")
                    external("Human support", "https://within-quiet-way.yvngcxrtek.chatgpt.site/support")
                }
                .padding(18)
                .withinSurface()

                VStack(alignment: .leading, spacing: 10) {
                    Eyebrow(text: "Erase this device")
                    Text("Remove the local profile, journal, dreams, sleep records, food history, and private progress photo from this iPhone. Connected server data and billing will need the production account-deletion service.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                    Button("Erase all local Within data", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
                .padding(18)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(palette.danger.opacity(0.55)))
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
        .confirmationDialog("Erase all local Within data?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Erase", role: .destructive) {
                Task {
                    try? await PrivateStore.shared.deleteAllPrivateData()
                    app.resetDemo()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone. Every protected record created by the native app on this device will be removed.")
        }
    }

    private func external(_ title: String, _ url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}
