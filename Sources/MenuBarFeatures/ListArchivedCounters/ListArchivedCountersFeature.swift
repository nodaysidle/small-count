// MOD-008 · COMP-008 · FLOW-008 · OP-008 · F-008
@MainActor
struct ListArchivedCountersFeature {
    let store: SmallCountStore

    func listArchivedCounters() async throws -> [Counter] {
        try Task.checkCancellation()
        return store.snapshot.counters
            .filter(\.archived)
            .sorted { lhs, rhs in
                let comparison = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
                return comparison == .orderedSame
                    ? lhs.id.uuidString < rhs.id.uuidString
                    : comparison == .orderedAscending
            }
    }
}
