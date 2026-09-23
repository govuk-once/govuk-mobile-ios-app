import Foundation

@testable import govuk_ios

class MockInactivityService: InactivityServiceInterface {

    var _stubbedInactive: Bool = false
    var inactive: Bool {
        return _stubbedInactive
    }

    var _receivedStartMonitoringInactivityHandler: (() -> Void)?
    var _receivedStartMonitoringAlertHandler: (() -> Void)?
    var _stubbedStartMonitoringCalled = false
    func startMonitoring(inactivityHandler: @escaping () -> Void,
                         alertHandler: @escaping () -> Void) {
        _stubbedStartMonitoringCalled = true
        _receivedStartMonitoringInactivityHandler = inactivityHandler
        _receivedStartMonitoringAlertHandler = alertHandler
    }

    var _resetTimerCalled = false
    func resetTimers() {
        _resetTimerCalled = true
    }

    func simulateWarning() {
        _receivedStartMonitoringAlertHandler?()
    }

    func simulateInactivity() {
        _stubbedInactive = true
        _receivedStartMonitoringInactivityHandler?()
    }

    func simulateActivity() {
        _stubbedInactive = false
    }
}
