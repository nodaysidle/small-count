# Small Count — Product Requirements

> Canonical schema 4.0.0 · prompt 4.0.0 · preset `native-macos-menu-bar`

## Product truth

A private, local-first manual counter in the macOS menu bar. Users create and edit counters, record events, view today's totals, archive/restore counters, and export a counter's full history as Markdown.

### Users

- People who need a simple manual tally without accounts or cloud sync
- Users who prefer menu-bar utilities for quick access

### Goals

- Provide a fast way to record an event for a selected counter
- Allow managing counters via Settings
- Show today's totals for active counters in the menu
- Support archiving and restoring counters without data loss
- Export a counter's complete event history as Markdown

### Non-goals

- No accounts, cloud sync, or network access
- No analytics, AI, notifications, or monitoring
- No global hotkeys or background activity
- No deletion of counters or events

## Features

### F-001 — Create Counter

Add a new counter with a name and optional color.

Acceptance criteria:

- AC-001-1: User can enter a name and choose a color
- AC-001-2: Counter appears in the menu and Settings list

Failure and recovery:

- If name is empty, show validation error and do not create

### F-002 — Edit Counter

Modify the name or color of an existing counter.

Acceptance criteria:

- AC-002-1: User can change name and color
- AC-002-2: Changes reflect in menu and Settings

Failure and recovery:

- If save fails, show retry without losing previous state

### F-003 — Record Event

Record one event for the selected active counter from the menu.

Acceptance criteria:

- AC-003-1: Selecting a counter and choosing 'Record' creates an event with current date/time
- AC-003-2: Today's count for that counter increments

Failure and recovery:

- If save fails, show retry without losing the event

### F-004 — View Today's Totals

Display today's count for each active counter in the menu.

Acceptance criteria:

- AC-004-1: Menu shows each active counter with its count for the current local day
- AC-004-2: Counts update after recording an event

Failure and recovery:

- If data cannot be read, show placeholder and allow retry

### F-005 — Archive Counter

Move a counter to archived state, hiding it from the active menu list.

Acceptance criteria:

- AC-005-1: Archived counters no longer appear in the active menu list
- AC-005-2: Archived counters appear in the archived list in Settings

Failure and recovery:

- If archive fails, show retry and keep counter active

### F-006 — Restore Counter

Bring an archived counter back to active state.

Acceptance criteria:

- AC-006-1: Restored counter reappears in the active menu list
- AC-006-2: Its event history remains intact

Failure and recovery:

- If restore fails, show retry and keep counter archived

### F-007 — List Active Counters

Show all active counters in the menu.

Acceptance criteria:

- AC-007-1: Menu lists all active counters
- AC-007-2: Archived counters are excluded

Failure and recovery:

- If read fails, show error with retry

### F-008 — List Archived Counters

Show archived counters in Settings for management.

Acceptance criteria:

- AC-008-1: Settings shows a list of archived counters
- AC-008-2: Each archived counter can be restored

Failure and recovery:

- If read fails, show error with retry

### F-009 — Export Counter History

Export one selected counter with its complete event history as a UTF-8 Markdown file to a user-selected location.

Acceptance criteria:

- AC-009-1: User selects a counter and chooses export destination
- AC-009-2: File contains counter name and all events with timestamps
- AC-009-3: File is UTF-8 Markdown

Failure and recovery:

- If export fails, show error and allow retry

### F-010 — Open Settings

Open the app's Settings window.

Acceptance criteria:

- AC-010-1: Selecting Settings opens the Settings window
- AC-010-2: Settings window shows counter management

Failure and recovery:

- If Settings cannot open, show error

### F-011 — Quit Application

Quit the app.

Acceptance criteria:

- AC-011-1: Selecting Quit terminates the app
- AC-011-2: All data is persisted before quitting

Failure and recovery:

- If quit fails, show error and keep app running

## Primary journeys

### Record a quick event

1. Open the menu bar app
2. See list of active counters with today's totals
3. Select a counter
4. Choose 'Record'
5. Event is recorded and total increments

### Manage counters

1. Open Settings
2. Create a new counter
3. Edit an existing counter
4. Archive a counter
5. Restore an archived counter

### Export history

1. Open Settings
2. Select a counter
3. Choose 'Export'
4. Pick a location
5. Markdown file is saved

## Interface requirements

### UIR-001 — keyboard

All menu items and Settings controls must be keyboard accessible.

Acceptance criteria:

- User can navigate menu with arrow keys
- Settings can be operated with keyboard

### UIR-002 — voiceOver

All UI elements must have appropriate accessibility labels.

Acceptance criteria:

- VoiceOver reads counter names and totals
- Buttons and controls are labeled

### UIR-003 — reducedMotion

Animations must be minimized or disabled when Reduce Motion is enabled.

Acceptance criteria:

- No unnecessary animations
- Transitions are instant when Reduce Motion is on

### UIR-004 — appearance

App must support both light and dark appearances.

Acceptance criteria:

- Colors adapt to system appearance
- Text is readable in both modes

### UIR-005 — windowBehavior

Settings window should be standard and resizable.

Acceptance criteria:

- Settings window opens and closes properly
- Window state is preserved

### UIR-006 — confirmation

No destructive actions require confirmation because there is no deletion.

Acceptance criteria:

- No confirmation dialogs appear

### UIR-007 — cancellation

Users can cancel any modal operation.

Acceptance criteria:

- Cancel buttons are available in dialogs

### UIR-008 — errorRecovery

Failed saves or exports show a retry option without losing data.

Acceptance criteria:

- Error messages include Retry button
- Last valid state is preserved

## Invariants

- **INV-001** `reversibleState` on ENT-001: Change archived reversibly without deleting the record.

## Destructive behavior

- None permitted. Reversible state transitions must preserve records.

## Assumptions

- The app runs on macOS 15 or later
- The user has a local file system for export
- The app is used privately and locally

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
