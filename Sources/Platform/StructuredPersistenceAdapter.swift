import Foundation
import SwiftData

@Model
final class StoredSnapshot {
    @Attribute(.unique) var key: String
    var payload: Data

    init(key: String = "current", payload: Data) {
        self.key = key
        self.payload = payload
    }
}

@MainActor
final class StructuredPersistenceAdapter: StructuredPersistenceProviding {
    private let container: ModelContainer
    private let context: ModelContext
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(inMemory: Bool = false) throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        container = try ModelContainer(for: StoredSnapshot.self, configurations: configuration)
        context = container.mainContext
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func loadSnapshot() async throws -> SmallCountSnapshot {
        guard let snapshot = try decodeStoredSnapshot() else { return .empty }
        if snapshot.schemaVersion == SmallCountSnapshot.currentSchemaVersion {
            return snapshot
        }
        return try await migrateStore(
            fromVersion: snapshot.schemaVersion,
            toVersion: SmallCountSnapshot.currentSchemaVersion
        )
    }

    func saveSnapshot(snapshot: SmallCountSnapshot) async throws {
        try Task.checkCancellation()
        let payload = try encoder.encode(snapshot)
        let descriptor = FetchDescriptor<StoredSnapshot>()
        do {
            if let stored = try context.fetch(descriptor).first {
                stored.payload = payload
            } else {
                context.insert(StoredSnapshot(payload: payload))
            }
            try Task.checkCancellation()
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func migrateStore(fromVersion: Int, toVersion: Int) async throws -> SmallCountSnapshot {
        guard toVersion == SmallCountSnapshot.currentSchemaVersion, fromVersion <= toVersion else {
            throw SmallCountError.invalidSchemaVersion
        }
        guard var migrated = try decodeStoredSnapshot() else { return .empty }
        guard migrated.schemaVersion == fromVersion else {
            throw SmallCountError.invalidSchemaVersion
        }
        while migrated.schemaVersion < toVersion {
            switch migrated.schemaVersion {
            case 0:
                migrated.schemaVersion = 1
            default:
                throw SmallCountError.invalidSchemaVersion
            }
        }
        try await saveSnapshot(snapshot: migrated)
        return migrated
    }

    private func decodeStoredSnapshot() throws -> SmallCountSnapshot? {
        let descriptor = FetchDescriptor<StoredSnapshot>()
        guard let stored = try context.fetch(descriptor).first else { return nil }
        return try decoder.decode(SmallCountSnapshot.self, from: stored.payload)
    }
}
