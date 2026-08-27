import Foundation
import Observation

protocol LocalTimeProviding: Sendable {
    func currentInstant() async throws -> Date
    func currentTimeZoneIdentifier() async throws -> String
    func dayInterval(containing: Date) async throws -> DateInterval
}

@MainActor
protocol StructuredPersistenceProviding: AnyObject {
    func loadSnapshot() async throws -> SmallCountSnapshot
    func saveSnapshot(snapshot: SmallCountSnapshot) async throws
    func migrateStore(fromVersion: Int, toVersion: Int) async throws -> SmallCountSnapshot
}

@MainActor
protocol UserSelectedFileExportProviding: AnyObject {
    func selectExportDestination(suggestedName: String) async throws -> URL
}

enum PlatformServices {
    static let requiredCapabilities = [
        "Local time",
        "Structured persistence",
        "User-selected file export"
    ]
}

@MainActor
@Observable
final class SmallCountStore {
    private(set) var snapshot: SmallCountSnapshot = .empty
    private let persistence: any StructuredPersistenceProviding

    init(persistence: any StructuredPersistenceProviding) {
        self.persistence = persistence
    }

    func restore() async throws {
        let restored = try await persistence.loadSnapshot()
        try Task.checkCancellation()
        snapshot = restored
    }

    func transact<Result>(
        _ mutation: (inout SmallCountSnapshot) throws -> Result
    ) async throws -> Result {
        var candidate = snapshot
        let result = try mutation(&candidate)
        try Task.checkCancellation()
        try await persistence.saveSnapshot(snapshot: candidate)
        try Task.checkCancellation()
        snapshot = candidate
        return result
    }
}
