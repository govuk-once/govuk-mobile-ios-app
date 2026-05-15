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
    let coreDataRepository: CoreDataRepository

    init() async {
        coreDataRepository = await CoreDataRepository.arrangeAndLoad
    }

    @Test
    func makeWidget_forDrivingTopic_whenFeatureSwitchIsEnabled_returnsWidget() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
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
        let widgetView = sut.makeWidget(for: drivingTopic)
        #expect(widgetView != nil)
    }

    @Test
    func makeWidget_forDrivingTopic_whenFeatureSwitchIsDisabled_returnsNil() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
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
        let widgetView = sut.makeWidget(for: drivingTopic)
        #expect(widgetView == nil)
    }

    @Test
    func makeWidget_forNonDrivingTopic_returnsNil() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
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
        let widgetView = sut.makeWidget(for: drivingTopic)
        #expect(widgetView == nil)
    }

    @Test
    func makeWidget_linkAction_startsLinkAccount() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
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
        let _ = sut.makeWidget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetLinkAction?()
        #expect(mockServiceAccountLinkCoordinator._startCalled == true)
    }

    @Test
    func makeWidget_unlinkAction_startsUnlinkAccount() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
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
        let _ = sut.makeWidget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetUnlinkAction?()
        #expect(mockServiceAccountUnlinkCoordinator._startCalled == true)
    }

    @Test
    func makeWidget_viewLicenceAction_startsDvlaAccount() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockDvlaAccountCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedDvlaAccountCoordinator = mockDvlaAccountCoordinator

        let sut = DrivingTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: mockCoordinatorBuilder,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let _ = sut.makeWidget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetViewLicenceAction?()
        #expect(mockDvlaAccountCoordinator._startCalled == true)
    }

    @Test
    func makeWidget_viewShareCodesAction_startsDvlaAccount() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "driving-transport"
        )
        mockConfigService.features = [.dvla]
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockDvlaAccountCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedDvlaAccountCoordinator = mockDvlaAccountCoordinator

        let sut = DrivingTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            userService: mockUserService,
            dvlaService: mockDvlaService,
            coordinatorBuilder: mockCoordinatorBuilder,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let _ = sut.makeWidget(for: drivingTopic)
        mockWidgetViewBuilder._receivedDvlaAccountWidgetViewShareCodesAction?()
        #expect(mockDvlaAccountCoordinator._startCalled == true)
    }
}

