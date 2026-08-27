import Testing
@testable import SmallCount

@Suite("TASK-010 F-008 List Archived Counters")
struct ListArchivedCountersFeatureTests {
    @Test("returns archived counters only")
    @MainActor
    func archivedOnly() async throws {
        let counters = [Counter(name: "Active", color: nil), Counter(name: "Archived", color: nil, archived: true)]
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: counters, events: []))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let result = try await ListArchivedCountersFeature(store: store).listArchivedCounters()
        #expect(result.map(\.name) == ["Archived"])
    }
}
