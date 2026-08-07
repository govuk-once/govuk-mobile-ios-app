import Foundation

@testable import govuk_ios

class MockNotificationCentreCoordinator: NotificationCentreCoordinator {
    var _stubbedDidShowDetail = false

    override func showDetail(for notificationId: String) {
        _stubbedDidShowDetail = true
    }

    var _startCalled: Bool = false
    override func start(url _: URL?) {
        _startCalled = true
    }
}
