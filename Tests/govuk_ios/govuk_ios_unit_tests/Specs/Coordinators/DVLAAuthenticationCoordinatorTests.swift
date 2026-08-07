import Foundation
import Testing
import UIKit

@testable import govuk_ios

@MainActor
@Suite
class DVLAAuthenticationCoordinatorTests {

    @Test
    func start_pushesDvlaAuthenticationView() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedDvlaAuthenticationViewController = UIViewController()
        mockViewControllerBuilder._stubbedDvlaAuthenticationViewController = stubbedDvlaAuthenticationViewController
        let navigationController = UINavigationController()

        let sut = DVLAAuthenticationCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener(),
            authenticationService: MockAuthenticationService(),
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService()
        )
        sut.start(url: nil)
        #expect(navigationController.viewControllers.first == stubbedDvlaAuthenticationViewController)
    }

    @Test
    func dvlaAuthenticationCompletionAction_opensUrl() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockURLOpener = MockURLOpener()
        let mockURL = URL(string: "https://dvla.gov.uk/auth")!

        let sut = DVLAAuthenticationCoordinator(
            navigationController: UINavigationController(),
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: mockURLOpener,
            authenticationService: MockAuthenticationService(),
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService()
        )
        sut.start(url: nil)
        mockViewControllerBuilder._receivedDvlaAuthenticationCompletionAction?(mockURL)
        #expect(mockURLOpener._receivedOpenIfPossibleUrl == mockURL)
    }

    @Test
    func dvlaAuthenticationErrorAction_presentsError() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let stubbedErrorViewController = UIViewController()
        mockViewControllerBuilder._stubbedErrorController = stubbedErrorViewController
        let mockNavigationController = MockNavigationController()

        let sut = DVLAAuthenticationCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener(),
            authenticationService: MockAuthenticationService(),
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService()
        )
        sut.start(url: nil)
        mockViewControllerBuilder._receivedDvlaAuthenticationErrorAction?()
        #expect(mockNavigationController._setViewControllers?.first == stubbedErrorViewController)
    }
}
