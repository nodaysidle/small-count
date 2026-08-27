import Testing
@testable import SmallCount
@Suite("UIR-003 Reduce Motion") struct ReducedMotionContractTests { @Test func motion() { #expect(ReducedMotionContract.duration(reduceMotion: true) == 0); #expect(ReducedMotionContract.duration(reduceMotion: false) > 0) } }
