package com.yuzutaru.profile.data.di

import android.content.Context
import com.yuzutaru.profile.data.ProfileData
import com.yuzutaru.profile.data.local.ProfileDatabase
import com.yuzutaru.profile.data.repository.UserProfileRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Hilt bindings for the profile data layer.
 *
 * Room types stay inside `:profile`; consumers (e.g. `:app`) only inject
 * repositories and domain models.
 */
@Module
@InstallIn(SingletonComponent::class)
object ProfileDataModule {

    @Provides
    @Singleton
    fun provideProfileData(@ApplicationContext context: Context): ProfileData =
        ProfileData(context)

    @Provides
    @Singleton
    fun provideUserProfileRepository(profileData: ProfileData): UserProfileRepository =
        profileData.userProfileRepository
}
