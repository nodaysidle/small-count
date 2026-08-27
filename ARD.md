# Small Count — Architecture Contract

> Canonical schema 4.0.0 · prompt 4.0.0 · preset `native-macos-menu-bar`

## Architecture boundary

- Application form: macOS Menu Bar
- One local product core owns state transitions and business invariants.
- Presentation calls typed operations; it does not access persistence or platform services directly.
- Cancellation, denial, and adapter failure preserve the last valid state.

## Components

### COMP-001 — Create Counter component

- Owns feature: F-001
- Module: MOD-001
- Source: `Sources/MenuBarFeatures/CreateCounter/CreateCounterFeature.swift`
- Responsibility: Add a new counter with a name and optional color.

### COMP-002 — Edit Counter component

- Owns feature: F-002
- Module: MOD-002
- Source: `Sources/MenuBarFeatures/EditCounter/EditCounterFeature.swift`
- Responsibility: Modify the name or color of an existing counter.

### COMP-003 — Record Event component

- Owns feature: F-003
- Module: MOD-003
- Source: `Sources/MenuBarFeatures/RecordEvent/RecordEventFeature.swift`
- Responsibility: Record one event for the selected active counter from the menu.

### COMP-004 — View Today's Totals component

- Owns feature: F-004
- Module: MOD-004
- Source: `Sources/MenuBarFeatures/ViewTodaySTotals/ViewTodaySTotalsFeature.swift`
- Responsibility: Display today's count for each active counter in the menu.

### COMP-005 — Archive Counter component

- Owns feature: F-005
- Module: MOD-005
- Source: `Sources/MenuBarFeatures/ArchiveCounter/ArchiveCounterFeature.swift`
- Responsibility: Move a counter to archived state, hiding it from the active menu list.

### COMP-006 — Restore Counter component

- Owns feature: F-006
- Module: MOD-006
- Source: `Sources/MenuBarFeatures/RestoreCounter/RestoreCounterFeature.swift`
- Responsibility: Bring an archived counter back to active state.

### COMP-007 — List Active Counters component

- Owns feature: F-007
- Module: MOD-007
- Source: `Sources/MenuBarFeatures/ListActiveCounters/ListActiveCountersFeature.swift`
- Responsibility: Show all active counters in the menu.

### COMP-008 — List Archived Counters component

- Owns feature: F-008
- Module: MOD-008
- Source: `Sources/MenuBarFeatures/ListArchivedCounters/ListArchivedCountersFeature.swift`
- Responsibility: Show archived counters in Settings for management.

### COMP-009 — Export Counter History component

- Owns feature: F-009
- Module: MOD-009
- Source: `Sources/MenuBarFeatures/ExportCounterHistory/ExportCounterHistoryFeature.swift`
- Responsibility: Export one selected counter with its complete event history as a UTF-8 Markdown file to a user-selected location.

### COMP-010 — Open Settings component

- Owns feature: F-010
- Module: MOD-010
- Source: `Sources/MenuBarFeatures/OpenSettings/OpenSettingsFeature.swift`
- Responsibility: Open the app's Settings window.

### COMP-011 — Quit Application component

- Owns feature: F-011
- Module: MOD-011
- Source: `Sources/MenuBarFeatures/QuitApplication/QuitApplicationFeature.swift`
- Responsibility: Quit the app.

## Runtime flows

### FLOW-001 — Create Counter

1. The user activates F-001 through the selected native shell.
2. The presentation layer validates input and invokes OP-001 `createCounter`.
3. The product core applies the create contract to ENT-001 within `singleRecord`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: A new Counter is persisted.
6. Success publishes the new valid state; failure presents: If name is empty, show validation error and do not create

### FLOW-002 — Edit Counter

1. The user activates F-002 through the selected native shell.
2. The presentation layer validates input and invokes OP-002 `editCounter`.
3. The product core applies the update contract to ENT-001 within `singleRecord`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: Only the selected Counter is updated.
6. Success publishes the new valid state; failure presents: If save fails, show retry without losing previous state

### FLOW-003 — Record Event

1. The user activates F-003 through the selected native shell.
2. The presentation layer validates input and invokes OP-003 `recordEvent`.
3. The product core applies the create contract to ENT-002 within `singleRecord`.
4. Preconditions: scopeID is the only owner authority when a scope is present.
5. Postconditions: A new Event is persisted.; occurredAt = Local time currentInstant; callers cannot supply this timestamp.
6. Success publishes the new valid state; failure presents: If save fails, show retry without losing the event

### FLOW-004 — View Today's Totals

