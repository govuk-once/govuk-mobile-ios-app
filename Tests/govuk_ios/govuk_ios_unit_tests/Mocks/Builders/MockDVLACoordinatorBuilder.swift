import UIKit
import Foundation
import FactoryKit

@testable import govuk_ios

final class MockDVLACoordinatorBuilder: DVLACoordinatorBuilding, ServiceAccountCoordinatorBuilding {
    var _stubbedVehicleDetailCoordinator: BaseCoordinator?
    var _receivedVehicleDetailNavigationController: UINavigationController?
    var _receivedVehicleDetailId: Int?

    func vehicleCheck(navigationController: UINavigationController) -> BaseCoordinator {
        MockBaseCoordinator()
    }

    func vehicleDetail(navigationController: UINavigationController, vehicleId: Int) -> BaseCoordinator {
        _receivedVehicleDetailNavigationController = navigationController
        _receivedVehicleDetailId = vehicleId
        return _stubbedVehicleDetailCoordinator ?? MockBaseCoordinator()
    }

    func licenceCategories(
        navigationController: UINavigationController,
        entitlements: [Entitlement]
    ) -> BaseCoordinator {
        MockBaseCoordinator()
    }

    var _stubbedServiceAccountLinkCoordinator: MockBaseCoordinator?
    var _receivedServiceAccountLinkCompletion: ((Bool) -> Void)?
    func serviceAccountLink(navigationController: UINavigationController,
                                     accountType: ServiceAccountType,
                                     completion: @escaping (Bool) -> Void) -> BaseCoordinator {
        _receivedServiceAccountLinkCompletion = completion
        return _stubbedServiceAccountLinkCoordinator ?? MockBaseCoordinator()
    }

    var _stubbedServiceAccountUnlinkCoordinator: MockBaseCoordinator?
    func serviceAccountUnlink(navigationController: UINavigationController,
                                       accountType: ServiceAccountType,
                                       completion: @escaping () -> Void) -> BaseCoordinator {
          return _stubbedServiceAccountUnlinkCoordinator ?? MockBaseCoordinator()
    }

}
