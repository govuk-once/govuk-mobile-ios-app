import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
class DVLAAuthenticationCoordinatorTests {

    @Test
    @MainActor
    func start_opensURL() async {
        let mockURLOpener = MockURLOpener()
        let sut = DVLAAuthenticationCoordinator(
            navigationController: UINavigationController(),
            urlOpener: mockURLOpener,
        )
        sut.start()
        #expect(mockURLOpener._receivedOpenIfPossibleUrl?.absoluteString == "https://architecture-link-account-service-ui-ext.dvla.gov.uk/")
    }
}
