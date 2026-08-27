import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-002 Local time adapter")
struct LocalTimeAdapterTests {
    @Test("uses a captured calendar and timezone for DST day intervals")
    func dstInterval() async throws {
        let instant = Date(timeIntervalSince1970: 1_741_508_000)
        let zone = try #require(TimeZone(identifier: "America/New_York"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let adapter = LocalTimeAdapter(now: { instant }, calendar: calendar, timeZone: zone)
        #expect(try await adapter.currentInstant() == instant)
        #expect(try await adapter.currentTimeZoneIdentifier() == zone.identifier)
        let interval = try await adapter.dayInterval(containing: instant)
        #expect(calendar.dateInterval(of: .day, for: instant) == interval)
    }
}
