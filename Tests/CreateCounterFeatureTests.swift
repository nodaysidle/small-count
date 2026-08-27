import Testing
@testable import SmallCount

@Suite("TASK-003 F-001 Create Counter")
struct CreateCounterFeatureTests {
    @Test("creates a validated counter visible in the store")
    @MainActor
    func createsCounter() async throws {
        let persistence = TestPersistence()
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let feature = CreateCounterFeature(store: store)
        let counter = try await feature.createCounter(draft: .init(name: "  Water  ", color: "blue"))
        #expect(counter.name == "Water")
        #expect(store.snapshot.counters == [counter])
    }

    @Test("rejects empty names without mutation")
    @MainActor
    func rejectsEmptyName() async {
        let persistence = TestPersistence()
        let store = SmallCountStore(persistence: persistence)
        let feature = CreateCounterFeature(store: store)
        await #expect(throws: SmallCountError.emptyName) {
            try await feature.createCounter(draft: .init(name: "  ", color: nil))
        }
        #expect(store.snapshot == .empty)
    }
}
