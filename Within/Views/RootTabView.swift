import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var app: AppModel
    @State private var modalDestination: RootModalDestination?
    @State private var showsRadialMenu = false

    var body: some View {
        let palette = WithinPalette.palette(for: app.theme)

        ZStack(alignment: .bottom) {
            TabView(selection: $app.selectedTab) {
                TodayView()
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(0)

                NavigationStack {
                    GuideView()
                }
                .tabItem { Label("Coach", systemImage: "sparkles") }
                .tag(1)

                MoreView()
                    .tabItem { Label("More", systemImage: "circle.grid.3x3.fill") }
                    .tag(2)

                NavigationStack {
                    NutritionView()
                }
                .tabItem { Label("Nutrition", systemImage: "leaf") }
                .tag(3)

                SleepView()
                    .tabItem { Label("Sleep", systemImage: "moon.stars") }
                    .tag(4)
            }
            .tint(palette.accent)
            .toolbarBackground(palette.surface, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)

            if showsRadialMenu {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                            showsRadialMenu = false
                        }
                    }
            }

            if showsRadialMenu {
                radialShortcutMenu
                    .padding(.bottom, 72)
                    .transition(.scale(scale: 0.82, anchor: .bottom).combined(with: .opacity))
            }

            moreOrb
                .padding(.bottom, 12)
        }
        .sheet(item: $modalDestination) { destination in
            modalView(destination)
        }
    }

    private var moreOrb: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                showsRadialMenu = false
            }
            app.selectedTab = 2
        } label: {
            ZStack {
                Circle()
                    .fill(orbFill)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Circle()
                            .stroke(orbStroke, lineWidth: app.theme == .spiritual ? 1.4 : 1)
                    }
                    .shadow(color: orbGlow, radius: app.theme == .spiritual ? 20 : 8, y: 4)

                if app.theme == .spiritual {
                    Image(systemName: "sparkles")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(WithinPalette.palette(for: app.theme).accent)
                }
            }
            .scaleEffect(app.selectedTab == 2 ? 1.04 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.35)
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.76)) {
                        showsRadialMenu = true
                    }
                }
        )
        .accessibilityLabel("More")
        .accessibilityHint("Tap to open More. Long press for shortcuts.")
    }

    private var radialShortcutMenu: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(shortcutMenuFill)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(shortcutButtonStroke, lineWidth: 1)
                }
                .shadow(color: app.theme == .spiritual ? .black.opacity(0.42) : .black.opacity(0.16), radius: 18, y: 8)

            ForEach(RadialShortcut.allCases) { shortcut in
                Button {
                    activate(shortcut)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: shortcut.symbol)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(width: 48, height: 48)
                            .background(shortcutButtonFill)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(shortcutButtonStroke, lineWidth: 1))
                            .shadow(color: app.theme == .spiritual ? .black.opacity(0.35) : .black.opacity(0.12), radius: 8, y: 3)
                        Text(shortcut.title)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(WithinPalette.palette(for: app.theme).text)
                    }
                    .frame(width: 66)
                }
                .buttonStyle(.plain)
                .offset(shortcut.offset)
                .accessibilityLabel(shortcut.accessibilityLabel)
            }
        }
        .frame(width: 342, height: 188)
    }

    private var orbFill: some ShapeStyle {
        if app.theme == .spiritual {
            return AnyShapeStyle(
                AngularGradient(
                    colors: [
                        Color(hex: 0x7FB2DF),
                        Color(hex: 0x9B7DE3),
                        Color(hex: 0x071A38),
                        Color(hex: 0xDCC577),
                        Color(hex: 0x7FB2DF)
                    ],
                    center: .center
                )
            )
        }

        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    WithinPalette.palette(for: app.theme).surface,
                    WithinPalette.palette(for: app.theme).accentSoft
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var orbStroke: Color {
        let palette = WithinPalette.palette(for: app.theme)
        return app.theme == .spiritual ? palette.accent.opacity(0.82) : palette.line
    }

    private var orbGlow: Color {
        let palette = WithinPalette.palette(for: app.theme)
        return app.theme == .spiritual ? palette.accent.opacity(0.48) : .black.opacity(0.12)
    }

    private var shortcutButtonFill: Color {
        let palette = WithinPalette.palette(for: app.theme)
        return app.theme == .spiritual ? palette.raisedSurface.opacity(0.96) : palette.surface
    }

    private var shortcutMenuFill: Color {
        let palette = WithinPalette.palette(for: app.theme)
        return app.theme == .spiritual ? palette.surface.opacity(0.96) : palette.raisedSurface.opacity(0.98)
    }

    private var shortcutButtonStroke: Color {
        let palette = WithinPalette.palette(for: app.theme)
        return app.theme == .spiritual ? palette.accent.opacity(0.58) : palette.line
    }

    private func activate(_ shortcut: RadialShortcut) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            showsRadialMenu = false
        }
        modalDestination = shortcut.destination
    }

    @ViewBuilder
    private func modalView(_ destination: RootModalDestination) -> some View {
        switch destination {
        case .journal:
            NavigationStack { JournalView() }
        case .practice:
            PracticeView()
        case .learn:
            LearnView()
        case .community:
            CommunityView()
        case .recovery:
            NavigationStack { RecoveryView() }
        case .settings:
            NavigationStack { SettingsView() }
        }
    }
}

private enum RootModalDestination: String, Identifiable {
    case journal
    case practice
    case learn
    case community
    case recovery
    case settings

    var id: String { rawValue }
}

private enum RadialShortcut: String, CaseIterable, Identifiable {
    case journal
    case practice
    case learn
    case community
    case recovery
    case account

    var id: String { rawValue }

    var title: String {
        switch self {
        case .journal: "Journal"
        case .practice: "Practice"
        case .learn: "Learn"
        case .community: "Circle"
        case .recovery: "Recovery"
        case .account: "Account"
        }
    }

    var symbol: String {
        switch self {
        case .journal: "square.and.pencil"
        case .practice: "wind"
        case .learn: "rectangle.stack"
        case .community: "person.3"
        case .recovery: "shield.lefthalf.filled"
        case .account: "person.crop.circle"
        }
    }

    var destination: RootModalDestination {
        switch self {
        case .journal: .journal
        case .practice: .practice
        case .learn: .learn
        case .community: .community
        case .recovery: .recovery
        case .account: .settings
        }
    }

    var offset: CGSize {
        switch self {
        case .journal: CGSize(width: -128, height: -12)
        case .practice: CGSize(width: -88, height: -82)
        case .learn: CGSize(width: -28, height: -124)
        case .community: CGSize(width: 40, height: -124)
        case .recovery: CGSize(width: 96, height: -82)
        case .account: CGSize(width: 132, height: -12)
        }
    }

    var accessibilityLabel: String {
        "Open \(title)"
    }
}
