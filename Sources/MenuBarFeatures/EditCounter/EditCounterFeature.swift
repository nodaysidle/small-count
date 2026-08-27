import Foundation

// MOD-002 · COMP-002 · FLOW-002 · OP-002 · F-002
@MainActor
struct EditCounterFeature {
    let store: SmallCountStore

    func editCounter(id: UUID, changes: CounterChanges) async throws -> Counter {
        try await store.transact { snapshot in
            guard let index = snapshot.counters.firstIndex(where: { $0.id == id }) else {
                throw SmallCountError.counterNotFound
            }
            if let name = changes.name {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { throw SmallCountError.emptyName }
                snapshot.counters[index].name = trimmed
            }
            snapshot.counters[index].color = changes.color
            return snapshot.counters[index]
        }
    }
}
