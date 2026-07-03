import Foundation
import Testing

@testable import govuk_ios

@Suite
struct PerformanceClientTests {
    @Test
    func setEnabled_true_passesThroughValue() {
        let mockPerformance = MockPerformance()
        let sut = PerformanceClient(
            performance: mockPerformance
        )

        sut.setEnabled(enabled: true)

        #expect(mockPerformance._receivedIsDataCollectionEnabled == true)
    }

    @Test
    func setEnabled_false_passesThroughValue() {
        let mockPerformance = MockPerformance()
        let sut = PerformanceClient(
            performance: mockPerformance
        )

        sut.setEnabled(enabled: false)

        #expect(mockPerformance._receivedIsDataCollectionEnabled == false)
    }

    @Test
    func launch_exists_doesNothing() {
        let mockPerformance = MockPerformance()
        let sut = PerformanceClient(
            performance: mockPerformance
        )
        sut.launch()
        #expect(mockPerformance._receivedIsDataCollectionEnabled == nil)
    }

    @Test
    func trackEvent_exists_doesNothing() {
        let mockPerformance = MockPerformance()
        let sut = PerformanceClient(
            performance: mockPerformance
        )
        sut.track(event: .init(name: "test", params: nil))
        #expect(mockPerformance._receivedIsDataCollectionEnabled == nil)
    }
}

class MockPerformance: PerformanceInterface {
    var _receivedIsDataCollectionEnabled: Bool?
    var isDataCollectionEnabled: Bool = false {
        didSet {
            _receivedIsDataCollectionEnabled = isDataCollectionEnabled
        }
    }
}
