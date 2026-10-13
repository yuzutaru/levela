package com.yuzutaru.profile.local

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * The locally persisted user profile — the first rows captured by the offline
 * onboarding flow.
 *
 * The first four fields are the **sync envelope**: they exist now so that an
 * account can be attached and rows pushed later without a schema migration.
 *
 * @property id client-generated UUID; also the row's identity on the backend, so
 *   a re-pushed profile upserts rather than duplicates.
 * @property accountUserId server-issued user id, `null` until the guest registers
 *   or logs in.
 * @property syncState whether the row still needs pushing to the backend.
 * @property deleted soft-delete tombstone, so a deletion can be propagated later.
 */
@Entity(tableName = "user_profile")
data class UserProfileEntity(
    @PrimaryKey val id: String,
    val accountUserId: String?,
    val goal: String?,
    val ageYears: Int,
    val sex: String?,
    val weightKg: Double,
    val heightCm: Double,
    val activityLevel: String?,
    val weightUnit: String,
    val heightUnit: String,
    val onboardingCompleted: Boolean,
    val createdAt: Long,
    val updatedAt: Long,
    val syncState: SyncState,
    val deleted: Boolean,
)
