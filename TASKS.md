# Small Count — Execution Plan

> Canonical schema 4.0.0 · prompt 4.0.0 · preset `native-macos-menu-bar`

Implement tasks in order. A task is complete only when every acceptance criterion and command passes.

## TASK-001 — Create the native application foundation

Establish the selected native macOS lifecycle and exact build configuration.

- Features: foundation
- Dependencies: none
- Source paths: `Package.swift`, `Sources/App/MenuBarApp.swift`
- Test paths: `Tests/AppLifecycleTests.swift`

Acceptance:

- The selected application lifecycle launches with no unselected-preset shell.

Validation:

- `swift test --filter AppLifecycleTests`
- `swift build`

## TASK-002 — Implement canonical models and platform services

Create typed domain models, persistence boundaries, and required platform adapters.

- Features: foundation
- Dependencies: TASK-001
- Source paths: `Sources/Domain/Models.swift`, `Sources/Platform/PlatformServices.swift`, `Sources/Platform/LocalTimeAdapter.swift`, `Sources/Platform/StructuredPersistenceAdapter.swift`, `Sources/Platform/UserSelectedFileExportAdapter.swift`
- Test paths: `Tests/DomainModelTests.swift`, `Tests/PlatformServicesTests.swift`, `Tests/Invariants/Invariant001Tests.swift`, `Tests/Platform/LocalTimeAdapterTests.swift`, `Tests/Platform/StructuredPersistenceAdapterTests.swift`, `Tests/Platform/UserSelectedFileExportAdapterTests.swift`

Acceptance:

- Models enforce identity, field, relationship, lifecycle, and capability invariants.

Validation:

- `swift test --filter DomainModelTests`
- `swift test --filter PlatformServicesTests`
- `swift test --filter Invariant001Tests`
- `swift test --filter LocalTimeAdapterTests`
- `swift test --filter StructuredPersistenceAdapterTests`
- `swift test --filter UserSelectedFileExportAdapterTests`

## TASK-003 — Implement Create Counter

Add a new counter with a name and optional color.

- Features: F-001
- Dependencies: TASK-002
- Source paths: `Sources/MenuBarFeatures/CreateCounter/CreateCounterFeature.swift`
- Test paths: `Tests/CreateCounterFeatureTests.swift`

Acceptance:

- User can enter a name and choose a color
- Counter appears in the menu and Settings list

Validation:

- `swift test --filter CreateCounterFeatureTests`

## TASK-004 — Implement Edit Counter

Modify the name or color of an existing counter.

- Features: F-002
- Dependencies: TASK-003
- Source paths: `Sources/MenuBarFeatures/EditCounter/EditCounterFeature.swift`
- Test paths: `Tests/EditCounterFeatureTests.swift`

Acceptance:

- User can change name and color
- Changes reflect in menu and Settings

Validation:

- `swift test --filter EditCounterFeatureTests`

## TASK-005 — Implement Record Event

Record one event for the selected active counter from the menu.

- Features: F-003
- Dependencies: TASK-004
- Source paths: `Sources/MenuBarFeatures/RecordEvent/RecordEventFeature.swift`
- Test paths: `Tests/RecordEventFeatureTests.swift`

Acceptance:

- Selecting a counter and choosing 'Record' creates an event with current date/time
- Today's count for that counter increments

Validation:

- `swift test --filter RecordEventFeatureTests`

## TASK-006 — Implement View Today's Totals

Display today's count for each active counter in the menu.

- Features: F-004
- Dependencies: TASK-005
- Source paths: `Sources/MenuBarFeatures/ViewTodaySTotals/ViewTodaySTotalsFeature.swift`
- Test paths: `Tests/ViewTodaySTotalsFeatureTests.swift`

Acceptance:

- Menu shows each active counter with its count for the current local day
- Counts update after recording an event

Validation:

- `swift test --filter ViewTodaySTotalsFeatureTests`

## TASK-007 — Implement Archive Counter

Move a counter to archived state, hiding it from the active menu list.

- Features: F-005
- Dependencies: TASK-006
- Source paths: `Sources/MenuBarFeatures/ArchiveCounter/ArchiveCounterFeature.swift`
- Test paths: `Tests/ArchiveCounterFeatureTests.swift`

Acceptance:

- Archived counters no longer appear in the active menu list
- Archived counters appear in the archived list in Settings

Validation:

- `swift test --filter ArchiveCounterFeatureTests`

## TASK-008 — Implement Restore Counter

Bring an archived counter back to active state.

- Features: F-006
- Dependencies: TASK-007
- Source paths: `Sources/MenuBarFeatures/RestoreCounter/RestoreCounterFeature.swift`
- Test paths: `Tests/RestoreCounterFeatureTests.swift`

Acceptance:

- Restored counter reappears in the active menu list
- Its event history remains intact

Validation:

- `swift test --filter RestoreCounterFeatureTests`

## TASK-009 — Implement List Active Counters

Show all active counters in the menu.

- Features: F-007
- Dependencies: TASK-008
- Source paths: `Sources/MenuBarFeatures/ListActiveCounters/ListActiveCountersFeature.swift`
- Test paths: `Tests/ListActiveCountersFeatureTests.swift`

Acceptance:

- Menu lists all active counters
- Archived counters are excluded

Validation:

- `swift test --filter ListActiveCountersFeatureTests`

## TASK-010 — Implement List Archived Counters

