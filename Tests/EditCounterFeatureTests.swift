import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-004 F-002 Edit Counter")
struct EditCounterFeatureTests {
    @Test("edits only selected counter and preserves state when save fails")
    @MainActor
    func editAndRollback() async throws {
        let id = UUID()
        let original = Counter(id: id, name: "Water", color: "blue", archived: false)
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: [original], events: []))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let feature = EditCounterFeature(store: store)
        let edited = try await feature.editCounter(id: id, changes: .init(name: "Tea", color: "green"))
        #expect(edited.name == "Tea")
        persistence.saveError = CocoaError(.fileWriteUnknown)
        await #expect(throws: (any Error).self) {
            try await feature.editCounter(id: id, changes: .init(name: "Lost", color: nil))
        }
        #expect(store.snapshot.counters[0] == edited)
    }
}
