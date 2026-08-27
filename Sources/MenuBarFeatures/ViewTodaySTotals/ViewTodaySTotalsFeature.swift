import Foundation

// MOD-004 · COMP-004 · FLOW-004 · OP-004 · F-004
@MainActor
struct ViewTodaySTotalsFeature {
    let store: SmallCountStore
    let localTime: any LocalTimeProviding

    func viewTodaySTotals(scopeID: UUID) async throws -> ViewTodaySTotalsResult {
        guard let counter = store.snapshot.counters.first(where: { $0.id == scopeID }) else {
            throw SmallCountError.counterNotFound
        }
        let currentInstant = try await localTime.currentInstant()
        let timeZoneIdentifier = try await localTime.currentTimeZoneIdentifier()
        let interval = try await localTime.dayInterval(containing: currentInstant)
        try Task.checkCancellation()
        let total = store.snapshot.events.lazy.filter {
            $0.counterID == scopeID
                && $0.occurredAt >= interval.start
                && $0.occurredAt < interval.end
        }.count
        return ViewTodaySTotalsResult(
            counter: counter,
            dayStart: interval.start,
            dayEnd: interval.end,
            timeZoneIdentifier: timeZoneIdentifier,
            total: total
        )
    }
}
