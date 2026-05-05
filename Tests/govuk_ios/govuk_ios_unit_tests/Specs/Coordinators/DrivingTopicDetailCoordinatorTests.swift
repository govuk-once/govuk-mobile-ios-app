import UIKit
import SwiftUI
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct DrivingTopicDetailCoordinatorTests {

    let mockAnalyticsService = MockAnalyticsService()
    let mockActivityService = MockActivityService()
    let mockTopicsService = MockTopicsService()
    let mockConfigService = MockAppConfigService()
    let mockUserService = MockUserService()
    let mockDvlaService = MockDVLAService()
    let mockNavigationController = MockNavigationController()
    let mockWidgetViewBuilder = MockWidgetViewBuilder()
    let mockViewControllerBuilder = MockViewControllerBuilder()
    let mockCoreDataViewContext = CoreDataRepository.arrangeAndLoad.viewContext

    @Test
    func accountWidget_forDrivingTopic_whenFeatureSwitchIsEnabled_returnsWidget() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]

        let sut = DrivingTopicDetailCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            topicsService: mockTopicsService,
            activityService: mockActivityService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            widgetViewBuilder: mockWidgetViewBuilder,
            topic: drivingTopic
        )
        let widgetView = sut.accountWidget(for: drivingTopic)
        #expect(widgetView != nil)
    }

    @Test
    func accountWidget_forDrivingTopic_whenFeatureSwitchIsDisabled_returnsNil() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = []

        let sut = DrivingTopicDetailCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            topicsService: mockTopicsService,
            activityService: mockActivityService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: MockViewControllerBuilder(),
            widgetViewBuilder: mockWidgetViewBuilder,
            topic: drivingTopic
        )
        let widgetView = sut.accountWidget(for: drivingTopic)
        #expect(widgetView == nil)
    }

    @Test
    func accountWidget_forNonDrivingTopic_returnsNil() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "business"
        )

        let sut = DrivingTopicDetailCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            topicsService: mockTopicsService,
            activityService: mockActivityService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: MockViewControllerBuilder(),
            widgetViewBuilder: mockWidgetViewBuilder,
            topic: drivingTopic
        )
        let widgetView = sut.accountWidget(for: drivingTopic)
        #expect(widgetView == nil)
    }

    @Test
    func accountWidget_linkAction_startsLinkAccount() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockServiceAccountLinkCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedServiceAccountLinkCoordinator = mockServiceAccountLinkCoordinator

        let sut = DrivingTopicDetailCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            topicsService: mockTopicsService,
            activityService: mockActivityService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            widgetViewBuilder: mockWidgetViewBuilder,
            topic: drivingTopic
        )
        let _ = sut.accountWidget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetLinkAction?()
        #expect(mockServiceAccountLinkCoordinator._startCalled == true)
    }

    @Test
    func accountWidget_unlinkAction_startsUnlinkAccount() {
        let drivingTopic = Topic.arrange(
            context: mockCoreDataViewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockServiceAccountUnlinkCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedServiceAccountUnlinkCoordinator = mockServiceAccountUnlinkCoordinator

        let sut = DrivingTopicDetailCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            topicsService: mockTopicsService,
            activityService: mockActivityService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            widgetViewBuilder: mockWidgetViewBuilder,
            topic: drivingTopic
        )
        let _ = sut.accountWidget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetUnlinkAction?()
        #expect(mockServiceAccountUnlinkCoordinator._startCalled == true)
    }
}