1. The user activates F-004 through the selected native shell.
2. The presentation layer validates input and invokes OP-004 `viewTodaySTotals`.
3. The product core applies the aggregate contract to ENT-002 within `none`.
4. Preconditions: scopeID identifies the grouping scope.
5. Postconditions: Local time currentInstant is captured once and passed to dayInterval.; dayStart and dayEnd are the returned current local day interval for occurredAt.; timeZoneIdentifier is captured once from Local time for the same aggregation.; total is the exact record count for Event records in the current local day.; The result identifies grouping scope scopeID as Counter.
6. Success publishes the new valid state; failure presents: If data cannot be read, show placeholder and allow retry

### FLOW-005 — Archive Counter

1. The user activates F-005 through the selected native shell.
2. The presentation layer validates input and invokes OP-005 `archiveCounter`.
3. The product core applies the update contract to ENT-001 within `singleRecord`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: archived = true
6. Success publishes the new valid state; failure presents: If archive fails, show retry and keep counter active

### FLOW-006 — Restore Counter

1. The user activates F-006 through the selected native shell.
2. The presentation layer validates input and invokes OP-006 `restoreCounter`.
3. The product core applies the update contract to ENT-001 within `singleRecord`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: archived = false
6. Success publishes the new valid state; failure presents: If restore fails, show retry and keep counter archived

### FLOW-007 — List Active Counters

1. The user activates F-007 through the selected native shell.
2. The presentation layer validates input and invokes OP-007 `listActiveCounters`.
3. The product core applies the read contract to ENT-001 within `none`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: Only Counter records with archived = false are returned.
6. Success publishes the new valid state; failure presents: If read fails, show error with retry

### FLOW-008 — List Archived Counters

1. The user activates F-008 through the selected native shell.
2. The presentation layer validates input and invokes OP-008 `listArchivedCounters`.
3. The product core applies the read contract to ENT-001 within `none`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: Only Counter records with archived = true are returned.
6. Success publishes the new valid state; failure presents: If read fails, show error with retry

### FLOW-009 — Export Counter History

1. The user activates F-009 through the selected native shell.
2. The presentation layer validates input and invokes OP-009 `exportCounterHistory`.
3. The product core applies the export contract to ENT-001 within `none`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: One UTF-8 Markdown file is written at destination using EXPORT-009.; The selected aggregate preserves ordered Events.
6. Success publishes the new valid state; failure presents: If export fails, show error and allow retry

### FLOW-010 — Open Settings

1. The user activates F-010 through the selected native shell.
2. The presentation layer validates input and invokes OP-010 `openSettings`.
3. The product core applies the invoke contract to ENT-001 within `none`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: The app Settings scene is presented.
6. Success publishes the new valid state; failure presents: If Settings cannot open, show error

### FLOW-011 — Quit Application

1. The user activates F-011 through the selected native shell.
2. The presentation layer validates input and invokes OP-011 `quitApplication`.
3. The product core applies the invoke contract to ENT-001 within `none`.
4. Preconditions: Inputs are validated before execution.
5. Postconditions: Ordinary application termination is requested.
6. Success publishes the new valid state; failure presents: If quit fails, show error and keep app running

## Capability boundaries

- **Structured persistence:** required; features: Create Counter, Edit Counter, Record Event, View Today's Totals, Archive Counter, Restore Counter, List Active Counters, List Archived Counters, Export Counter History.
- **User-selected file import:** excluded; features: none.
- **User-selected file export:** required; features: Export Counter History.
- **Persistent external file access:** excluded; features: none.
- **Document rendering:** excluded; features: none.
- **Network access:** excluded; features: none.
- **Credential storage:** excluded; features: none.
- **Notifications:** excluded; features: none.
- **Microphone capture:** excluded; features: none.
- **Speech recognition:** excluded; features: none.
- **Clipboard read:** excluded; features: none.
- **Clipboard write:** excluded; features: none.
- **Global shortcuts:** excluded; features: none.
- **Background execution:** excluded; features: none.
- **Local time:** required; features: Record Event, View Today's Totals.
- `Local time` uses `Foundation Date, Calendar, and TimeZone` at `Sources/Platform/LocalTimeAdapter.swift`; permission: Read system time only through the app-owned Local time adapter; no permission prompt is permitted.; denial: An unavailable calendar or time zone publishes no partial aggregate or timestamped record.; cancellation: Cancellation discards the captured temporal context before model mutation.; recovery: A temporal failure preserves the last valid state and permits retry with a newly captured context..
  - `func currentInstant() async throws -> Date`; effect: One current instant is returned from the injected clock.
  - `func currentTimeZoneIdentifier() async throws -> String`; effect: One system time-zone identifier is captured for the complete operation.
  - `func dayInterval(containing: Date) async throws -> DateInterval`; effect: The local calendar day interval is derived without fixed-duration arithmetic.
