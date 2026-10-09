import Design
import SwiftUI

/// Contract values for the splash flow.
///
/// Mirrors `assets/splash/splash-contract.json` and the Android `SplashTokens`.
/// Do not hand-edit: change the contract and run `scripts/verify_splash_parity.sh`.
public enum SplashTokens {
    // Flow — stages: brand, welcome, actions
    public static let stages: [SplashStage] = [SplashStage.brand, SplashStage.welcome, SplashStage.actions]
    public static let autoAdvanceBrandMs = 1200
    public static let autoAdvanceWelcomeMs = 1200
    public static let showEveryLaunch = true

    /// Accounts are deferred (offline-first): the Login / Register buttons and
    /// their copy stay defined, but are hidden until the auth flow lands.
    public static let showAuthActions = false

    /// The guest entry is a primary button now; the old underlined link stays
    /// defined but hidden. Both use the `guest` copy.
    public static let showGuestLink = false
    public static let showGuestButton = true

    // Copy
    public static let titleLine1 = "Start your"
    public static let titleLine2 = "Fitness Journey"
    public static let login = "Login"
    public static let register = "Register"
    public static let guest = "Continue as a guest"

    // Colours (design-system primitives, see THEME_COLORS.md)
    public static let backgroundGradient: [Color] = [.white, Color.lightBlue100]
    public static let backgroundGlow = Color.lightBlue300
    public static let title = Color.navy900
    public static let loginBackground = Color.gray100
    public static let loginText = Color.blue700
    public static let registerBackground = Color.blue500
    public static let registerText = Color.white
    public static let guestText = Color.gray500

    // Icon (the app's launcher icon foreground, injected by the app)
    public static let iconSize: CGFloat = 96
}
