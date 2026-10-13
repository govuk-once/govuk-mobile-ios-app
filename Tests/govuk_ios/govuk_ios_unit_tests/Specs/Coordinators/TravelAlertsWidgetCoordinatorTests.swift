import UIKit
import SwiftUI
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct TravelAlertsWidgetCoordinatorTests {

    let mockAnalyticsService = MockAnalyticsService()
    let mockConfigService = MockAppConfigService()
    let mockTravelService = MockTravelService()
    let mockNotificationService = MockNotificationService()
    let mockNavigationController = MockNavigationController()
    let mockWidgetViewBuilder = MockWidgetViewBuilder()
    let mockViewControllerBuilder = MockViewControllerBuilder()
    let coreDataRepository: CoreDataRepository

    init() async {
        coreDataRepository = await CoreDataRepository.arrangeAndLoad
    }
    
    @Test
    func makeWidget_forTravelTopic_whenFeatureSwitchIsEnabled_returnsWidget() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = [.travelAlerts]

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )
        let widgetView = sut.makeWidget(for: travelTopic)
        #expect(widgetView != nil)
    }

    @Test
    func makeWidget_forTravelTopic_whenFeatureSwitchIsDisabled_returnsNil() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = []

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )
        let widgetView = sut.makeWidget(for: travelTopic)
        #expect(widgetView == nil)
    }
    
    @Test
    func makeWidget_forNonTravelTopic_returnsNil() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "business"
        )

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )
        let widgetView = sut.makeWidget(for: travelTopic)
        #expect(widgetView == nil)
    }

    @Test
    func makeWidget_linkActionClosure_triggersCountrySelection() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = [.travelAlerts]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: mockCoordinatorBuilder,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )

        _ = sut.makeWidget(for: travelTopic)

        guard let linkAction = mockWidgetViewBuilder._receivedTravelAlertLinkAction else {
            Issue.record("Expected linkAction closure to be captured")
            return
        }

        linkAction()

        #expect(mockCoordinatorBuilder._countryListCoordinatorWasCalled == true)
    }

    @Test
    func makeWidget_dismissActionClosure_triggersViewReappear() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = [.travelAlerts]
        let mockNavigationController = MockNavigationController()

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: mockNavigationController,
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )

        _ = sut.makeWidget(for: travelTopic)

        guard let dismissAction = mockWidgetViewBuilder._receivedTravelAlertDismissAction else {
            Issue.record("Expected dismissAction closure to be captured")
            return
        }

        dismissAction()

        #expect(mockNavigationController.viewWillReAppearWasCalled == true)
    }

    @Test
    func makeWidget_editActionClosure_pushesEditCountriesViewController() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = [.travelAlerts]
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: mockNavigationController,
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )

        _ = sut.makeWidget(for: travelTopic)

        guard let editAction = mockWidgetViewBuilder._receivedTravelAlertEditAction else {
            Issue.record("Expected editAction closure to be captured")
            return
        }

        editAction()

        #expect(mockViewControllerBuilder._editCountriesWasCalled == true)
        #expect(mockNavigationController._pushedViewController != nil)
    }

    @Test
    func makeWidget_editActionClosure_enablesLargeTitles() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = [.travelAlerts]
        let mockNavigationController = MockNavigationController()

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: mockNavigationController,
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )

        _ = sut.makeWidget(for: travelTopic)

        guard let editAction = mockWidgetViewBuilder._receivedTravelAlertEditAction else {
            Issue.record("Expected editAction closure to be captured")
            return
        }

        editAction()

        #expect(mockNavigationController._prefersLargeTitles == true)
    }

    @Test
    func makeWidget_openURLActionClosure_presentsSafariCoordinator() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = [.travelAlerts]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let testURL = URL(string: "https://www.example.com")!

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: mockCoordinatorBuilder,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )

        _ = sut.makeWidget(for: travelTopic)

        guard let openURLAction = mockWidgetViewBuilder._receivedTravelAlertOpenURLAction else {
            Issue.record("Expected openURLAction closure to be captured")
            return
        }

        openURLAction(testURL)

        #expect(mockCoordinatorBuilder._receivedSafariCoordinatorURL == testURL)
    }

    @Test
    func makeWidget_openURLActionClosure_createsSafariCoordinatorWithNonFullScreen() {
        let travelTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "travel-abroad"
        )
        mockConfigService.features = [.travelAlerts]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let testURL = URL(string: "https://www.gov.uk")!

        let sut = TravelAlertsWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            notificationService: mockNotificationService,
            deviceInformationProvider: MockDeviceInformationProvider(),
            versionProvider: MockAppVersionProvider(),
            coordinatorBuilder: mockCoordinatorBuilder,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
        )

        _ = sut.makeWidget(for: travelTopic)

        guard let openURLAction = mockWidgetViewBuilder._receivedTravelAlertOpenURLAction else {
            Issue.record("Expected openURLAction closure to be captured")
            return
        }

        openURLAction(testURL)

        #expect(mockCoordinatorBuilder._receivedSafariCoordinatorFullScreen == false)
    }

}
