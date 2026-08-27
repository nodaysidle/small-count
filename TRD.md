# Small Count — Technical Contract

> Canonical schema 4.0.0 · prompt 4.0.0 · preset `native-macos-menu-bar`

## Exact implementation stack

- Swift 6
- SwiftUI
- AppKit
- Observation
- Foundation
- OSLog
- Swift Testing
- MenuBarExtra
- Foundation Date, Calendar, and TimeZone
- SwiftData
- NSSavePanel

## Delivery identity

- Display name: `Small Count`
- Executable: `SmallCount`
- Bundle identifier: `com.nodaysidle.smallcount`
- Version: `0.1.0` (`1`)
- Minimum macOS: `15.0`
- Application bundle: `build/Small Count.app`
- LSUIElement: `true`
- Entitlements: none

No framework, database, package, or service outside this list may be introduced without an approved contract change.

## Canonical models

### ENT-001 — `Counter`

A manual counter with a name and color.

| Field | Type | Required | Role |
|---|---|---|---|
| `id` | `UUID` | yes | `identity` |
| `name` | `String` | yes | `user` |
| `color` | `String` | no | `user` |
| `archived` | `Bool` | yes | `archiveState` |

Persistence: Persist through the product-core store with versioned migration and last-valid-state recovery.

### ENT-002 — `Event`

A single recorded event for a counter.

| Field | Type | Required | Role |
|---|---|---|---|
| `id` | `UUID` | yes | `identity` |
| `occurredAt` | `Date` | yes | `timestamp` |
| `counterID` | `UUID` | yes | `ownerReference` |

Persistence: Persist through the product-core store with versioned migration and last-valid-state recovery.

## Canonical relationships

| ID | Name | Source | Target | Cardinality | Ownership | Properties |
|---|---|---|---|---|---|---|
| REL-001 | `counterEvents` | ENT-001 | ENT-002 | `oneToMany` | `sourceOwnsTarget` | `counterEvents` / `counterID` |

## Supporting value types

### `CounterDraft`

Kind: `structure`

| Field | Type | Required | Role |
|---|---|---|---|
| `name` | `String` | yes | `user` |
| `color` | `String` | no | `user` |

### `CounterChanges`

Kind: `structure`

| Field | Type | Required | Role |
|---|---|---|---|
| `name` | `String` | no | `user` |
| `color` | `String` | no | `user` |

### `EventDraft`

Kind: `structure`

| Field | Type | Required | Role |
|---|---|---|---|

### `ViewTodaySTotalsResult`

Kind: `structure`

| Field | Type | Required | Role |
|---|---|---|---|
| `counter` | `Counter` | yes | `user` |
| `dayStart` | `Date` | yes | `timestamp` |
| `dayEnd` | `Date` | yes | `timestamp` |
| `timeZoneIdentifier` | `String` | yes | `user` |
| `total` | `Int` | yes | `user` |

### `SmallCountSnapshot`

Kind: `structure`

| Field | Type | Required | Role |
|---|---|---|---|
| `schemaVersion` | `Int` | yes | `user` |
| `counters` | `[Counter]` | yes | `user` |
| `events` | `[Event]` | yes | `user` |

## Enforced invariants

### INV-001 — `reversibleState`

Change archived reversibly without deleting the record.

- Entity: ENT-001
- Fields: `archived`
- Scope: none
- Test: `Tests/Invariants/Invariant001Tests.swift`
- Validation: `swift test --filter Invariant001Tests`

## Typed operations

### OP-001 — F-001

`func createCounter(draft: CounterDraft) async throws -> Counter`

- Mutation: create
- Cardinality: one
- Transaction: singleRecord
- Precondition: Inputs are validated before execution.
- Postcondition: A new Counter is persisted.
- Errors: If name is empty, show validation error and do not create
- Implementation: `Sources/MenuBarFeatures/CreateCounter/CreateCounterFeature.swift`
- Test: `Tests/CreateCounterFeatureTests.swift`
- Validation: `swift test --filter CreateCounterFeatureTests`

### OP-002 — F-002

`func editCounter(id: UUID, changes: CounterChanges) async throws -> Counter`

- Mutation: update
- Cardinality: one
- Transaction: singleRecord
- Precondition: Inputs are validated before execution.
- Postcondition: Only the selected Counter is updated.
- Errors: If save fails, show retry without losing previous state
- Implementation: `Sources/MenuBarFeatures/EditCounter/EditCounterFeature.swift`
- Test: `Tests/EditCounterFeatureTests.swift`
- Validation: `swift test --filter EditCounterFeatureTests`

