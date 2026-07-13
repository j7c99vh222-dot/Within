import SwiftUI

struct WithinPalette {
    let background: Color
    let surface: Color
    let raisedSurface: Color
    let text: Color
    let secondaryText: Color
    let line: Color
    let accent: Color
    let accentSoft: Color
    let gold: Color
    let danger: Color

    static func palette(for theme: ThemeMode) -> WithinPalette {
        switch theme {
        case .minimal:
            WithinPalette(
                background: Color(hex: 0xF4F5F2),
                surface: Color(hex: 0xFDFDFB),
                raisedSurface: .white,
                text: Color(hex: 0x1B1F1C),
                secondaryText: Color(hex: 0x69716C),
                line: Color(hex: 0xD8DED8),
                accent: Color(hex: 0x356452),
                accentSoft: Color(hex: 0xDCE7DA),
                gold: Color(hex: 0xB4873F),
                danger: Color(hex: 0x934B45)
            )
        case .spiritual:
            WithinPalette(
                background: Color(hex: 0x06142D),
                surface: Color(hex: 0x0C2143),
                raisedSurface: Color(hex: 0x102B53),
                text: Color(hex: 0xF1F5FF),
                secondaryText: Color(hex: 0xA9B8D3),
                line: Color(hex: 0x29466F),
                accent: Color(hex: 0x7FB2DF),
                accentSoft: Color(hex: 0x1A416B),
                gold: Color(hex: 0xDCC577),
                danger: Color(hex: 0xF0A09A)
            )
        }
    }
}

struct WithinBackground: View {
    @EnvironmentObject private var app: AppModel

    var body: some View {
        let palette = WithinPalette.palette(for: app.theme)
        ZStack {
            palette.background.ignoresSafeArea()
            if app.theme == .spiritual {
                Image("SpiritualNight")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.48)
                Color(hex: 0x031027).opacity(0.60).ignoresSafeArea()
            }
        }
    }
}

struct ScreenBackgroundModifier: ViewModifier {
    @EnvironmentObject private var app: AppModel

    func body(content: Content) -> some View {
        let palette = WithinPalette.palette(for: app.theme)
        content
            .foregroundStyle(palette.text)
            .background(WithinBackground())
            .tint(palette.accent)
    }
}

struct SurfaceModifier: ViewModifier {
    @EnvironmentObject private var app: AppModel
    let emphasized: Bool

    func body(content: Content) -> some View {
        let palette = WithinPalette.palette(for: app.theme)
        content
            .background(emphasized ? palette.raisedSurface : palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(palette.line, lineWidth: 1)
            }
    }
}

extension View {
    func withinScreen() -> some View { modifier(ScreenBackgroundModifier()) }
    func withinSurface(emphasized: Bool = false) -> some View { modifier(SurfaceModifier(emphasized: emphasized)) }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct Eyebrow: View {
    @EnvironmentObject private var app: AppModel
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .foregroundStyle(WithinPalette.palette(for: app.theme).secondaryText)
    }
}

struct WithinLogo: View {
    @EnvironmentObject private var app: AppModel
    var compact = false

    var body: some View {
        HStack(spacing: 9) {
            Image("WithinLogo")
                .resizable()
                .scaledToFill()
                .frame(width: compact ? 32 : 42, height: compact ? 32 : 42)
                .clipShape(Circle())
            if !compact {
                Text("within")
                    .font(.system(size: 24, weight: .medium, design: .serif))
            }
        }
    }
}

struct CompanionAvatar: View {
    @EnvironmentObject private var app: AppModel
    let companion: CompanionChoice
    var size: CGFloat = 52
    var lineWidth: CGFloat = 1

    var body: some View {
        let palette = WithinPalette.palette(for: app.theme)
        Image(companion.avatarAssetName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(app.theme == .spiritual ? palette.accent.opacity(0.55) : palette.line, lineWidth: lineWidth)
            }
            .shadow(color: app.theme == .spiritual ? palette.accent.opacity(0.28) : .black.opacity(0.08), radius: app.theme == .spiritual ? 10 : 4, y: 2)
            .accessibilityLabel("\(companion.name), \(companion.species)")
    }
}
