import Foundation
import Observation

/// Drives the splash flow.
///
/// The platform counterpart of the Android `SplashViewModel`; the owning view
/// schedules the timed advancement, the view model only owns the current stage.
@Observable
@MainActor
public final class SplashViewModel {
    public private(set) var stage: SplashStage = .brand

    /// True once the flow has reached its final stage.
    public var isFinished: Bool { stage == .actions }

    public init() {}

    /// Delay before advancing from the current stage, or `nil` when finished.
    public var nextDelayMs: Int? {
        switch stage {
        case .brand: SplashTokens.autoAdvanceBrandMs
        case .welcome: SplashTokens.autoAdvanceWelcomeMs
        case .actions: nil
        }
    }

    /// Advances to the next stage, staying on ``SplashStage/actions``.
    public func advance() {
        switch stage {
        case .brand: stage = .welcome
        case .welcome: stage = .actions
        case .actions: break
        }
    }
}
