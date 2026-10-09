//
//  LevelaRootView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Onboarding
import Splash
import SwiftUI

/// The app shell. Owns navigation and theming; feature modules provide destinations.
struct LevelaRootView: View {
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            // Splash is the launch screen; tapping "Continue as a guest"
            // reports completion and crossfades into the onboarding flow.
            ZStack {
                if showOnboarding {
                    OnboardingView()
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
}

#Preview {
    LevelaRootView()
}
