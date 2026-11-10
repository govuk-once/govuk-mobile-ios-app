import UIKit
import SwiftUI
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct DWPTopicWidgetCoordinatorTests {

    let mockAnalyticsService = MockAnalyticsService()
    let mockConfigService = MockAppConfigService()
    let mockNavigationController = MockNavigationController()
    let mockWidgetViewBuilder = MockWidgetViewBuilder()
    let coreDataRepository: CoreDataRepository

    init() async {
        coreDataRepository = await CoreDataRepository.arrangeAndLoad
    }

    @Test
    func makeWidget_forBenefitsTopic_whenFeatureSwitchIsEnabled_returnsWidget() {
        let drivingTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "benefits"
        )
        mockConfigService.features = [.dwp]

        let sut = BenefitsWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let widgetView = sut.makeWidget(for: drivingTopic)
        #expect(widgetView != nil)
    }
}
