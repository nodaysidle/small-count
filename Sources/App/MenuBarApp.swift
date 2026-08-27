import AppKit
import Observation
import OSLog
import SwiftUI

/// TASK-001 lifecycle facts used by release and lifecycle tests.
enum AppLifecycle {
    static let applicationForm = "macOS Menu Bar"
    static let usesMenuBarExtra = true
    static let keepsMenuBarExtraInserted = true
    static let fallbackRequestsVisibility = true
    static let minimumMacOS = "15.0"

    static func shouldInstallFallback(menuBarExtraVisiblePreference: Bool?) -> Bool {
        menuBarExtraVisiblePreference == false
    }
}

enum AppTerminationPolicy {
    static func shouldTerminate(explicitQuitRequested: Bool) -> Bool {
        explicitQuitRequested
    }
}

@MainActor
final class AppLifecycleDelegate: NSObject, NSApplicationDelegate {
    private var explicitQuitRequested = false
    private var journeys: PrimaryJourneys?
    private var fallbackStatusItem: NSStatusItem?
    private var fallbackPopover: NSPopover?

    func configure(journeys: PrimaryJourneys) {
        self.journeys = journeys
        installFallbackIfNeeded()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        installFallbackIfNeeded()
    }

    func requestExplicitQuit() {
        explicitQuitRequested = true
        NSApplication.shared.terminate(nil)
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        AppTerminationPolicy.shouldTerminate(explicitQuitRequested: explicitQuitRequested)
            ? .terminateNow
            : .terminateCancel
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let fallbackStatusItem {
            NSStatusBar.system.removeStatusItem(fallbackStatusItem)
        }
    }

