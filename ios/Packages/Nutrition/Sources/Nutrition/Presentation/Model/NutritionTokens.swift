//
//  NutritionTokens.swift
//  Nutrition
//

/// Contract values for the Nutrition destination.
///
/// Mirrors the Android `NutritionTokens` and the `mainmenu.nutrition` handle
/// that the app's UI tests assert against. Keep `screenTag` stable: routing and
/// end-to-end tests find the destination by it.
public enum NutritionTokens {
    /// The Nutrition heading copy.
    public static let title = "Nutrition"

    /// Stable accessibility identifier for the Nutrition destination's heading.
    public static let screenTag = "mainmenu.nutrition"
}
