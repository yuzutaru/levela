//
//  LevelaRootView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Splash
import SwiftUI
import UIKit

/// The app shell. Owns navigation and theming; feature modules provide destinations.
struct LevelaRootView: View {
    var body: some View {
        NavigationStack {
            // The splash is the app's launch screen. It reports completion
            // through `onFinished`; navigation (e.g. to the Onboarding package)
            // will be wired here later.
            SplashView(icon: appIcon)
        }
        .levelaTheme()
    }

    /// The app icon's artwork (transparent foreground), so the splash shows the
    /// app's own icon. iOS app icons don't expose a separate foreground layer,
    /// so the dark/alpha appearance — the illustration without the background —
    /// is the closest equivalent.
    private var appIcon: Image {
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        let image = UIImage(named: "AppIcon", in: .main, compatibleWith: dark) ?? UIImage()
        return Image(uiImage: image)
    }
}

#Preview {
    LevelaRootView()
}