    private func installFallbackIfNeeded() {
        guard fallbackStatusItem == nil, let journeys else { return }
        let visibilityPreference = UserDefaults.standard.object(
            forKey: "NSStatusItem VisibleCC Item-0"
        ) as? Bool
        guard AppLifecycle.shouldInstallFallback(
            menuBarExtraVisiblePreference: visibilityPreference
        ) else { return }

        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 460)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarContent(
                journeys: journeys,
                requestQuit: { [weak self] in self?.requestExplicitQuit() }
            )
        )

        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.autosaveName = "SmallCountFallbackStatusItem"
        statusItem.isVisible = AppLifecycle.fallbackRequestsVisibility
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "number.circle",
                accessibilityDescription: "Small Count"
            )
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(toggleFallbackPopover(_:))
            button.toolTip = "Small Count"
        }

        fallbackPopover = popover
        fallbackStatusItem = statusItem
    }

    @objc private func toggleFallbackPopover(_ sender: NSStatusBarButton) {
        guard let fallbackPopover else { return }
        if fallbackPopover.isShown {
            fallbackPopover.performClose(sender)
        } else {
            fallbackPopover.show(
                relativeTo: sender.bounds,
                of: sender,
                preferredEdge: .minY
            )
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}

@MainActor
final class UnavailablePersistence: StructuredPersistenceProviding {
    private let error: Error

    init(error: Error) { self.error = error }
    func loadSnapshot() async throws -> SmallCountSnapshot { throw error }
    func saveSnapshot(snapshot: SmallCountSnapshot) async throws { throw error }
    func migrateStore(fromVersion: Int, toVersion: Int) async throws -> SmallCountSnapshot { throw error }
}

@MainActor
@Observable
final class PresentationState {
    private let logger = Logger(subsystem: "com.nodaysidle.smallcount", category: "presentation")
    var errorMessage: String?
    var isBusy = false
    @ObservationIgnored private var retryAction: (@MainActor () async -> Void)?

    func perform(_ operation: @escaping @MainActor () async throws -> Void) async {
        isBusy = true
        errorMessage = nil
        retryAction = nil
        do {
            try await operation()
        } catch is CancellationError {
            // Cancellation preserves the last valid state and presents no failure.
        } catch UserSelectedFileExportError.cancelled {
            // Closing NSSavePanel is an ordinary reversible cancellation.
        } catch {
            logger.error("Operation failed: \(error.localizedDescription, privacy: .private)")
            errorMessage = error.localizedDescription
            retryAction = { [weak self] in await self?.perform(operation) }
        }
        isBusy = false
    }

    func retry() {
        let action = retryAction
        Task { await action?() }
    }
}

@main
struct SmallCountApp: App {
    @NSApplicationDelegateAdaptor(AppLifecycleDelegate.self) private var appDelegate
    @State private var journeys: PrimaryJourneys

    init() {
        let persistence: any StructuredPersistenceProviding
        do {
            persistence = try StructuredPersistenceAdapter()
        } catch {
            persistence = UnavailablePersistence(error: error)
        }
        let configuredJourneys = PrimaryJourneys(persistence: persistence)
        _journeys = State(initialValue: configuredJourneys)
        appDelegate.configure(journeys: configuredJourneys)
    }

    var body: some Scene {
        MenuBarExtra(
            "Small Count",
            systemImage: "number.circle",
            isInserted: .constant(AppLifecycle.keepsMenuBarExtraInserted)
        ) {
            MenuBarContent(
                journeys: journeys,
                requestQuit: appDelegate.requestExplicitQuit
            )
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsContent(journeys: journeys)
                .frame(
                    minWidth: WindowBehaviorContract.minimumWidth,
                    minHeight: WindowBehaviorContract.minimumHeight
                )
                .background(SettingsWindowConfigurator())
        }
        .defaultSize(width: 620, height: 520)
        .windowResizability(.contentMinSize)
    }
}

private struct ErrorRecoveryView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .textSelection(.enabled)
            Spacer()
            Button(ErrorRecoveryContract.retryTitle, action: retry)
                .accessibilityLabel(VoiceOverContract.retryLabel)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MenuBarContent: View {
    let journeys: PrimaryJourneys
    let requestQuit: @MainActor () -> Void
    @Environment(\.openSettings) private var openSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var presentation = PresentationState()
    @State private var totals: [UUID: Int] = [:]
    @FocusState private var focusedCounterID: UUID?

    private var activeCounters: [Counter] {
        journeys.snapshot.counters
            .filter { !$0.archived }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Small Count", systemImage: "number.circle.fill")
                    .font(.headline)
                Spacer()
                if presentation.isBusy { ProgressView().controlSize(.small) }
            }

            if let message = presentation.errorMessage {
                ErrorRecoveryView(message: message, retry: presentation.retry)
            }

            if activeCounters.isEmpty {
                ContentUnavailableView {
                    Label("No Active Counters", systemImage: "number")
                } description: {
                    Text("Create a counter in Settings.")
                }
            } else {
                ForEach(activeCounters) { counter in
                    Button {
                        Task {
                            await presentation.perform {
                                _ = try await journeys.recordEvent(scopeID: counter.id, draft: EventDraft())
                                try await refreshTotals()
                            }
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(color(for: counter.color))
                                .frame(width: 9, height: 9)
                            Text(counter.name)
                            Spacer()
                            Text("\(totals[counter.id] ?? 0)")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 5)
                    .accessibilityLabel(
                        VoiceOverContract.counterLabel(name: counter.name, total: totals[counter.id] ?? 0)
                    )
                    .accessibilityHint("Records one event")
                    .focused($focusedCounterID, equals: counter.id)
                }
            }

            Divider()
            HStack {
                Button("Settings…") {
                    Task {
                        await presentation.perform {
                            try await OpenSettingsFeature { openSettings() }.openSettings()
                        }
                    }
                }
                .keyboardShortcut(",", modifiers: .command)
                Spacer()
                Button("Quit") {
                    Task {
                        await presentation.perform {
                            try await QuitApplicationFeature(requestTermination: requestQuit).quitApplication()
                        }
                    }
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
        .padding(14)
        .frame(width: 320)
        .animation(.easeInOut(duration: ReducedMotionContract.duration(reduceMotion: reduceMotion)), value: activeCounters)
        .onMoveCommand { direction in
            let keyboardDirection: KeyboardContract.Direction?
            switch direction {
            case .up: keyboardDirection = .up
            case .down: keyboardDirection = .down
            default: keyboardDirection = nil
            }
            guard let keyboardDirection else { return }
            focusedCounterID = KeyboardContract.nextSelection(
                current: focusedCounterID,
                direction: keyboardDirection,
                identifiers: activeCounters.map(\.id)
            )
        }
        .task {
            await presentation.perform {
                try await journeys.restore()
                try await refreshTotals()
            }
        }
    }

    private func refreshTotals() async throws {
        var refreshed: [UUID: Int] = [:]
        for counter in activeCounters {
            refreshed[counter.id] = try await journeys.viewTodaySTotals(scopeID: counter.id).total
        }
        totals = refreshed
    }

    private func color(for value: String?) -> Color {
        switch value?.lowercased() {
        case "red": .red
        case "orange": .orange
        case "yellow": .yellow
        case "green": .green
        case "purple": .purple
        case "pink": .pink
        default: .blue
        }
    }
}

private struct SettingsContent: View {
    let journeys: PrimaryJourneys
    @State private var presentation = PresentationState()
    @State private var newName = ""
    @State private var newColor = ""

    private var active: [Counter] { journeys.snapshot.counters.filter { !$0.archived } }
    private var archived: [Counter] { journeys.snapshot.counters.filter(\.archived) }

    var body: some View {
        Form {
            if let message = presentation.errorMessage {
                ErrorRecoveryView(message: message, retry: presentation.retry)
            }

            Section("Create Counter") {
                TextField("Name", text: $newName)
                    .accessibilityLabel("New counter name")
                Picker("Color (optional)", selection: $newColor) {
                    ForEach(AppearanceContract.counterColors, id: \.self) { color in
                        Text(color.isEmpty ? "None" : color.capitalized).tag(color)
                    }
                }
                .accessibilityLabel("New counter color")
                HStack {
                    Spacer()
                    Button("Cancel") {
                        newName = ""
                        newColor = ""
                    }
                    Button("Create") {
                        Task {
                            await presentation.perform {
                                _ = try await journeys.createCounter(
                                    draft: CounterDraft(name: newName, color: newColor.nilIfEmpty)
                                )
                                newName = ""
                                newColor = ""
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Section("Active Counters") {
                if active.isEmpty { Text("No active counters").foregroundStyle(.secondary) }
                ForEach(active) { counter in
                    CounterEditorRow(counter: counter, journeys: journeys, presentation: presentation)
                }
            }

            Section("Archived Counters") {
                if archived.isEmpty { Text("No archived counters").foregroundStyle(.secondary) }
                ForEach(archived) { counter in
                    HStack {
                        Text(counter.name)
                        Spacer()
                        Button("Export…") { export(counter) }
                            .accessibilityLabel("Export \(counter.name) history")
                        Button("Restore") {
                            Task {
                                await presentation.perform {
                                    _ = try await journeys.restoreCounter(id: counter.id)
                                }
                            }
                        }
                        .accessibilityLabel("Restore \(counter.name)")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .task {
            if journeys.snapshot == .empty {
                await presentation.perform { try await journeys.restore() }
            }
        }
    }

    private func export(_ counter: Counter) {
        Task {
            await presentation.perform {
                _ = try await journeys.exportCounterHistory(
                    selectionID: counter.id,
                    suggestedName: "\(counter.name)-history.md"
                )
            }
        }
    }
}

private struct CounterEditorRow: View {
    let counter: Counter
    let journeys: PrimaryJourneys
    let presentation: PresentationState
    @State private var name: String
    @State private var color: String

    init(counter: Counter, journeys: PrimaryJourneys, presentation: PresentationState) {
        self.counter = counter
        self.journeys = journeys
        self.presentation = presentation
        _name = State(initialValue: counter.name)
        _color = State(initialValue: counter.color ?? "")
    }

    var body: some View {
        HStack {
            TextField("Name", text: $name)
                .accessibilityLabel("Name for \(counter.name)")
            Picker("Color", selection: $color) {
                ForEach(AppearanceContract.counterColors, id: \.self) { option in
                    Text(option.isEmpty ? "None" : option.capitalized).tag(option)
                }
            }
                .frame(width: 100)
                .accessibilityLabel("Color for \(counter.name)")
            Button("Save") {
                Task {
                    await presentation.perform {
                        _ = try await journeys.editCounter(
                            id: counter.id,
                            changes: CounterChanges(name: name, color: color.nilIfEmpty)
                        )
                    }
                }
            }
            Button("Export…") {
                Task {
                    await presentation.perform {
                        _ = try await journeys.exportCounterHistory(
                            selectionID: counter.id,
                            suggestedName: "\(counter.name)-history.md"
                        )
                    }
                }
            }
            Button("Archive") {
                Task {
                    await presentation.perform {
                        _ = try await journeys.archiveCounter(id: counter.id)
                    }
                }
            }
            .accessibilityLabel("Archive \(counter.name)")
        }
    }
}

private struct SettingsWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            view.window?.setFrameAutosaveName(WindowBehaviorContract.autosaveName)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