### OP-003 — F-003

`func recordEvent(scopeID: UUID, draft: EventDraft) async throws -> Event`

- Mutation: create
- Cardinality: one
- Transaction: singleRecord
- Precondition: scopeID is the only owner authority when a scope is present.
- Postcondition: A new Event is persisted.
- Postcondition: occurredAt = Local time currentInstant; callers cannot supply this timestamp.
- Errors: If save fails, show retry without losing the event
- Implementation: `Sources/MenuBarFeatures/RecordEvent/RecordEventFeature.swift`
- Test: `Tests/RecordEventFeatureTests.swift`
- Validation: `swift test --filter RecordEventFeatureTests`

### OP-004 — F-004

`func viewTodaySTotals(scopeID: UUID) async throws -> ViewTodaySTotalsResult`

- Mutation: aggregate
- Cardinality: one
- Transaction: none
- Precondition: scopeID identifies the grouping scope.
- Postcondition: Local time currentInstant is captured once and passed to dayInterval.
- Postcondition: dayStart and dayEnd are the returned current local day interval for occurredAt.
- Postcondition: timeZoneIdentifier is captured once from Local time for the same aggregation.
- Postcondition: total is the exact record count for Event records in the current local day.
- Postcondition: The result identifies grouping scope scopeID as Counter.
- Errors: If data cannot be read, show placeholder and allow retry
- Implementation: `Sources/MenuBarFeatures/ViewTodaySTotals/ViewTodaySTotalsFeature.swift`
- Test: `Tests/ViewTodaySTotalsFeatureTests.swift`
- Validation: `swift test --filter ViewTodaySTotalsFeatureTests`

### OP-005 — F-005

`func archiveCounter(id: UUID) async throws -> Counter`

- Mutation: update
- Cardinality: one
- Transaction: singleRecord
- Precondition: Inputs are validated before execution.
- Postcondition: archived = true
- Errors: If archive fails, show retry and keep counter active
- Implementation: `Sources/MenuBarFeatures/ArchiveCounter/ArchiveCounterFeature.swift`
- Test: `Tests/ArchiveCounterFeatureTests.swift`
- Validation: `swift test --filter ArchiveCounterFeatureTests`

### OP-006 — F-006

`func restoreCounter(id: UUID) async throws -> Counter`

- Mutation: update
- Cardinality: one
- Transaction: singleRecord
- Precondition: Inputs are validated before execution.
- Postcondition: archived = false
- Errors: If restore fails, show retry and keep counter archived
- Implementation: `Sources/MenuBarFeatures/RestoreCounter/RestoreCounterFeature.swift`
- Test: `Tests/RestoreCounterFeatureTests.swift`
- Validation: `swift test --filter RestoreCounterFeatureTests`

### OP-007 — F-007

`func listActiveCounters() async throws -> [Counter]`

- Mutation: read
- Cardinality: many
- Transaction: none
- Precondition: Inputs are validated before execution.
- Postcondition: Only Counter records with archived = false are returned.
- Errors: If read fails, show error with retry
- Implementation: `Sources/MenuBarFeatures/ListActiveCounters/ListActiveCountersFeature.swift`
- Test: `Tests/ListActiveCountersFeatureTests.swift`
- Validation: `swift test --filter ListActiveCountersFeatureTests`

### OP-008 — F-008

`func listArchivedCounters() async throws -> [Counter]`

- Mutation: read
- Cardinality: many
- Transaction: none
- Precondition: Inputs are validated before execution.
- Postcondition: Only Counter records with archived = true are returned.
- Errors: If read fails, show error with retry
- Implementation: `Sources/MenuBarFeatures/ListArchivedCounters/ListArchivedCountersFeature.swift`
- Test: `Tests/ListArchivedCountersFeatureTests.swift`
- Validation: `swift test --filter ListArchivedCountersFeatureTests`

### OP-009 — F-009

`func exportCounterHistory(selectionID: UUID, destination: URL) async throws -> URL`

- Mutation: export
- Cardinality: one
- Transaction: none
- Precondition: Inputs are validated before execution.
- Postcondition: One UTF-8 Markdown file is written at destination using EXPORT-009.
- Postcondition: The selected aggregate preserves ordered Events.
- Errors: If export fails, show error and allow retry
- Implementation: `Sources/MenuBarFeatures/ExportCounterHistory/ExportCounterHistoryFeature.swift`
- Test: `Tests/ExportCounterHistoryFeatureTests.swift`
- Validation: `swift test --filter ExportCounterHistoryFeatureTests`

