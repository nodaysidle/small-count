import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-005 F-003 Record Event")
struct RecordEventFeatureTests {
    @Test("records adapter timestamp only for an active counter")
    @MainActor
    func recordsCurrentInstant() async throws {
        let id = UUID()
        let instant = Date(timeIntervalSince1970: 1_700_000_123)
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: [.init(id: id, name: "Water", color: nil, archived: false)], events: []))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let feature = RecordEventFeature(store: store, localTime: FixedLocalTime(instant: instant, zone: .gmt))
        let event = try await feature.recordEvent(scopeID: id, draft: EventDraft())
        #expect(event.occurredAt == instant)
        #expect(event.counterID == id)
        #expect(store.snapshot.events == [event])
    }

    @Test("rejects recording against an archived counter without mutation")
    @MainActor
    func rejectsArchivedCounter() async throws {
        let counter = Counter(name: "Archived", color: nil, archived: true)
        let persistence = TestPersistence(
            snapshot: SmallCountSnapshot(schemaVersion: 1, counters: [counter], events: [])
        )
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let feature = RecordEventFeature(
            store: store,
            localTime: FixedLocalTime(instant: .now, zone: .gmt)
        )

        await #expect(throws: SmallCountError.self) {
            _ = try await feature.recordEvent(scopeID: counter.id, draft: EventDraft())
        }
        #expect(store.snapshot.events.isEmpty)
    }
}
