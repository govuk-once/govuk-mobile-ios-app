import UIKit
import SwiftUI
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct DrivingTopicWidgetCoordinatorTests {

    let mockAnalyticsService = MockAnalyticsService()
    let mockConfigService = MockAppConfigService()
    let mockUserService = MockUserService()
    let mockDvlaService = MockDVLAService()
    let mockNavigationController = MockNavigationController()
    let mockWidgetViewBuilder = MockWidgetViewBuilder()
    let mockCoreDataViewContext = CoreDataRepository.arrangeAndLoad.viewContext

    @Test
    func widget_forDrivingTopic_whenFeatureSwitchIsEnabled_returnsWidget() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]

        let sut = DrivingTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let widgetView = sut.widget(for: drivingTopic)
        #expect(widgetView != nil)
    }

    @Test
    func widget_forDrivingTopic_whenFeatureSwitchIsDisabled_returnsNil() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = []

        let sut = DrivingTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let widgetView = sut.widget(for: drivingTopic)
        #expect(widgetView == nil)
    }

    @Test
    func widget_forNonDrivingTopic_returnsNil() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "business"
        )

        let sut = DrivingTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let widgetView = sut.widget(for: drivingTopic)
        #expect(widgetView == nil)
    }

    @Test
    func widget_linkAction_startsLinkAccount() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockServiceAccountLinkCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedServiceAccountLinkCoordinator = mockServiceAccountLinkCoordinator

        let sut = DrivingTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: mockCoordinatorBuilder,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let _ = sut.widget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetLinkAction?()
        #expect(mockServiceAccountLinkCoordinator._startCalled == true)
    }

    @Test
    func widget_unlinkAction_startsUnlinkAccount() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockServiceAccountUnlinkCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedServiceAccountUnlinkCoordinator = mockServiceAccountUnlinkCoordinator

        let sut = DrivingTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: mockCoordinatorBuilder,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let _ = sut.widget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetUnlinkAction?()
        #expect(mockServiceAccountUnlinkCoordinator._startCalled == true)
    }
}

