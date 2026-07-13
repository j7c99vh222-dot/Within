import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var app: AppModel
    @State private var step = 0
    @State private var profile = AccountProfile()
    @State private var password = ""
    @State private var selectedFocus: FocusArea = .growth
    @State private var selectedCompanion: CompanionChoice = .capy
    @State private var selectedTheme: ThemeMode = .minimal
    @State private var relationship = RelationshipProfile()
    @State private var acceptedTerms = false
    @State private var error: String?

    private enum Stage {
        case focus
        case relationship
        case account
        case companion
        case theme
        case membership
    }

    var body: some View {
        ZStack {
            WithinBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        WithinLogo()
                        Spacer()
                        Text("\(step + 1) / \(stages.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.secondaryText)
                    }

                    Group {
                        switch currentStage {
                        case .focus: focusStep
                        case .relationship: relationshipStep
                        case .account: accountStep
                        case .companion: companionStep
                        case .theme: themeStep
                        case .membership: membershipStep
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))

                    if let error {
                        Label(error, systemImage: "exclamationmark.circle")
                            .font(.footnote)
                            .foregroundStyle(palette.danger)
                    }

                    HStack(spacing: 12) {
                        if step > 0 {
                            Button("Back") {
                                error = nil
                                withAnimation { step -= 1 }
                            }
                            .buttonStyle(.bordered)
                        }
                        Button(currentStage == .membership ? "Begin three-day trial" : "Continue") {
                            continueFlow()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 26)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(palette.text)
        .tint(palette.accent)
        .preferredColorScheme(selectedTheme == .spiritual ? .dark : .light)
    }

    private var focusStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "Personalize your path")
                Text("What do you need help with?")
                    .font(.system(size: 38, weight: .medium, design: .serif))
                Text("Choose what matters most right now. You can change this later.")
                    .foregroundStyle(palette.secondaryText)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(FocusArea.allCases) { focus in
                    Button {
                        selectedFocus = focus
                        if focus != .relationships {
                            relationship = RelationshipProfile()
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 16) {
                            Image(systemName: focus.symbol)
                                .font(.title3)
                            Text(focus.title)
                                .font(.headline)
                            Text(focus.routeTitle)
                                .font(.caption)
                                .foregroundStyle(palette.secondaryText)
                                .lineLimit(3)
                        }
                        .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
                        .padding(16)
                        .background(selectedFocus == focus ? palette.accentSoft : palette.surface)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedFocus == focus ? palette.accent : palette.line, lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var relationshipStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "Relationship support")
                Text("Do you have someone you want Within to remember?")
                    .font(.system(size: 36, weight: .medium, design: .serif))
                Text("If yes, Home will show anniversary reminders, daily relationship prompts, and a private heart ping card.")
                    .foregroundStyle(palette.secondaryText)
            }

            VStack(alignment: .leading, spacing: 16) {
                Toggle(isOn: $relationship.hasSignificantOther) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("I am in a relationship or married")
                            .font(.headline)
                        Text("This unlocks the relationship calendar and partner check-in card.")
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                    }
                }
                .toggleStyle(.switch)

                if relationship.hasSignificantOther {
                    field("Partner's name", text: $relationship.partnerName, contentType: .name)

                    DatePicker("Together since", selection: $relationship.startedOn, in: ...Date(), displayedComponents: .date)
                        .font(.subheadline)

                    Toggle(isOn: $relationship.isMarried) {
                        Text("We are married")
                            .font(.subheadline.weight(.semibold))
                    }
                    .toggleStyle(.switch)

                    field("Partner username or email for linking (optional)", text: $relationship.linkedPartnerHandle, contentType: .username, keyboard: .emailAddress, autocapitalization: .never)

                    Text("Account linking and heart pings need the production account and push-notification service. This saves the setup now so the UI is ready.")
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
            }
            .padding(18)
            .withinSurface(emphasized: selectedTheme == .spiritual)
        }
    }

    private var accountStep: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "Your account")
                Text("A private place to begin.")
                    .font(.system(size: 38, weight: .medium, design: .serif))
                Text("Your journal and health information are private. Community members see only your username.")
                    .foregroundStyle(palette.secondaryText)
            }

            VStack(spacing: 14) {
                field("Name", text: $profile.name, contentType: .name)
                field("Email", text: $profile.email, contentType: .emailAddress, keyboard: .emailAddress, autocapitalization: .never)
                field("Username", text: $profile.username, contentType: .username, autocapitalization: .never)
                field("Phone number (optional)", text: $profile.phone, contentType: .telephoneNumber, keyboard: .phonePad)
                VStack(alignment: .leading, spacing: 7) {
                    Text("Password")
                        .font(.caption.weight(.semibold))
                    SecureField("At least 8 characters", text: $password)
                        .textContentType(.newPassword)
                        .padding(13)
                        .background(palette.surface)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
                }
            }
        }
    }

    private var themeStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "Atmosphere")
                Text("Choose how Within feels.")
                    .font(.system(size: 38, weight: .medium, design: .serif))
                Text("The theme changes the complete interface, not only the background.")
                    .foregroundStyle(palette.secondaryText)
            }

            HStack(spacing: 12) {
                themeButton(.minimal, symbol: "circle.lefthalf.filled")
                themeButton(.spiritual, symbol: "moon.stars")
            }

        }
    }

    private var companionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "Choose your companion")
                Text("Who should meet you inside the difficult moments?")
                    .font(.system(size: 38, weight: .medium, design: .serif))
                Text("Each companion opens the same safety-aware guide. What changes is the name and tone that makes the space feel like yours.")
                    .foregroundStyle(palette.secondaryText)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(CompanionChoice.allCases) { companion in
                    Button {
                        selectedCompanion = companion
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            CompanionAvatar(companion: companion, size: 64, lineWidth: selectedCompanion == companion ? 2 : 1)
                            Text(companion.name)
                                .font(.system(.title3, design: .serif).weight(.semibold))
                            Text(companion.species)
                                .font(.caption.weight(.semibold))
                            Text(companion.promise)
                                .font(.caption2)
                                .foregroundStyle(palette.secondaryText)
                                .lineLimit(4)
                        }
                        .frame(maxWidth: .infinity, minHeight: 190, alignment: .leading)
                        .padding(16)
                        .background(selectedCompanion == companion ? palette.accentSoft : palette.surface)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedCompanion == companion ? palette.accent : palette.line))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Eyebrow(text: "A first word from \(selectedCompanion.name)")
                Text("“\(selectedCompanion.greeting)”")
                    .font(.system(.title3, design: .serif))
                Text("\(selectedCompanion.name) is an app persona, not a person, therapist, or conscious being.")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .padding(17)
            .withinSurface()
        }
    }

    private var membershipStep: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "Membership before the doorway")
                Text("Three days to explore the whole path.")
                    .font(.system(size: 38, weight: .medium, design: .serif))
                Text("After the trial, Within is $10 per month unless you cancel through your Apple subscription settings. Financial-access review remains available from Account.")
                    .foregroundStyle(palette.secondaryText)
            }

            VStack(alignment: .leading, spacing: 13) {
                Text("$10")
                    .font(.system(size: 50, weight: .medium, design: .serif))
                Text("per month after a three-day free trial")
                    .font(.subheadline.weight(.semibold))
                Label("Daily paths, complete learning library, journal, nutrition, sleep, and meditation", systemImage: "checkmark")
                Label("AI guide and book companion when the secure service is connected", systemImage: "checkmark")
                Label("Minimal and premium spiritual-night atmospheres", systemImage: "checkmark")
                Label("Small, moderated community circles", systemImage: "checkmark")
            }
            .font(.subheadline)
            .padding(19)
            .withinSurface(emphasized: selectedTheme == .spiritual)

            Toggle(isOn: $acceptedTerms) {
                Text("I am at least 18 and agree to the Terms, Privacy Policy, Community Standards, and subscription terms.")
                    .font(.footnote)
            }
            .toggleStyle(.switch)

            HStack(spacing: 18) {
                Link("Terms", destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/terms")!)
                Link("Privacy", destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/privacy")!)
                Link("Community", destination: URL(string: "https://within-quiet-way.yvngcxrtek.chatgpt.site/community-guidelines")!)
            }
            .font(.caption.weight(.semibold))

            Text("This Xcode demo does not charge until the App Store Connect product is connected. Apple will show the final price, renewal period, and cancellation terms before confirmation.")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
    }

    private func field(
        _ title: String,
        text: Binding<String>,
        contentType: UITextContentType?,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .words
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.semibold))
            TextField(title, text: text)
                .textContentType(contentType)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .padding(13)
                .background(palette.surface)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(palette.line))
        }
    }

    private func themeButton(_ theme: ThemeMode, symbol: String) -> some View {
        Button {
            selectedTheme = theme
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.title2)
                Text(theme.title)
                    .font(.headline)
                Text(theme == .minimal ? "Quiet and clear" : "Deep blue night sky")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
            .padding(16)
            .background(selectedTheme == theme ? palette.accentSoft : palette.surface)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedTheme == theme ? palette.accent : palette.line))
        }
        .buttonStyle(.plain)
    }

    private var palette: WithinPalette { .palette(for: selectedTheme) }

    private var stages: [Stage] {
        selectedFocus == .relationships
            ? [.focus, .relationship, .account, .companion, .theme, .membership]
            : [.focus, .account, .companion, .theme, .membership]
    }

    private var currentStage: Stage {
        stages[min(step, stages.count - 1)]
    }

    private func continueFlow() {
        error = nil
        switch currentStage {
        case .focus:
            withAnimation { step += 1 }
        case .relationship:
            if relationship.hasSignificantOther {
                guard relationship.trimmedPartnerName.count >= 2 else {
                    error = "Enter your partner's name or turn the relationship feature off."
                    return
                }
            }
            withAnimation { step += 1 }
        case .account:
            guard profile.name.trimmingCharacters(in: .whitespaces).count >= 2 else { error = "Enter your name."; return }
            guard profile.email.contains("@") else { error = "Enter a valid email address."; return }
            guard profile.username.count >= 3 else { error = "Choose a username with at least 3 characters."; return }
            guard password.count >= 8 else { error = "Use a password with at least 8 characters."; return }
            password = ""
            withAnimation { step += 1 }
        case .companion:
            withAnimation { step += 1 }
        case .theme:
            withAnimation { step += 1 }
        case .membership:
            guard acceptedTerms else { error = "Accept the terms to continue."; return }
            app.completeOnboarding(profile: profile, focus: selectedFocus, companion: selectedCompanion, theme: selectedTheme, relationship: relationship)
        }
    }
}
