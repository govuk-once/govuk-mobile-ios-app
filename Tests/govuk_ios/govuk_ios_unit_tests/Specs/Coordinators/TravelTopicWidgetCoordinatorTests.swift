import UIKit
import SwiftUI
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct TravelTopicWidgetCoordinatorTests {

    let mockAnalyticsService = MockAnalyticsService()
    let mockConfigService = MockAppConfigService()
    let mockTravelService = MockTravelService()
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

        let sut = TravelTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener()
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

        let sut = TravelTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener()
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

        let sut = TravelTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            configService: mockConfigService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            urlOpener: MockURLOpener()
        )
        let widgetView = sut.makeWidget(for: travelTopic)
        #expect(widgetView == nil)
    }

}
