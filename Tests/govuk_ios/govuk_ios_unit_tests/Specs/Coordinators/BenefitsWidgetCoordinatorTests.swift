import UIKit
import SwiftUI
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct BenefitsWidgetCoordinatorTests {

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
        let benefitsTopic = Topic.arrange(
            context: coreDataRepository.viewContext,
            ref: "benefits"
        )
        mockConfigService.features = [.dwp]

        let sut = BenefitsTopicWidgetCoordinator(
            navigationController: UINavigationController(),
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            coordinatorBuilder: CoordinatorBuilder.mock,
            widgetViewBuilder: mockWidgetViewBuilder
        )
        let widgetView = sut.makeWidget(for: benefitsTopic)
        #expect(widgetView != nil)
    }
    
    @Test
       func makeWidget_forBenefitsTopic_whenFeatureSwitchIsDisabled_returnsNil() {
           let benefitsTopic = Topic.arrange(
               context: coreDataRepository.viewContext,
               ref: "benefits"
           )
           mockConfigService.features = []

           let sut = BenefitsTopicWidgetCoordinator(
               navigationController: UINavigationController(),
               analyticsService: mockAnalyticsService,
               configService: mockConfigService,
               coordinatorBuilder: CoordinatorBuilder.mock,
               widgetViewBuilder: mockWidgetViewBuilder
           )
           let widgetView = sut.makeWidget(for: benefitsTopic)

           #expect(widgetView == nil)
       }

       @Test
       func makeWidget_forNonBenefitsTopic_returnsNil() {
           let otherTopic = Topic.arrange(
               context: coreDataRepository.viewContext,
               ref: "driving"
           )
           mockConfigService.features = [.dwp]

           let sut = BenefitsTopicWidgetCoordinator(
               navigationController: UINavigationController(),
               analyticsService: mockAnalyticsService,
               configService: mockConfigService,
               coordinatorBuilder: CoordinatorBuilder.mock,
               widgetViewBuilder: mockWidgetViewBuilder
           )
           let widgetView = sut.makeWidget(for: otherTopic)

           #expect(widgetView == nil)
       }

}
