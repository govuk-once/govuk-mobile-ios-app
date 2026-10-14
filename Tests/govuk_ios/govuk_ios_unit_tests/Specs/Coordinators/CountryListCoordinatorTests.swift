import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct CountryListCoordinatorTests {

    @Test
    func start_setsViewController() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let sut = CountryListCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            urlOpener: MockURLOpener(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completion: { _ in }
        )

        sut.start()

        #expect(mockNavigationController._setViewControllers != nil)
        #expect(mockNavigationController._setViewControllers?.count ?? 0 > 0)
    }

    @Test
    func start_passesOpenURLActionToViewControllerBuilder() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let sut = CountryListCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            urlOpener: MockURLOpener(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completion: { _ in }
        )

        sut.start()

        #expect(mockNavigationController._setViewControllers?.count ?? 0 > 0)
    }

    @Test
    func start_openExternalURLActionClosure_opensURLWithURLOpener() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockURLOpener = MockURLOpener()
        let testURL = URL(string: "https://example.com")!

        let sut = CountryListCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            urlOpener: mockURLOpener,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completion: { _ in }
        )

        sut.start()

        guard let openExternalURLAction = mockViewControllerBuilder._receivedCountryListOpenExternalURLAction else {
            Issue.record("Expected openExternalURLAction closure to be captured")
            return
        }

        openExternalURLAction(testURL)

        #expect(mockURLOpener._receivedOpenIfPossibleUrl == testURL)
    }

    @Test
    func start_openFooterLinkActionClosure_capturesClosure() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let sut = CountryListCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            urlOpener: MockURLOpener(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completion: { _ in }
        )

        sut.start()

        #expect(mockViewControllerBuilder._receivedCountryListOpenFooterLinkAction != nil)
    }

    @Test
    func start_openFooterLinkActionClosure_createsSafariCoordinator() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let testURL = URL(string: "https://footer.example.com")!

        let sut = CountryListCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            urlOpener: MockURLOpener(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            completion: { _ in }
        )

        sut.start()

        guard let openFooterLinkAction = mockViewControllerBuilder._receivedCountryListOpenFooterLinkAction else {
            Issue.record("Expected openFooterLinkAction closure to be captured")
            return
        }

        openFooterLinkAction(testURL)

        #expect(mockCoordinatorBuilder._receivedSafariCoordinatorURL == testURL)
        #expect(mockCoordinatorBuilder._receivedSafariCoordinatorFullScreen == false)
    }
}
