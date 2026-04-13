import Foundation
import GovKit
import FirebasePerformance

class PerformanceClient: AnalyticsClient {
    private var performance: PerformanceInterface

    init(performance: PerformanceInterface) {
        self.performance = performance
    }

    func setEnabled(enabled: Bool) {
        performance.isDataCollectionEnabled = enabled
    }

    func launch() { /* protocol conformance */ }

    func track(screen: TrackableScreen) { /* protocol conformance */ }

    func track(event: AppEvent) { /* protocol conformance */ }

    func track(error: Error) { /* protocol conformance */ }

    func set(userProperty: UserProperty) { /* protocol conformance */ }
}

protocol PerformanceInterface {
    var isDataCollectionEnabled: Bool { get set }
}

extension Performance: PerformanceInterface { }