Show archived counters in Settings for management.

- Features: F-008
- Dependencies: TASK-009
- Source paths: `Sources/MenuBarFeatures/ListArchivedCounters/ListArchivedCountersFeature.swift`
- Test paths: `Tests/ListArchivedCountersFeatureTests.swift`

Acceptance:

- Settings shows a list of archived counters
- Each archived counter can be restored

Validation:

- `swift test --filter ListArchivedCountersFeatureTests`

## TASK-011 — Implement Export Counter History

Export one selected counter with its complete event history as a UTF-8 Markdown file to a user-selected location.

- Features: F-009
- Dependencies: TASK-010
- Source paths: `Sources/MenuBarFeatures/ExportCounterHistory/ExportCounterHistoryFeature.swift`, `Sources/Platform/MarkdownExport/ExportCounterHistoryMarkdownExport.swift`
- Test paths: `Tests/ExportCounterHistoryFeatureTests.swift`, `Tests/Platform/MarkdownExport/ExportCounterHistoryMarkdownExportTests.swift`

Acceptance:

- User selects a counter and chooses export destination
- File contains counter name and all events with timestamps
- File is UTF-8 Markdown

Validation:

- `swift test --filter ExportCounterHistoryFeatureTests`
- `swift test --filter ExportCounterHistoryMarkdownExportTests`

## TASK-012 — Implement Open Settings

Open the app's Settings window.

- Features: F-010
- Dependencies: TASK-011
- Source paths: `Sources/MenuBarFeatures/OpenSettings/OpenSettingsFeature.swift`
- Test paths: `Tests/OpenSettingsFeatureTests.swift`

Acceptance:

- Selecting Settings opens the Settings window
- Settings window shows counter management

Validation:

- `swift test --filter OpenSettingsFeatureTests`

## TASK-013 — Implement Quit Application

Quit the app.

- Features: F-011
- Dependencies: TASK-012
- Source paths: `Sources/MenuBarFeatures/QuitApplication/QuitApplicationFeature.swift`
- Test paths: `Tests/QuitApplicationFeatureTests.swift`

Acceptance:

- Selecting Quit terminates the app
- All data is persisted before quitting

Validation:

- `swift test --filter QuitApplicationFeatureTests`

## TASK-014 — Integrate the primary journeys

Connect implemented features through the selected native shell and verify end-to-end state flow.

- Features: foundation
- Dependencies: TASK-013
- Source paths: `Sources/App/PrimaryJourneys.swift`
- Test paths: `Tests/PrimaryJourneyTests.swift`

Acceptance:

- Every declared journey reaches its observable result through typed feature operations.

Validation:

- `swift test --filter PrimaryJourneyTests`

## TASK-015 — Verify interface, accessibility, and recovery

Verify every declared interface requirement and recovery behavior.

- Features: foundation
- Dependencies: TASK-014
- Source paths: `Sources/App/Interface/KeyboardContract.swift`, `Sources/App/Interface/VoiceOverContract.swift`, `Sources/App/Interface/ReducedMotionContract.swift`, `Sources/App/Interface/AppearanceContract.swift`, `Sources/App/Interface/WindowBehaviorContract.swift`, `Sources/App/Interface/ConfirmationContract.swift`, `Sources/App/Interface/CancellationContract.swift`, `Sources/App/Interface/ErrorRecoveryContract.swift`
- Test paths: `Tests/Interface/KeyboardContractTests.swift`, `Tests/Interface/VoiceOverContractTests.swift`, `Tests/Interface/ReducedMotionContractTests.swift`, `Tests/Interface/AppearanceContractTests.swift`, `Tests/Interface/WindowBehaviorContractTests.swift`, `Tests/Interface/ConfirmationContractTests.swift`, `Tests/Interface/CancellationContractTests.swift`, `Tests/Interface/ErrorRecoveryContractTests.swift`

Acceptance:

- User can navigate menu with arrow keys
- Settings can be operated with keyboard
- VoiceOver reads counter names and totals
- Buttons and controls are labeled
- No unnecessary animations
- Transitions are instant when Reduce Motion is on
- Colors adapt to system appearance
- Text is readable in both modes
- Settings window opens and closes properly
- Window state is preserved
- No confirmation dialogs appear
- Cancel buttons are available in dialogs
- Error messages include Retry button
- Last valid state is preserved
- Every workflow preserves the last valid state on cancellation or failure.

Validation:

- `swift test --filter KeyboardContractTests`
- `swift test --filter VoiceOverContractTests`
- `swift test --filter ReducedMotionContractTests`
- `swift test --filter AppearanceContractTests`
- `swift test --filter WindowBehaviorContractTests`
- `swift test --filter ConfirmationContractTests`
- `swift test --filter CancellationContractTests`
- `swift test --filter ErrorRecoveryContractTests`

## TASK-016 — Build, sign, and package the application

Produce and verify the selected native macOS application bundle.

- Features: F-001, F-002, F-003, F-004, F-005, F-006, F-007, F-008, F-009, F-010, F-011
- Dependencies: TASK-015
- Source paths: `Scripts/package_app.sh`
- Test paths: `Tests/ReleaseContractTests.swift`

Acceptance:

- All tests pass before the signed application bundle is created.

Validation:

- `swift test`
- `swift build -c release`
- `Scripts/package_app.sh`
- `codesign --verify --deep --strict "build/Small Count.app"`

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
