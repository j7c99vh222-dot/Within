# Within for iPhone

This folder is a native SwiftUI iPhone project. It is separate from the web app and can be opened directly in Xcode.

## Open it

1. Double-click `Within.xcodeproj`.
2. Select the blue **Within** project, then the **Within** target.
3. Open **Signing & Capabilities**.
4. Choose your Apple Developer **Team**.
5. Replace the placeholder bundle identifier `com.within.app` with one you control. Choose carefully before creating the App Store record.
6. Confirm **Sign in with Apple** appears. Add it with **+ Capability** if Xcode does not resolve the included entitlement automatically.
7. Add **In-App Purchase** with **+ Capability**.
8. Pick an iPhone simulator and press the Run triangle.

The project targets iOS 17 and has no third-party dependencies.

## What is implemented

- Native launch animation and three-step personalized onboarding
- Complete Minimal and Spiritual night palettes across every screen
- Organized Today screen with practice, mood, daily promises, compact continuation links, hydration milestones, guide, gut-brain learning, daily wisdom, and a sourced fact
- 76 focus-aware, source-linked lessons organized as resumable courses; a different lesson opens each day
- 2,796 source-attributed public-domain wisdom passages, with a quality-screened daily pool and direct edition links
- 12 public-domain books with overviews, guided lesson decks, quotations, interpretation, practices, and full-text links
- Guided meditation using the device's natural system voice
- Ten original looping sound beds generated specifically for the app: 432 Hz, rain, ocean, birds, classical-style arpeggio, white noise, brown noise, forest rain, night crickets, and soft wind
- Four breathing methods with comfort and safety guidance
- Illustrated yoga poses with real tutorial and safety links
- Private journal and private progress photo using iOS complete file protection
- BMI, optional body-fat field, nutrition goals, generic gram-based food logging, protein and fiber totals, diet accommodations, a non-punitive meal reset, and a four-milestone hydration reminder shared with Today
- Dedicated Sleep tab with a seven-day diary, transparent wellness score, pattern guidance, source links, sleep sound room, timer, and protected dream journal
- Recovery urge plan and treatment/crisis resources
- Community interface with filtering, reporting, immediate blocking, mentor labels, small random rooms, and 24-hour messaging language
- Human support, privacy, terms, and community contact links
- StoreKit 2 monthly subscription code using product ID `within.monthly`
- AI client boundary with reviewed offline safety responses; no secret is stored in the app
- Apple privacy manifest and account deletion interface

The target has been compiled successfully against the installed iPhone device SDK with code signing disabled. This Mac does not currently have an iOS Simulator runtime installed, so install one in Xcode before using the simulator.

## Required production connections

The native project compiles and runs as a local demo. These external systems still require your real accounts and credentials before App Store submission:

### Accounts

The onboarding interface intentionally does not create a production account yet. Connect it to a managed identity service, verify email and phone as needed, and add Sign in with Apple when any third-party sign-in is offered. Never store passwords in `UserDefaults` or send them to an AI service.

### AI

Keep the OpenAI API key on your server. This repo includes a Vercel backend in `api/guide.js`; see `BACKEND.md` for deployment steps. Set the generated Info.plist key `WITHIN_API_BASE_URL` to your secured API origin after native authentication is available. The app calls `/api/guide` only when that key contains a valid URL and otherwise uses reviewed local coping guidance.

### Community

The included room is a safe UI demo. Production posting must call the server moderation route before publication, persist reports and blocks, expire messages, and route reports to named trained human moderators. Do not enable public posting when filtering or the human response queue is unavailable.

### Subscription

Create an auto-renewable subscription in App Store Connect with product ID `within.monthly`. Configure the local price, a three-day introductory trial, renewal language, privacy policy, and terms. StoreKit displays Apple's real localized price once the product is approved for testing.

### App Store assets

Install an iOS Simulator runtime from Xcode Settings > Components first. The included asset catalog is excluded from the current demo target because this Mac does not have that runtime installed; in Xcode, add `Resources/Assets.xcassets` to the Within target membership before archiving. Then add a final 1024 x 1024 app icon to `AppIcon.appiconset`, screenshots for required iPhone sizes, support and privacy URLs, App Privacy answers, age rating, review notes, and a demo account for App Review.

## Safety release gate

Before public launch, obtain clinical review for crisis, withdrawal, panic, eating, nutrition, and medication-related language. Staff moderation every day you allow public posting. The app is wellness and peer support, not diagnosis, treatment, or emergency care.
