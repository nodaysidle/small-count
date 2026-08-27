import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-016 Release contract")
struct ReleaseContractTests {
    @Test("package script declares exact bundle identity")
    func packageIdentity() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let scriptURL = root.appendingPathComponent("Scripts/package_app.sh")
        let script = try String(contentsOf: scriptURL, encoding: .utf8)
        #expect(script.contains("build/Small Count.app"))
        #expect(script.contains("com.nodaysidle.smallcount"))
        #expect(script.contains("CFBundleShortVersionString 0.1.0"))
        #expect(script.contains("CFBundleVersion 1"))
        #expect(script.contains("LSMinimumSystemVersion 15.0"))
        #expect(script.contains("LSUIElement true"))
        #expect(script.contains("codesign --force --deep --sign -"))
    }

    @Test("package includes the editable logo and native macOS icon")
    func packageIcon() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let scriptURL = root.appendingPathComponent("Scripts/package_app.sh")
        let script = try String(contentsOf: scriptURL, encoding: .utf8)

        #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("Resources/AppIcon.svg").path))
        #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("Resources/AppIcon.icns").path))
        #expect(script.contains("CFBundleIconFile"))
        #expect(script.contains("AppIcon.icns"))
        #expect(script.contains("AppIcon.svg"))
    }

    @Test("release script builds a verified drag-to-Applications DMG and checksum")
    func releaseDMG() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let scriptURL = root.appendingPathComponent("Scripts/build_dmg.sh")
        let script = try String(contentsOf: scriptURL, encoding: .utf8)

        #expect(script.contains("Scripts/package_app.sh"))
        #expect(script.contains("Small-Count-v${VERSION}-macos.dmg"))
        #expect(script.contains("ln -s /Applications"))
        #expect(script.contains("hdiutil create"))
        #expect(script.contains("hdiutil verify"))
        #expect(script.contains("shasum -a 256"))
    }
}
