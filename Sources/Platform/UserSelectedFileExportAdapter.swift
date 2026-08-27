import AppKit
import Foundation

enum UserSelectedFileExportError: Error, Equatable, CustomStringConvertible {
    case cancelled

    var description: String { "Export cancelled" }
}

@MainActor
final class UserSelectedFileExportAdapter: UserSelectedFileExportProviding {
    func selectExportDestination(suggestedName: String) async throws -> URL {
        try Task.checkCancellation()
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedName
        panel.allowedContentTypes = [.plainText]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        guard panel.runModal() == .OK, let url = panel.url else {
            throw UserSelectedFileExportError.cancelled
        }
        try Task.checkCancellation()
        return url
    }
}
