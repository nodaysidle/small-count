import Testing
@testable import SmallCount
@Suite("UIR-008 error recovery") struct ErrorRecoveryContractTests { @Test func retry() { #expect(ErrorRecoveryContract.retryTitle == "Retry"); #expect(ErrorRecoveryContract.preservesLastValidState) } }
