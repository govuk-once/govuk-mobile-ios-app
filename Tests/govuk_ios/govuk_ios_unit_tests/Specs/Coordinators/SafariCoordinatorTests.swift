import UIKit
import Foundation
import Testing
import SafariServices

@testable import govuk_ios

@Suite
struct SafariCoordinatorTests {
    @Test
    @MainActor
    func start_presentsSafariViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedSafariViewController = expectedViewController
        let mockNavigationController = MockNavigationController()
        let subject = SafariCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            configService: MockAppConfigService(),
            urlOpener: MockURLOpener(),
            url: .arrange,
            fullScreen: false
        )
        subject.start()

        #expect(mockNavigationController._presentedViewController === expectedViewController)
    }

    @Test
    @MainActor
    func start_externalBrowserDisabled_presentsSafariViewController() {
        let expectedURL = URL.arrange
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let subject = SafariCoordinator(
            navigationController: MockNavigationController(),
            viewControllerBuilder: mockViewControllerBuilder,
            configService: MockAppConfigService(),
            urlOpener: MockURLOpener(),
            url: expectedURL,
            fullScreen: true
        )
        subject.start()

        #expect(mockViewControllerBuilder._receivedSafariUrl == expectedURL)
    }

    @Test
    @MainActor
    func start_noneHttpURL_opensURL() {
        let expectedNoneHttpURL = URL(string: "mailto:test@example.com")!
        let mockURLOpener = MockURLOpener()
        let subject = SafariCoordinator(
            navigationController: MockNavigationController(),
            viewControllerBuilder: MockViewControllerBuilder(),
            configService: MockAppConfigService(),
            urlOpener: mockURLOpener,
            url: expectedNoneHttpURL,
            fullScreen: true
        )
        subject.start()

        #expect(mockURLOpener._receivedOpenIfPossibleUrl == expectedNoneHttpURL)
    }

    @Test
    @MainActor
    func start_externalBrowserEnabled_opensURL() {
        let expectedURL = URL.arrange
        let mockConfigService = MockAppConfigService()
        mockConfigService.features = [.externalBrowser]
        let mockURLOpener = MockURLOpener()
        let subject = SafariCoordinator(
            navigationController: MockNavigationController(),
            viewControllerBuilder: MockViewControllerBuilder(),
            configService: mockConfigService,
            urlOpener: mockURLOpener,
            url: expectedURL,
            fullScreen: false
        )
        subject.start()

        #expect(mockURLOpener._receivedOpenIfPossibleUrl == expectedURL)
    }

    @Test
    @MainActor
    func start_fullScreen_configuresCorrectly() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedSafariViewController = expectedViewController
        let subject = SafariCoordinator(
            navigationController: MockNavigationController(),
            viewControllerBuilder: mockViewControllerBuilder,
            configService: MockAppConfigService(),
            urlOpener: MockURLOpener(),
            url: .arrange,
            fullScreen: true
        )
        subject.start()

        #expect(expectedViewController.isModalInPresentation == true)
        #expect(expectedViewController.modalPresentationStyle == .fullScreen)
    }

    @Test
    @MainActor
    func start_notFullScreen_configuresCorrectly() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedSafariViewController = expectedViewController
        let subject = SafariCoordinator(
            navigationController: MockNavigationController(),
            viewControllerBuilder: mockViewControllerBuilder,
            configService: MockAppConfigService(),
            urlOpener: MockURLOpener(),
            url: .arrange,
            fullScreen: false
        )
        subject.start()

        #expect(expectedViewController.isModalInPresentation == true)
        #expect(expectedViewController.modalPresentationStyle == .pageSheet)
    }

    @Test
    @MainActor
    func start_withPresentedViewController_presentsOnPresentedViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedSafariViewController = expectedViewController
        let mockNavigationController = MockNavigationController()
        let mockPresentedViewController = MockBaseViewController.mock
        mockNavigationController._stubbedPresentedViewController = mockPresentedViewController
        let subject = SafariCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            configService: MockAppConfigService(),
            urlOpener: MockURLOpener(),
            url: .arrange,
            fullScreen: false
        )
        subject.start()

        #expect(mockPresentedViewController._presentedViewController == expectedViewController)
    }
}
