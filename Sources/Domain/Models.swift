import Foundation

// ENT-001
struct Counter: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var color: String?
    var archived: Bool

    init(id: UUID = UUID(), name: String, color: String?, archived: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.archived = archived
    }
}

// ENT-002
struct Event: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let occurredAt: Date
    let counterID: UUID

    init(id: UUID = UUID(), occurredAt: Date, counterID: UUID) {
        self.id = id
        self.occurredAt = occurredAt
        self.counterID = counterID
    }
}

struct CounterDraft: Equatable, Sendable {
    var name: String
    var color: String?
}

struct CounterChanges: Equatable, Sendable {
    var name: String?
    var color: String?
}

struct EventDraft: Equatable, Sendable {
    init() {}
}

struct ViewTodaySTotalsResult: Equatable, Sendable {
    let counter: Counter
    let dayStart: Date
    let dayEnd: Date
    let timeZoneIdentifier: String
    let total: Int
}

struct SmallCountSnapshot: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var counters: [Counter]
    var events: [Event]

    static let empty = SmallCountSnapshot(
        schemaVersion: currentSchemaVersion,
        counters: [],
        events: []
    )
}

enum SmallCountError: Error, Equatable, LocalizedError {
    case emptyName
    case counterNotFound
    case counterArchived
    case invalidSchemaVersion
    case persistenceFailed(String)
    case exportFailed(String)
    case settingsUnavailable
    case quitFailed

    var errorDescription: String? {
        switch self {
        case .emptyName: "Counter name cannot be empty."
        case .counterNotFound: "Counter not found."
        case .counterArchived: "Archived counters cannot record events."
        case .invalidSchemaVersion: "The stored data version is unsupported."
        case .persistenceFailed(let message): "Could not save data: \(message)"
        case .exportFailed(let message): "Could not export: \(message)"
        case .settingsUnavailable: "Settings could not be opened."
        case .quitFailed: "Small Count could not quit."
        }
    }
}