### OP-010 — F-010

`func openSettings() async throws -> Void`

- Mutation: invoke
- Cardinality: none
- Transaction: none
- Precondition: Inputs are validated before execution.
- Postcondition: The app Settings scene is presented.
- Errors: If Settings cannot open, show error
- Implementation: `Sources/MenuBarFeatures/OpenSettings/OpenSettingsFeature.swift`
- Test: `Tests/OpenSettingsFeatureTests.swift`
- Validation: `swift test --filter OpenSettingsFeatureTests`

### OP-011 — F-011

`func quitApplication() async throws -> Void`

- Mutation: invoke
- Cardinality: none
- Transaction: none
- Precondition: Inputs are validated before execution.
- Postcondition: Ordinary application termination is requested.
- Errors: If quit fails, show error and keep app running
- Implementation: `Sources/MenuBarFeatures/QuitApplication/QuitApplicationFeature.swift`
- Test: `Tests/QuitApplicationFeatureTests.swift`
- Validation: `swift test --filter QuitApplicationFeatureTests`

## Capability adapter contracts

### `Local time`

- Technology: `Foundation Date, Calendar, and TimeZone`
- Implementation: `Sources/Platform/LocalTimeAdapter.swift`
- Test: `Tests/Platform/LocalTimeAdapterTests.swift`
- Validation: `swift test --filter LocalTimeAdapterTests`
- Permission: Read system time only through the app-owned Local time adapter; no permission prompt is permitted.
- Denial: An unavailable calendar or time zone publishes no partial aggregate or timestamped record.
- Cancellation: Cancellation discards the captured temporal context before model mutation.
- Recovery: A temporal failure preserves the last valid state and permits retry with a newly captured context.

#### CAP-OP-LocalTime-001

- Operation: `func currentInstant() async throws -> Date`
- Mutation: read
- Cardinality: one
- Transaction: none
- Precondition: Read system time only through the app-owned Local time adapter; no permission prompt is permitted.
- Effect: One current instant is returned from the injected clock.
- Errors: An unavailable calendar or time zone publishes no partial aggregate or timestamped record.; A temporal failure preserves the last valid state and permits retry with a newly captured context.

#### CAP-OP-LocalTime-002

- Operation: `func currentTimeZoneIdentifier() async throws -> String`
- Mutation: read
- Cardinality: one
- Transaction: none
- Precondition: Read system time only through the app-owned Local time adapter; no permission prompt is permitted.
- Effect: One system time-zone identifier is captured for the complete operation.
- Errors: An unavailable calendar or time zone publishes no partial aggregate or timestamped record.; A temporal failure preserves the last valid state and permits retry with a newly captured context.

#### CAP-OP-LocalTime-003

- Operation: `func dayInterval(containing: Date) async throws -> DateInterval`
- Mutation: read
- Cardinality: one
- Transaction: none
- Precondition: Read system time only through the app-owned Local time adapter; no permission prompt is permitted.
- Effect: The local calendar day interval is derived without fixed-duration arithmetic.
- Errors: An unavailable calendar or time zone publishes no partial aggregate or timestamped record.; A temporal failure preserves the last valid state and permits retry with a newly captured context.

### `Structured persistence`

- Technology: `SwiftData`
- Implementation: `Sources/Platform/StructuredPersistenceAdapter.swift`
- Test: `Tests/Platform/StructuredPersistenceAdapterTests.swift`
- Validation: `swift test --filter StructuredPersistenceAdapterTests`
- Permission: Authorize only the app-owned SwiftData store; no user permission prompt is permitted.
- Denial: A store denial leaves the prior persisted snapshot unchanged.
- Cancellation: Cancellation rolls back the SwiftData transaction before publication.
- Recovery: A SwiftData failure reloads the last valid snapshot and permits retry.

#### CAP-OP-StructuredPersistence-001

- Operation: `func loadSnapshot() async throws -> SmallCountSnapshot`
- Mutation: load
- Cardinality: one
- Transaction: none
- Precondition: Authorize only the app-owned SwiftData store; no user permission prompt is permitted.
- Effect: A fully migrated SmallCountSnapshot is returned before feature mutations are enabled.
- Errors: A store denial leaves the prior persisted snapshot unchanged.; A SwiftData failure reloads the last valid snapshot and permits retry.

