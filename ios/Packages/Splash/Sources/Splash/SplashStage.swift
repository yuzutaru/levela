import Foundation

/// The auto-advancing stages of the splash flow.
///
/// Mirrors the Android `SplashStage`. The raw values must match
/// `flow.stages` in `assets/splash/splash-contract.json`
/// (enforced by `scripts/verify_splash_parity.sh`).
public enum SplashStage: String, Sendable, CaseIterable {
    case brand
    case welcome
    case actions
}
