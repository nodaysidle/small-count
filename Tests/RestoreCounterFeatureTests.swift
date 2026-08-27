import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-008 F-006 Restore Counter")
struct RestoreCounterFeatureTests {
    @Test("restores archived counter and preserves event history")
    @MainActor
    func restoresReversibly() async throws {
        let id = UUID()
        let event = Event(occurredAt: .now, counterID: id)
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: [.init(id: id, name: "A", color: nil, archived: true)], events: [event]))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let restored = try await RestoreCounterFeature(store: store).restoreCounter(id: id)
        #expect(!restored.archived)
        #expect(store.snapshot.events == [event])
    }
}
