import Design
import SwiftUI

/// Contract values for the splash flow.
///
/// Mirrors `assets/splash/splash-contract.json` and the Android `SplashTokens`.
/// Do not hand-edit: change the contract and run
/// `scripts/generate_splash_assets.sh` / `scripts/verify_splash_parity.sh`.
public enum SplashTokens {
    // Flow — stages: brand, welcome, actions
    public static let stages: [SplashStage] = [SplashStage.brand, SplashStage.welcome, SplashStage.actions]
    public static let autoAdvanceBrandMs = 1200
    public static let autoAdvanceWelcomeMs = 1200
    public static let showEveryLaunch = true

    // Copy
    public static let titleLine1 = "Start your"
    public static let titleLine2 = "Fitness Journey"
    public static let login = "Login"
    public static let register = "Register"
    public static let guest = "Continue as a guest"

    // Colours (design-system primitives, see THEME_COLORS.md)
    public static let backgroundGradient: [Color] = [Color.purple800, Color.purple950, Color.purple900]
    public static let backgroundGlow = Color.purple800
    public static let title = Color.white
    public static let logo = Color.lavender200
    public static let loginBackground = Color.purple700
    public static let loginText = Color.gray200
    public static let registerBackground = Color.white
    public static let registerText = Color.purple950
    public static let guestText = Color.lavender200

    // Logo
    public static let logoSize: CGFloat = 64
}
