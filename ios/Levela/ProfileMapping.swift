//
//  ProfileMapping.swift
//  Levela
//

import Foundation
import Onboarding
import Profile

extension OnboardingProfile {
    /// Builds a guest-owned profile (no account yet) from the collected
    /// onboarding values.
    ///
    /// The row gets a client-generated UUID: the same id the backend will later
    /// upsert, so registering can re-parent this row instead of copying it.
    /// Mirrors the Android `OnboardingProfile.toUserProfile`.
    func toUserProfile(now: Date = .now) -> UserProfile {
        UserProfile(
            id: UUID().uuidString,
            accountUserId: nil,
            goal: goal,
            ageYears: ageYears,
            sex: sex,
            weightKg: weightKg,
            heightCm: heightCm,
            activityLevel: activityLevel,
            weightUnit: weightUnit,
            heightUnit: heightUnit,
            onboardingCompleted: true,
            createdAt: now,
            updatedAt: now
        )
    }
}
