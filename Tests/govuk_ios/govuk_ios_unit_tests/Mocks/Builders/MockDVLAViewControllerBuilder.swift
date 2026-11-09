import Foundation
import UIKit
import SwiftUI
import GovKit

@testable import govuk_ios

final class MockDVLAViewControllerBuilder: DVLAViewControllerBuilding, ErrorViewControllerBuilding {

    var _stubbedVehicleDetailController: UIViewController?
    var _receivedVehicleDetailOpenURLAction: ((URL) -> Void)?
    func vehicleDetail(
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService configServive: AppConfigServiceInterface,
        openURLAction: @escaping (URL) -> Void,
        vehicleId: Int
    ) -> UIViewController {
        _receivedVehicleDetailOpenURLAction = openURLAction
        return _stubbedVehicleDetailController ?? UIViewController()
    }


    var _stubbedVehicleRegistrationInputViewController: UIViewController?
    var _receivedVehicleRegistrationInputDvlaService: DVLAServiceInterface?
    var _receivedVehicleRegistrationInputCancelAction: (() -> Void)?
    var _receivedVehicleRegistrationInputCompletionAction: ((VehicleEnquiryResponse.Vehicle) -> Void)?

    func vehicleRegistrationInput(
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        cancelAction: @escaping () -> Void,
        completionAction: @escaping (VehicleEnquiryResponse.Vehicle) -> Void
    ) -> UIViewController {
        _receivedVehicleRegistrationInputDvlaService = dvlaService
        _receivedVehicleRegistrationInputCancelAction = cancelAction
        _receivedVehicleRegistrationInputCompletionAction = completionAction
        return _stubbedVehicleRegistrationInputViewController ?? UIViewController()
    }

    var _stubbedVehicleCheckResultViewController: UIViewController?
    var _receivedVehicleCheckResultVehicle: VehicleEnquiryResponse.Vehicle?
    var _receivedVehicleCheckResultAnalyticsService: AnalyticsServiceInterface?
    var _receivedVehicleCheckResultConfigService: AppConfigServiceInterface?
    var _receivedVehicleCheckResultActions: VehicleCheckResultActions?

    func vehicleCheckResult(
        vehicle: VehicleEnquiryResponse.Vehicle,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
        actions: VehicleCheckResultActions
    ) -> UIViewController {
        _receivedVehicleCheckResultVehicle = vehicle
        _receivedVehicleCheckResultAnalyticsService = analyticsService
        _receivedVehicleCheckResultConfigService = configService
        _receivedVehicleCheckResultActions = actions
        return _stubbedVehicleCheckResultViewController ?? UIViewController()
    }

    var _stubbedDvlaAuthenticationViewController: UIViewController?
    var _receivedDvlaAuthenticationCompletionAction: ((URL) -> Void)?
    var _receivedDvlaAuthenticationErrorAction: (() -> Void)?
    func dvlaAuthentication(
        authenticationService: AuthenticationServiceInterface,
        appEnvironmentService: AppEnvironmentServiceInterface,
        completionAction: @escaping (URL) -> Void,
        errorAction: @escaping () -> Void
    ) -> UIViewController {
        _receivedDvlaAuthenticationCompletionAction = completionAction
        _receivedDvlaAuthenticationErrorAction = errorAction
        return _stubbedDvlaAuthenticationViewController ?? UIViewController()
    }

    var _stubbedErrorController: UIViewController?
    var _receivedErrorViewModel: ErrorViewModel?
    func error(viewModel: ErrorViewModel) -> UIViewController {
        _receivedErrorViewModel = viewModel
        return _stubbedErrorController ?? UIViewController()
    }

    func licenceCategoryDetail(
        entitlement: Entitlement,
        analyticsService: AnalyticsServiceInterface,
        dismissAction: @escaping () -> Void
    ) -> UIViewController {
        UIViewController()
    }

    func licenceCategoryList(entitlements: [govuk_ios.Entitlement],
                             analyticsService: AnalyticsServiceInterface,
                             selectAction: @escaping (Entitlement) -> Void,
                             dismissAction: @escaping () -> Void
    ) -> UIViewController {
        UIViewController()
    }
}
