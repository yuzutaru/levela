import Foundation
import Observation

/// Owns the app's launch-time state: whether a profile already exists.
///
/// The check goes through `HasActiveProfileUseCase`, so the view model never
/// touches the repository directly. `nil` means "still loading", `false` means
/// "no profile yet" (route to onboarding) and `true` means "returning user"
/// (route to main menu). Mirrors the Android `RootViewModel`.
@Observable
@MainActor
final class RootViewModel {
    private let hasActiveProfileUseCase: HasActiveProfileUseCase

    /// The launch-time profile state; `nil` until the check completes.
    private(set) var hasProfile: Bool?

    init(hasActiveProfileUseCase: HasActiveProfileUseCase) {
        self.hasActiveProfileUseCase = hasActiveProfileUseCase
    }

    /// Resolves whether a profile already exists. Called once from the root
    /// view's `.task` (the counterpart of Android's `stateIn` flow collection).
    func load() {
        hasProfile = hasActiveProfileUseCase.invoke()
    }
}
