import Foundation

enum KeyboardContract {
    enum Navigation { case arrowKeys }
    enum Direction { case up, down }
    static let menuNavigation = Navigation.arrowKeys
    static let settingsShortcut = ","
    static let quitShortcut = "q"

    static func nextSelection(
        current: UUID?,
        direction: Direction,
        identifiers: [UUID]
    ) -> UUID? {
        guard !identifiers.isEmpty else { return nil }
        guard let current, let index = identifiers.firstIndex(of: current) else {
            return direction == .down ? identifiers.first : identifiers.last
        }
        let offset = direction == .down ? 1 : -1
        let nextIndex = min(max(index + offset, identifiers.startIndex), identifiers.index(before: identifiers.endIndex))
        return identifiers[nextIndex]
    }
}