#### CAP-OP-StructuredPersistence-002

- Operation: `func saveSnapshot(snapshot: SmallCountSnapshot) async throws -> Void`
- Mutation: save
- Cardinality: none
- Transaction: aggregate
- Precondition: Authorize only the app-owned SwiftData store; no user permission prompt is permitted.
- Effect: The complete SmallCountSnapshot is committed atomically before publication.
- Errors: A store denial leaves the prior persisted snapshot unchanged.; A SwiftData failure reloads the last valid snapshot and permits retry.

#### CAP-OP-StructuredPersistence-003

- Operation: `func migrateStore(fromVersion: Int, toVersion: Int) async throws -> SmallCountSnapshot`
- Mutation: migrate
- Cardinality: one
- Transaction: aggregate
- Precondition: Authorize only the app-owned SwiftData store; no user permission prompt is permitted.
- Effect: Every ordered migration completes atomically and returns the current SmallCountSnapshot.
- Errors: A store denial leaves the prior persisted snapshot unchanged.; A SwiftData failure reloads the last valid snapshot and permits retry.

### `User-selected file export`

- Technology: `NSSavePanel`
- Implementation: `Sources/Platform/UserSelectedFileExportAdapter.swift`
- Test: `Tests/Platform/UserSelectedFileExportAdapterTests.swift`
- Validation: `swift test --filter UserSelectedFileExportAdapterTests`
- Permission: Present NSSavePanel only from the explicit export action.
- Denial: Panel denial or cancellation writes no file and changes no state.
- Cancellation: Closing NSSavePanel discards the pending destination.
- Recovery: A failed export can reopen NSSavePanel without losing app-owned data.

#### CAP-OP-UserSelectedFileExport-001

- Operation: `func selectExportDestination(suggestedName: String) async throws -> URL`
- Mutation: select
- Cardinality: one
- Transaction: none
- Precondition: Present NSSavePanel only from the explicit export action.
- Effect: Exactly one user-selected destination URL is returned without writing it.
- Errors: Panel denial or cancellation writes no file and changes no state.; A failed export can reopen NSSavePanel without losing app-owned data.

## Deterministic Markdown export contracts

### EXPORT-009 — F-009

- Root entity: ENT-001
- Format version: 1
- Encoding: `UTF-8`
- Byte-order mark: excluded
- Line ending: `LF`
- Trailing newline: required
- Timestamp encoding: `ISO-8601 UTC with fixed milliseconds`
- Record ordering: `declared entity order, then ascending UUID string within each entity`
- Document heading: `# Swiftpiler Markdown Export v1`
- Entity heading template: `## Entity: {canonicalSwiftTypeName}`
- Record heading template: `### Record: {lowercase-hyphenated-uuid}`
- Field line template: `- `{fieldName}`: {canonicalScalar}`
- Empty entity line: `_No records._`
- Section separator: `one empty LF line between document heading, entity sections, and records`
- Scalar encoding: `canonical JSON scalar: quoted JSON string with slash unescaped and control characters escaped, lowercase true or false, base-10 Int, finite shortest-round-trip Double, or null`
- Null literal: `null`
- Implementation: `Sources/Platform/MarkdownExport/ExportCounterHistoryMarkdownExport.swift`
- Test: `Tests/Platform/MarkdownExport/ExportCounterHistoryMarkdownExportTests.swift`
- Validation: `swift test --filter ExportCounterHistoryMarkdownExportTests`

| Entity | Ordered fields |
|---|---|
| ENT-001 | `id`, `name`, `color`, `archived` |
| ENT-002 | `id`, `occurredAt`, `counterID` |

## Interface implementation contracts

### UIR-001 — keyboard

- Implementation: `Sources/App/Interface/KeyboardContract.swift`
- Test: `Tests/Interface/KeyboardContractTests.swift`
- Validation: `swift test --filter KeyboardContractTests`

### UIR-002 — voiceOver

- Implementation: `Sources/App/Interface/VoiceOverContract.swift`
- Test: `Tests/Interface/VoiceOverContractTests.swift`
- Validation: `swift test --filter VoiceOverContractTests`

### UIR-003 — reducedMotion

- Implementation: `Sources/App/Interface/ReducedMotionContract.swift`
- Test: `Tests/Interface/ReducedMotionContractTests.swift`
- Validation: `swift test --filter ReducedMotionContractTests`

