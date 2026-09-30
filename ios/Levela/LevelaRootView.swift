//
//  LevelaRootView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Onboarding
import SwiftUI

/// The app shell. Owns navigation and theming; feature modules provide destinations.
struct LevelaRootView: View {
    var body: some View {
        NavigationStack {
            OnboardingView()
        }
        .levelaTheme()
    }
}

#Preview {
    LevelaRootView()
}