- `Structured persistence` uses `SwiftData` at `Sources/Platform/StructuredPersistenceAdapter.swift`; permission: Authorize only the app-owned SwiftData store; no user permission prompt is permitted.; denial: A store denial leaves the prior persisted snapshot unchanged.; cancellation: Cancellation rolls back the SwiftData transaction before publication.; recovery: A SwiftData failure reloads the last valid snapshot and permits retry..
  - `func loadSnapshot() async throws -> SmallCountSnapshot`; effect: A fully migrated SmallCountSnapshot is returned before feature mutations are enabled.
  - `func saveSnapshot(snapshot: SmallCountSnapshot) async throws -> Void`; effect: The complete SmallCountSnapshot is committed atomically before publication.
  - `func migrateStore(fromVersion: Int, toVersion: Int) async throws -> SmallCountSnapshot`; effect: Every ordered migration completes atomically and returns the current SmallCountSnapshot.
- `User-selected file export` uses `NSSavePanel` at `Sources/Platform/UserSelectedFileExportAdapter.swift`; permission: Present NSSavePanel only from the explicit export action.; denial: Panel denial or cancellation writes no file and changes no state.; cancellation: Closing NSSavePanel discards the pending destination.; recovery: A failed export can reopen NSSavePanel without losing app-owned data..
  - `func selectExportDestination(suggestedName: String) async throws -> URL`; effect: Exactly one user-selected destination URL is returned without writing it.

## Data ownership

- ENT-001 `Counter`: app-owned persisted state; A manual counter with a name and color.
- ENT-002 `Event`: app-owned persisted state; A single recorded event for a counter.

## Relationship ownership

- REL-001 `counterEvents`: ENT-001 → ENT-002; `sourceOwnsTarget`; `oneToMany`; preservation is required unless an explicit destructive contract says otherwise.

## Interface ownership

- UIR-001 is owned at `Sources/App/Interface/KeyboardContract.swift`, verified at `Tests/Interface/KeyboardContractTests.swift`, and validated with `swift test --filter KeyboardContractTests`.
- UIR-002 is owned at `Sources/App/Interface/VoiceOverContract.swift`, verified at `Tests/Interface/VoiceOverContractTests.swift`, and validated with `swift test --filter VoiceOverContractTests`.
- UIR-003 is owned at `Sources/App/Interface/ReducedMotionContract.swift`, verified at `Tests/Interface/ReducedMotionContractTests.swift`, and validated with `swift test --filter ReducedMotionContractTests`.
- UIR-004 is owned at `Sources/App/Interface/AppearanceContract.swift`, verified at `Tests/Interface/AppearanceContractTests.swift`, and validated with `swift test --filter AppearanceContractTests`.
- UIR-005 is owned at `Sources/App/Interface/WindowBehaviorContract.swift`, verified at `Tests/Interface/WindowBehaviorContractTests.swift`, and validated with `swift test --filter WindowBehaviorContractTests`.
- UIR-006 is owned at `Sources/App/Interface/ConfirmationContract.swift`, verified at `Tests/Interface/ConfirmationContractTests.swift`, and validated with `swift test --filter ConfirmationContractTests`.
- UIR-007 is owned at `Sources/App/Interface/CancellationContract.swift`, verified at `Tests/Interface/CancellationContractTests.swift`, and validated with `swift test --filter CancellationContractTests`.
- UIR-008 is owned at `Sources/App/Interface/ErrorRecoveryContract.swift`, verified at `Tests/Interface/ErrorRecoveryContractTests.swift`, and validated with `swift test --filter ErrorRecoveryContractTests`.

## Markdown export boundaries

- EXPORT-009 owns F-009 at `Sources/Platform/MarkdownExport/ExportCounterHistoryMarkdownExport.swift` with exact canonical Markdown byte grammar: document `# Swiftpiler Markdown Export v1`; entity `## Entity: {canonicalSwiftTypeName}`; record `### Record: {lowercase-hyphenated-uuid}`; field `- `{fieldName}`: {canonicalScalar}`; empty entity `_No records._`; separator `one empty LF line between document heading, entity sections, and records`; scalar `canonical JSON scalar: quoted JSON string with slash unescaped and control characters escaped, lowercase true or false, base-10 Int, finite shortest-round-trip Double, or null`; null `null`; entity order ENT-001, ENT-002; encoding `UTF-8`; byte-order mark excluded; line ending `LF`; trailing newline required; timestamp `ISO-8601 UTC with fixed milliseconds`; record order `declared entity order, then ascending UUID string within each entity`.

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
