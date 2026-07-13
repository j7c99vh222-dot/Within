import SwiftUI

struct LaunchView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(hex: 0x07111F).ignoresSafeArea()
            VStack(spacing: 22) {
                Image("WithinLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .scaleEffect(appeared ? 1 : 0.72)
                    .opacity(appeared ? 1 : 0)

                Text("change starts from within")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.68))
                .offset(y: appeared ? 0 : 8)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }
}
