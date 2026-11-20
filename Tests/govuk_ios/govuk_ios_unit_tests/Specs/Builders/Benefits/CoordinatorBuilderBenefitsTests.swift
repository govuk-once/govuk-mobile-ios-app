import Foundation
import Testing
import FactoryKit
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct CoordinatorBuilderBenefitsTests {

    @Test
    func benefits_returnsExpectedResult() {
        let container = Container()
        container.analyticsService.register(factory: { MockAnalyticsService() })
        let subject = CoordinatorBuilder(container: container)
        let coordinator = subject.benefitsContainer(
            navigationController: UINavigationController(),
            viewControllerBuilder: ViewControllerBuilder()
        )

        #expect(coordinator is BenefitsContainerCoordinator)
    }
}

