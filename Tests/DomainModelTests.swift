import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-002 Canonical domain models")
struct DomainModelTests {
    @Test("ENT-001 and ENT-002 retain canonical fields and ownership")
    func canonicalFields() {
        let counterID = UUID()
        let counter = Counter(id: counterID, name: "Water", color: "blue", archived: false)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let event = Event(id: UUID(), occurredAt: date, counterID: counterID)
        let snapshot = SmallCountSnapshot(schemaVersion: 1, counters: [counter], events: [event])
        #expect(snapshot.counters == [counter])
        #expect(snapshot.events == [event])
        #expect(EventDraft() == EventDraft())
    }
}
