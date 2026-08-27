import Testing
@testable import SmallCount
@Suite("UIR-006 confirmation") struct ConfirmationContractTests { @Test func noDestructiveConfirmation() { #expect(!ConfirmationContract.hasDestructiveActions); #expect(!ConfirmationContract.requiresConfirmation) } }
