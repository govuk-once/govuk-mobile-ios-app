import Foundation
import UIKit
import Testing

@testable import GovKitUI

@Suite
@MainActor
struct GOVUKColors_NotificationCentreTests {
    @Test
    func notificationCentreFloatingIcons_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.notificationCentreFloatingIcons

        #expect(result.lightMode == .grey900)
    }

    @Test
    func notificationCentreFloatingIcons_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.notificationCentreFloatingIcons

        #expect(result.darkMode == .blackLighter95)
    }
}
