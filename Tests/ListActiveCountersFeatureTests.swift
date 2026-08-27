import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-009 F-007 List Active Counters")
struct ListActiveCountersFeatureTests {
    @Test("returns active counters only in stable name order")
    @MainActor
    func activeOnly() async throws {
        let counters = [
            Counter(name: "Zulu", color: nil),
            Counter(name: "Archived", color: nil, archived: true),
            Counter(name: "Alpha", color: nil)
        ]
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: counters, events: []))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let result = try await ListActiveCountersFeature(store: store).listActiveCounters()
        #expect(result.map(\.name) == ["Alpha", "Zulu"])
    }
}
