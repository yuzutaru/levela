//
//  LevelaRootView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Onboarding
import Persistence
import Splash
import SwiftData
import SwiftUI

/// The app shell. Owns navigation and theming; feature modules provide destinations.
struct LevelaRootView: View {
    @State private var showOnboarding = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            // Splash is the launch screen; tapping "Continue as a guest"
            // reports completion and crossfades into the onboarding flow.
            ZStack {
                if showOnboarding {
                    OnboardingView { profile in
                        persist(profile)
                    }
                    .transition(.opacity)
                } else {
                    SplashView(icon: Image("SplashIcon")) {
                        showOnboarding = true
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.25), value: showOnboarding)
        }
        .levelaTheme()
    }

    /// Persists the collected profile offline; it stays guest-owned until the
    /// user registers, then syncs under the account.
    private func persist(_ profile: OnboardingProfile) {
        let store = ProfileStore(context: modelContext)
        try? store.save(UserProfile(onboarding: profile))
    }
}

#Preview {
    LevelaRootView()
}
