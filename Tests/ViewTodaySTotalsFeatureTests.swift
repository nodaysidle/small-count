import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-006 F-004 View Today's Totals")
struct ViewTodaySTotalsFeatureTests {
    @Test("counts exact events in captured local calendar day")
    @MainActor
    func localDayCount() async throws {
        let id = UUID()
        let zone = try #require(TimeZone(identifier: "America/New_York"))
        let now = Date(timeIntervalSince1970: 1_741_508_000)
        let time = FixedLocalTime(instant: now, zone: zone)
        let interval = try await time.dayInterval(containing: now)
        let events = [
            Event(occurredAt: interval.start, counterID: id),
            Event(occurredAt: interval.end.addingTimeInterval(-0.001), counterID: id),
            Event(occurredAt: interval.end, counterID: id)
        ]
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: [.init(id: id, name: "A", color: nil)], events: events))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let result = try await ViewTodaySTotalsFeature(store: store, localTime: time).viewTodaySTotals(scopeID: id)
        #expect(result.total == 2)
        #expect(result.dayStart == interval.start)
        #expect(result.dayEnd == interval.end)
        #expect(result.timeZoneIdentifier == zone.identifier)
    }
}
