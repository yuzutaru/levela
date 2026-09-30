//
//  LevelaApp.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import SwiftUI

@main
struct LevelaApp: App {
    init() {
        // Fonts live in the Design package's resource bundle; register them so
        // `Font.custom` can resolve their PostScript names.
        LevelaFonts.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            LevelaRootView()
        }
    }
}
