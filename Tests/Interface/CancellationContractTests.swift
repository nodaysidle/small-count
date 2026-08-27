import Testing
@testable import SmallCount
@Suite("UIR-007 cancellation") struct CancellationContractTests { @Test func cancellable() { #expect(CancellationContract.modalCancelTitle == "Cancel"); #expect(CancellationContract.cancellationPreservesState) } }
