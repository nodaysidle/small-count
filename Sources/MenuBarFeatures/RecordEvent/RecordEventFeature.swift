import Foundation

// MOD-003 · COMP-003 · FLOW-003 · OP-003 · F-003
@MainActor
struct RecordEventFeature {
    let store: SmallCountStore
    let localTime: any LocalTimeProviding

    func recordEvent(scopeID: UUID, draft: EventDraft) async throws -> Event {
        guard let counter = store.snapshot.counters.first(where: { $0.id == scopeID }) else {
            throw SmallCountError.counterNotFound
        }
        guard !counter.archived else { throw SmallCountError.counterArchived }
        let occurredAt = try await localTime.currentInstant()
        try Task.checkCancellation()
        let event = Event(occurredAt: occurredAt, counterID: scopeID)
        return try await store.transact { snapshot in
            snapshot.events.append(event)
            return event
        }
    }
}
