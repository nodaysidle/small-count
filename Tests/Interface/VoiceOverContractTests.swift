import Testing
@testable import SmallCount
@Suite("UIR-002 VoiceOver") struct VoiceOverContractTests { @Test func labels() { #expect(VoiceOverContract.counterLabel(name: "Water", total: 2) == "Water, 2 today"); #expect(!VoiceOverContract.retryLabel.isEmpty) } }