### UIR-004 — appearance

- Implementation: `Sources/App/Interface/AppearanceContract.swift`
- Test: `Tests/Interface/AppearanceContractTests.swift`
- Validation: `swift test --filter AppearanceContractTests`

### UIR-005 — windowBehavior

- Implementation: `Sources/App/Interface/WindowBehaviorContract.swift`
- Test: `Tests/Interface/WindowBehaviorContractTests.swift`
- Validation: `swift test --filter WindowBehaviorContractTests`

### UIR-006 — confirmation

- Implementation: `Sources/App/Interface/ConfirmationContract.swift`
- Test: `Tests/Interface/ConfirmationContractTests.swift`
- Validation: `swift test --filter ConfirmationContractTests`

### UIR-007 — cancellation

- Implementation: `Sources/App/Interface/CancellationContract.swift`
- Test: `Tests/Interface/CancellationContractTests.swift`
- Validation: `swift test --filter CancellationContractTests`

### UIR-008 — errorRecovery

- Implementation: `Sources/App/Interface/ErrorRecoveryContract.swift`
- Test: `Tests/Interface/ErrorRecoveryContractTests.swift`
- Validation: `swift test --filter ErrorRecoveryContractTests`

## Platform lifecycle

- Launch through `MenuBarExtra`; provide Settings and Quit commands and no ordinary window unless explicitly required.
- Restore state before enabling menu actions and cancel owned work when the menu-bar scene terminates.
- Respect VoiceOver, keyboard navigation, light/dark appearance, and reduced-motion preferences.

## Canonical trace matrix

| Feature | Entity | Component | Flow | Operation | Module | Task | Test | Validation |
|---|---|---|---|---|---|---|---|---|
| F-001 | ENT-001 | COMP-001 | FLOW-001 | OP-001 | MOD-001 | TASK-003 | `Tests/CreateCounterFeatureTests.swift` | `swift test --filter CreateCounterFeatureTests` |
| F-002 | ENT-001 | COMP-002 | FLOW-002 | OP-002 | MOD-002 | TASK-004 | `Tests/EditCounterFeatureTests.swift` | `swift test --filter EditCounterFeatureTests` |
| F-003 | ENT-002 | COMP-003 | FLOW-003 | OP-003 | MOD-003 | TASK-005 | `Tests/RecordEventFeatureTests.swift` | `swift test --filter RecordEventFeatureTests` |
| F-004 | ENT-002 | COMP-004 | FLOW-004 | OP-004 | MOD-004 | TASK-006 | `Tests/ViewTodaySTotalsFeatureTests.swift` | `swift test --filter ViewTodaySTotalsFeatureTests` |
| F-005 | ENT-001 | COMP-005 | FLOW-005 | OP-005 | MOD-005 | TASK-007 | `Tests/ArchiveCounterFeatureTests.swift` | `swift test --filter ArchiveCounterFeatureTests` |
| F-006 | ENT-001 | COMP-006 | FLOW-006 | OP-006 | MOD-006 | TASK-008 | `Tests/RestoreCounterFeatureTests.swift` | `swift test --filter RestoreCounterFeatureTests` |
| F-007 | ENT-001 | COMP-007 | FLOW-007 | OP-007 | MOD-007 | TASK-009 | `Tests/ListActiveCountersFeatureTests.swift` | `swift test --filter ListActiveCountersFeatureTests` |
| F-008 | ENT-001 | COMP-008 | FLOW-008 | OP-008 | MOD-008 | TASK-010 | `Tests/ListArchivedCountersFeatureTests.swift` | `swift test --filter ListArchivedCountersFeatureTests` |
| F-009 | ENT-001 | COMP-009 | FLOW-009 | OP-009 | MOD-009 | TASK-011 | `Tests/ExportCounterHistoryFeatureTests.swift` | `swift test --filter ExportCounterHistoryFeatureTests` |
| F-010 | ENT-001 | COMP-010 | FLOW-010 | OP-010 | MOD-010 | TASK-012 | `Tests/OpenSettingsFeatureTests.swift` | `swift test --filter OpenSettingsFeatureTests` |
| F-011 | ENT-001 | COMP-011 | FLOW-011 | OP-011 | MOD-011 | TASK-013 | `Tests/QuitApplicationFeatureTests.swift` | `swift test --filter QuitApplicationFeatureTests` |
