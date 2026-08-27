import Testing
@testable import SmallCount
@Suite("UIR-005 window behavior") struct WindowBehaviorContractTests { @Test func settingsWindow() { #expect(WindowBehaviorContract.resizable); #expect(WindowBehaviorContract.autosaveName == "SmallCountSettingsWindow"); #expect(WindowBehaviorContract.minimumWidth >= 520) } }
