import Testing
@testable import SmallCount

@Suite("TASK-001 Application lifecycle")
struct AppLifecycleTests {
    @Test("native macOS menu-bar lifecycle is selected")
    func nativeMenuBarLifecycle() {
        #expect(AppLifecycle.applicationForm == "macOS Menu Bar")
        #expect(AppLifecycle.usesMenuBarExtra)
        #expect(AppLifecycle.keepsMenuBarExtraInserted)
        #expect(AppLifecycle.minimumMacOS == "15.0")
    }

    @Test("automatic status-item removal keeps the app alive while explicit Quit terminates")
    func terminationPolicy() {
        #expect(!AppTerminationPolicy.shouldTerminate(explicitQuitRequested: false))
        #expect(AppTerminationPolicy.shouldTerminate(explicitQuitRequested: true))
    }

    @Test("AppKit fallback appears only when Control Center explicitly hides MenuBarExtra")
    func fallbackPolicy() {
        #expect(AppLifecycle.fallbackRequestsVisibility)
        #expect(AppLifecycle.shouldInstallFallback(menuBarExtraVisiblePreference: false))
        #expect(!AppLifecycle.shouldInstallFallback(menuBarExtraVisiblePreference: true))
        #expect(!AppLifecycle.shouldInstallFallback(menuBarExtraVisiblePreference: nil))
    }
}
