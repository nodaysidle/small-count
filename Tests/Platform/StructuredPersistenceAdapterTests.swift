import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-002 SwiftData persistence adapter")
struct StructuredPersistenceAdapterTests {
    @Test("snapshot round trips and migration preserves records")
    @MainActor
    func roundTrip() async throws {
        let adapter = try StructuredPersistenceAdapter(inMemory: true)
        let id = UUID()
        let snapshot = SmallCountSnapshot(schemaVersion: 1, counters: [.init(id: id, name: "Tea", color: nil, archived: false)], events: [.init(id: UUID(), occurredAt: .now, counterID: id)])
        try await adapter.saveSnapshot(snapshot: snapshot)
        #expect(try await adapter.loadSnapshot() == snapshot)
        #expect(try await adapter.migrateStore(fromVersion: 1, toVersion: 1) == snapshot)
    }

    @Test("load performs ordered migration before publishing a snapshot")
    @MainActor
    func migratesOnLoad() async throws {
        let adapter = try StructuredPersistenceAdapter(inMemory: true)
        let legacy = SmallCountSnapshot(
            schemaVersion: 0,
            counters: [Counter(name: "Legacy", color: nil)],
            events: []
        )
        try await adapter.saveSnapshot(snapshot: legacy)

        let loaded = try await adapter.loadSnapshot()
        #expect(loaded.schemaVersion == SmallCountSnapshot.currentSchemaVersion)
        #expect(loaded.counters == legacy.counters)
        #expect(loaded.events == legacy.events)
    }
}
