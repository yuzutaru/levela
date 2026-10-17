//
//  LevelaRootView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Onboarding
import Profile
import Splash
import SwiftUI

/// The app's top-level screens, in the order the guest walks them.
private enum LevelaFlow { case splash, onboarding, mainMenu }

/// The app shell. Owns navigation and theming; feature modules provide destinations.
///
/// The view models are injected by the app's `AppContainer` (the counterpart of
/// Android's `hiltViewModel()`) and held as plain `let`s, not `@State`.
struct LevelaRootView: View {
    @State private var flow: LevelaFlow = .splash

    /// Owns the launch-time "has profile?" state. Returning users skip
    /// onboarding and land directly on the main menu after the splash.
    let rootViewModel: RootViewModel

    /// Owns the onboarding flow's view model so it survives re-renders; injected
    /// into `OnboardingView`. Persistence goes through its injected save
    /// function (wired by the container), so this view only navigates.
    let onboardingViewModel: OnboardingViewModel

    var body: some View {
        // Resolve the launch-time profile check once, on appear (the
        // counterpart of Android collecting the RootViewModel's flow).
        let hasProfile = rootViewModel.hasProfile
        if hasProfile == nil {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.blue500)
                .levelaTheme()
                .task { rootViewModel.load() }
        } else {
            NavigationStack {
                // Splash is the launch screen. For new users, tapping "Continue as a
                // guest" reports completion and crossfades into the onboarding flow.
                // For returning users, the splash auto-finishes and lands directly
                // on the main menu.
                ZStack {
                    switch flow {
                    case .splash:
                        SplashView(icon: Image("SplashIcon"), autoFinish: hasProfile == true) {
                            flow = hasProfile == true ? .mainMenu : .onboarding
                        }
                        .transition(.opacity)
                    case .onboarding:
                        OnboardingView(viewModel: onboardingViewModel) {
                            flow = .mainMenu
                        }
                        .transition(.opacity)
                    case .mainMenu:
                        MainMenuView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.25), value: flow)
            }
            .levelaTheme()
        }
    }
}

#Preview {
    let profileData = try! ProfileData.inMemory()
    LevelaRootView(
        rootViewModel: RootViewModel(repository: profileData.userProfileRepository),
        onboardingViewModel: OnboardingViewModel()
    )
}
