# Small Count — Agent Operating Contract

> Canonical schema 4.0.0 · prompt 4.0.0 · preset `native-macos-menu-bar`

## Authority

- `PRD.md` owns product behavior and acceptance criteria.
- `ARD.md` owns component, flow, resource, and lifecycle boundaries.
- `TRD.md` owns the exact stack, types, operations, paths, and validation commands.
- `TASKS.md` owns dependency-safe execution order.
- This file owns downstream implementation behavior.

## Mandatory workflow

1. Read all five documents before editing.
2. Confirm the selected preset is macOS Menu Bar and reject technology from the unselected shell.
3. Implement tasks in dependency order without inventing features, services, destructive behavior, or dependencies.
4. Preserve exact IDs in tests and review notes so traceability remains auditable.
5. Run each task command and all final commands before packaging.

## Safety and quality gates

- Keep data local unless `Network access` is explicitly required.
- Store credentials only through Keychain when `Credential storage` is required.
- Cancellation and failure preserve the last valid state and release transient resources.
- Archive and restore are Boolean state transitions, never deletion.
- Current-event timestamps come only from the Local time adapter, never from callers.
- Daily totals use one captured calendar and time zone; never assume a day is 86,400 seconds.
- Markdown exports must preserve the exact canonical Markdown byte grammar, entity order, field order, record order, UTF-8/LF policy, and UTC timestamp encoding.
- Do not weaken tests, types, accessibility, validation, signing, or error handling to make a gate pass.
- Stop and request clarification when the five contracts materially conflict.

## Completion evidence

- Required task range: 6–24; this packet contains 16.
- Final test: `swift test`
- Final build: `swift build -c release`
- Final package: `Scripts/package_app.sh`
- Final application: `build/Small Count.app`
- Final signature: `codesign --verify --deep --strict "build/Small Count.app"`

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
