import Foundation
import Testing
import FactoryKit
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct CoordinatorBuilderDVLATests {

    @Test
    func vehicleCheck_returnsExpectedResult() {
        let container = Container()
        container.analyticsService.register(factory: { MockAnalyticsService() })
        container.dvlaService.register(factory: { MockDVLAService() })
        let subject = CoordinatorBuilder(container: container)
        let coordinator = subject.vehicleCheck(
            navigationController: UINavigationController()
        )

        #expect(coordinator is VehicleCheckCoordinator)
    }

    @Test
    func vehicleDetail_returnsExpectedResult() {
        let container = Container()
        container.analyticsService.register(factory: { MockAnalyticsService() })
        container.dvlaService.register(factory: { MockDVLAService() })
        container.userService.register(factory: { MockUserService() })
        let subject = CoordinatorBuilder(container: container)
        let coordinator = subject.vehicleDetail(
            navigationController: UINavigationController(),
            vehicleId: 1
        )

        #expect(coordinator is VehicleDetailCoordinator)
    }

    @Test
    func licenceCategories_returnsExpectedResult() {
        let container = Container()
        container.analyticsService.register(factory: { MockAnalyticsService() })
        let subject = CoordinatorBuilder(container: container)
        let coordinator = subject.licenceCategoriesCoordinator(
            entitlements: [.arrange]
        )
        #expect(coordinator is LicenceCategoriesCoordinator)
    }
}
