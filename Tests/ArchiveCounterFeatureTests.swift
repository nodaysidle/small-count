import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-007 F-005 Archive Counter")
struct ArchiveCounterFeatureTests {
    @Test("sets archived without deleting history")
    @MainActor
    func archivesReversibly() async throws {
        let id = UUID()
        let event = Event(occurredAt: .now, counterID: id)
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: [.init(id: id, name: "A", color: nil)], events: [event]))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let archived = try await ArchiveCounterFeature(store: store).archiveCounter(id: id)
        #expect(archived.archived)
        #expect(store.snapshot.events == [event])
    }
}
