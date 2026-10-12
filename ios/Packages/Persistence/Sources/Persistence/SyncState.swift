import Foundation

/// How far a row has travelled through the (future) sync engine.
///
/// Rows are written `.pending` while the app is offline and flipped to `.synced`
/// once the backend has accepted them. Mirrors the Android `SyncState`.
public enum SyncState: String, Codable, Sendable, CaseIterable {
    /// Written locally, not yet confirmed by the backend.
    case pending

    /// Accepted by the backend; the local row matches the server copy.
    case synced

    /// The last push attempt failed; eligible for retry.
    case failed
}
