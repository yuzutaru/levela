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
struct LevelaRootView: View {
    @State private var flow: LevelaFlow = .splash
    /// Owns the onboarding flow's view model so it survives re-renders; injected
    /// into `OnboardingView`.
    @State private var onboardingViewModel = OnboardingViewModel()

    /// The app-side use case that persists a completed onboarding flow.
    let completeOnboardingUseCase: CompleteOnboardingUseCase

    var body: some View {
        NavigationStack {
            // Splash is the launch screen; tapping "Continue as a guest"
            // reports completion and crossfades into the onboarding flow.
            ZStack {
                switch flow {
                case .splash:
                    SplashView(icon: Image("SplashIcon")) {
                        flow = .onboarding
                    }
                    .transition(.opacity)
                case .onboarding:
                    OnboardingView(viewModel: onboardingViewModel) { profile in
                        complete(profile)
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

    /// Persists the collected profile offline — it stays guest-owned until the
    /// user registers, then syncs under the account — and moves on to the home
    /// screen.
    private func complete(_ profile: OnboardingProfile) {
        try? completeOnboardingUseCase.invoke(profile)
        flow = .mainMenu
    }
}

#Preview {
    LevelaRootView(
        completeOnboardingUseCase: CompleteOnboardingUseCase(
            repository: try! ProfileData.inMemory().userProfileRepository
        )
    )
}
