import SwiftUI

@main
struct WithinApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var app = AppModel()
    @StateObject private var ambient = AmbientPlayer()
    @State private var isLaunching = true

    var body: some Scene {
        WindowGroup {
            Group {
                if isLaunching {
                    LaunchView()
                        .transition(.opacity)
                } else if app.isOnboarded {
                    RootTabView()
                        .transition(.opacity)
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
            .environmentObject(app)
            .environmentObject(ambient)
            .preferredColorScheme(app.theme == .spiritual ? .dark : .light)
            .animation(.easeInOut(duration: 0.35), value: isLaunching)
            .task {
                try? await Task.sleep(for: .seconds(1.35))
                isLaunching = false
                if app.isOnboarded {
                    await MorningAffirmationService.refreshSchedule(profile: app.profile)
                }
            }
            .onChange(of: app.isOnboarded) { _, isOnboarded in
                guard isOnboarded else { return }
                Task {
                    await MorningAffirmationService.refreshSchedule(profile: app.profile)
                }
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                app.refreshDailyState()
            }
        }
    }
}
