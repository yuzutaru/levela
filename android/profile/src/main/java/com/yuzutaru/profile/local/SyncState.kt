package com.yuzutaru.profile.local

/**
 * How far a row has travelled through the (future) sync engine.
 *
 * Rows are written `Pending` while the app is offline and flipped to `Synced`
 * once the backend has accepted them. See `UserProfileEntity`.
 */
enum class SyncState {
    /** Written locally, not yet confirmed by the backend. */
    Pending,

    /** Accepted by the backend; the local row matches the server copy. */
    Synced,

    /** The last push attempt failed; eligible for retry. */
    Failed,
}
