import Foundation

// MOD-006 · COMP-006 · FLOW-006 · OP-006 · F-006
@MainActor
struct RestoreCounterFeature {
    let store: SmallCountStore

    func restoreCounter(id: UUID) async throws -> Counter {
        try await store.transact { snapshot in
            guard let index = snapshot.counters.firstIndex(where: { $0.id == id }) else {
                throw SmallCountError.counterNotFound
            }
            snapshot.counters[index].archived = false
            return snapshot.counters[index]
        }
    }
}
