import Design
import SwiftUI

/// The Levela splash (launch welcome) screen.
///
/// Shows the app icon and auto-advances through the ``SplashStage``s in
/// ``SplashTokens``; the actions are visual only for now, and the whole flow
/// reports completion through `onFinished` so the app can wire navigation later.
/// The Login / Register buttons are defined but hidden while accounts are
/// deferred (offline-first) — see ``SplashTokens/showAuthActions``. The guest
/// entry is a primary button (``SplashTokens/showGuestButton``); the old
/// underlined link is defined but hidden (``SplashTokens/showGuestLink``).
///
/// Mirrors the Android `SplashView`.
///
/// - Parameter icon: the app icon, injected by the app.
@MainActor
public struct SplashView: View {
    @State private var viewModel = SplashViewModel()
    private let icon: Image
    private let onFinished: () -> Void

    public init(icon: Image, onFinished: @escaping () -> Void = {}) {
        self.icon = icon
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                mark

                if viewModel.stage != .brand {
                    title
                        .padding(.top, 24)
                }

                Spacer(minLength: 0)

                if viewModel.stage == .actions {
                    actions
                }
            }
            .padding(.horizontal, 28)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.3), value: viewModel.stage)
        .task(id: viewModel.stage) {
            guard let delayMs = viewModel.nextDelayMs else { return }
            try? await Task.sleep(for: .milliseconds(delayMs))
            viewModel.advance()
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: SplashTokens.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [SplashTokens.backgroundGlow.opacity(0.55), .clear],
                center: UnitPoint(x: 0.5, y: -0.08),
                startRadius: 0,
                endRadius: 460
            )
        }
    }

    private var mark: some View {
        icon
            .resizable()
            .interpolation(.high)
            .frame(width: SplashTokens.iconSize, height: SplashTokens.iconSize)
    }

    private var title: some View {
        VStack(spacing: 0) {
            Text(SplashTokens.titleLine1)
                .font(LevelaTypography.headlineMedium)
            Text(SplashTokens.titleLine2)
                .font(LevelaTypography.headlineMedium.bold())
        }
        .foregroundStyle(SplashTokens.title)
        .multilineTextAlignment(.center)
    }

    private var actions: some View {
        VStack(spacing: 0) {
            if SplashTokens.showAuthActions {
                SplashButton(
                    title: SplashTokens.login,
                    background: SplashTokens.loginBackground,
                    foreground: SplashTokens.loginText
                ) {}

                SplashButton(
                    title: SplashTokens.register,
                    background: SplashTokens.registerBackground,
                    foreground: SplashTokens.registerText
                ) {}
                .padding(.top, 12)
            }

            if SplashTokens.showGuestButton {
                SplashButton(
                    title: SplashTokens.guest,
                    background: SplashTokens.registerBackground,
                    foreground: SplashTokens.registerText,
                    action: onFinished
                )
            }

            if SplashTokens.showGuestLink {
                Text(SplashTokens.guest)
                    .font(LevelaTypography.labelMedium)
                    .foregroundStyle(SplashTokens.guestText)
                    .underline()
                    .padding(.top, 18)
                    .onTapGesture {}
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 28)
    }
}

private struct SplashButton: View {
    let title: String
    let background: Color
    let foreground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LevelaTypography.labelLarge)
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(background, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SplashView(icon: Image(systemName: "figure.run"))
        .levelaTheme()
}
