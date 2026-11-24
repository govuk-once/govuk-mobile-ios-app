import Foundation
import Testing
import UIKit
import GovKit

@testable import govuk_ios

@Suite
@MainActor
struct LicenceCategoriesCoordinatorTests {

    @Test
    func start_pushesLicenceCategoryListViewController() {
        let mockViewControllerBuilder = MockDVLAViewControllerBuilder()
        let expectedViewController = UIViewController()
        let mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [UIViewController()]
        mockNavigationController._prefersLargeTitles = false
        let mockConfigService = MockAppConfigService()
        let mockAnalyticsService = MockAnalyticsService()
        let expectedEntitlements: [Entitlement] = [.arrange]
        mockViewControllerBuilder._stubbedLicenceCategoryListViewController = expectedViewController

        let sut = LicenceCategoriesCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener(),
            configService: mockConfigService,
            analyticsService: mockAnalyticsService,
            entitlements: expectedEntitlements
        )

        sut.start()

        #expect(mockNavigationController._pushedViewController == expectedViewController)
        #expect(mockNavigationController.viewControllers.last == expectedViewController)
        #expect(expectedViewController.navigationItem.largeTitleDisplayMode == .always)
        #expect(mockNavigationController._prefersLargeTitles == true)
        #expect(mockViewControllerBuilder._receivedLicenceCategoryListEntitlements == expectedEntitlements)
        #expect(mockViewControllerBuilder._receivedLicenceCategoryListAnalyticsService as? MockAnalyticsService === mockAnalyticsService)
        #expect(mockViewControllerBuilder._receivedLicenceCategoryListConfigService as? MockAppConfigService === mockConfigService)
    }

    @Test
    func finish_restoresPreviousPrefersLargeTitles() {
        let mockViewControllerBuilder = MockDVLAViewControllerBuilder()
        let mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [UIViewController()]
        mockNavigationController._prefersLargeTitles = false

        let sut = LicenceCategoriesCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener(),
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService(),
            entitlements: []
        )

        sut.start()
        #expect(mockNavigationController._prefersLargeTitles == true)

        sut.finish()
        #expect(mockNavigationController._prefersLargeTitles == false)
    }

    @Test
    func listOpenURLAction_opensURL() throws {
        let mockViewControllerBuilder = MockDVLAViewControllerBuilder()
        let mockURLOpener = MockURLOpener()
        let mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [UIViewController()]
        let expectedURL = try #require(URL(string: "https://www.gov.uk"))

        let sut = LicenceCategoriesCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: mockURLOpener,
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService(),
            entitlements: []
        )

        sut.start()
        let actions = try #require(mockViewControllerBuilder._receivedLicenceCategoryListActions)
        #expect(actions.openURLAction != nil)
        if let openURLAction = actions.openURLAction {
            openURLAction(expectedURL)
            #expect(mockURLOpener._receivedOpenIfPossibleUrl == expectedURL)
        }
    }

    @Test
    func listDidSelectAction_presentsLicenceCategoryDetail() throws {
        let mockViewControllerBuilder = MockDVLAViewControllerBuilder()
        let mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [UIViewController()]
        let mockAnalyticsService = MockAnalyticsService()
        let expectedDetailViewController = UIViewController()
        let selectedEntitlement = Entitlement.arrange
        mockViewControllerBuilder._stubbedLicenceCategoryDetailViewController = expectedDetailViewController

        let sut = LicenceCategoriesCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener(),
            configService: MockAppConfigService(),
            analyticsService: mockAnalyticsService,
            entitlements: [selectedEntitlement]
        )

        sut.start()
        let actions = try #require(mockViewControllerBuilder._receivedLicenceCategoryListActions)
        #expect(actions.didSelectAction != nil)
        if let didSelectAction = actions.didSelectAction {
            didSelectAction(selectedEntitlement)
        }

        let presentedNavController = try #require(
            mockNavigationController._presentedViewController as? UINavigationController
        )
        #expect(mockViewControllerBuilder._receivedLicenceCategoryDetailEntitlement == selectedEntitlement)
        #expect(mockViewControllerBuilder._receivedLicenceCategoryDetailAnalyticsService as? MockAnalyticsService === mockAnalyticsService)
        #expect(presentedNavController.viewControllers.first == expectedDetailViewController)
    }

}
