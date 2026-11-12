import Foundation
import GovKit
import SwiftUI
import UIKit

@MainActor
protocol DVLAViewControllerBuilding: AnyObject {
    func vehicleDetail(
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        openURLAction: @escaping (URL) -> Void,
        vehicleId: Int
    ) -> UIViewController

    func dvlaAuthentication(
        authenticationService: AuthenticationServiceInterface,
        appEnvironmentService: AppEnvironmentServiceInterface,
        completionAction: @escaping (URL) -> Void,
        errorAction: @escaping () -> Void
    ) -> UIViewController

    func vehicleCheckResult(
        vehicle: VehicleEnquiryResponse.Vehicle,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
        actions: VehicleCheckResultActions
    ) -> UIViewController

    func vehicleRegistrationInput(
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        cancelAction: @escaping () -> Void,
        completionAction: @escaping (VehicleEnquiryResponse.Vehicle) -> Void
    ) -> UIViewController

    func licenceCategoryList(
        entitlements: [Entitlement],
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
        actions: CategoriesActions,
    ) -> UIViewController

    func licenceCategoryDetail(
        entitlement: Entitlement,
        analyticsService: AnalyticsServiceInterface,
        dismissAction: @escaping () -> Void
    ) -> UIViewController
}

/// factory methods related to DVLA functionality
@MainActor
extension ViewControllerBuilder: DVLAViewControllerBuilding {
    func vehicleDetail(
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        openURLAction: @escaping (URL) -> Void,
        vehicleId: Int
    ) -> UIViewController {
        let viewModel = VehicleDetailViewModel(
            vehicleId: vehicleId,
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            openURLAction: openURLAction
        )
        let view = VehicleDetailView(viewModel: viewModel)
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }

    func dvlaAuthentication(
        authenticationService: AuthenticationServiceInterface,
        appEnvironmentService: AppEnvironmentServiceInterface,
        completionAction: @escaping (URL) -> Void,
        errorAction: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = DVLAAuthenticationViewModel(
            authenticationService: authenticationService,
            appEnvironmentService: appEnvironmentService,
            completionAction: completionAction,
            errorAction: errorAction
        )
        let view = DVLAAuthenticationView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        return viewController
    }

    func vehicleCheckResult(
        vehicle: VehicleEnquiryResponse.Vehicle,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
        actions: VehicleCheckResultActions
    ) -> UIViewController {
        let viewModel = VehicleCheckResultViewModel(
            vehicle: vehicle,
            analyticsService: analyticsService,
            configService: configService,
            actions: actions
        )
        let view = VehicleCheckResultView(viewModel: viewModel)
        let viewController = HostingViewController(
            rootView: view
        )
        viewController.shouldAutoFocusVoiceover = false
        return viewController
    }

    func vehicleRegistrationInput(
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        cancelAction: @escaping () -> Void,
        completionAction: @escaping (VehicleEnquiryResponse.Vehicle) -> Void
    ) -> UIViewController {
        let viewModel = RegistrationNumberFormViewModel(
            lookupService: dvlaService.makeVehicleLookup(
                analyticsService: analyticsService
            ),
            onSuccess: completionAction,
            onCancel: cancelAction
        )
        let view = RegistrationNumberFormModal(
            viewModel: viewModel
        )

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear
        return hostingController
    }

    func licenceCategoryList(
        entitlements: [Entitlement],
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
        actions: CategoriesActions,
    ) -> UIViewController {
        let urls: DvlaURLs? = configService.dvlaUrls
        let links: [CategoryLink] = [
            CategoryLink(
                text: String(localized: .DVLA.compareOldAndNewCategories),
                // KK Stuff:
                url: urls?.compareOldNewLicenceCategories ??
                Constants.API.defaultDvlaCategoriesCompareOldAndNewUrl
            ),
            CategoryLink(
                text: String(localized: .DVLA.vehicleWeightsExplained),
                url: urls?.vehicleWeightExplained ??
                Constants.API.defaultDvlaCategoriesVehicleWeightsUrl
            ),
            CategoryLink(
                text: String(localized: .DVLA.addingCategoriesToYourVehicle),
                url: urls?.addCategoriesToLicence ??
                Constants.API.defaultDvlaCategoriesAddingCategoriesUrl
            ),
        ]

        let viewModel = CategoriesViewModel(entitlements: entitlements,
                                            actions: actions,
                                            links: links,
                                            analyticsService: analyticsService)

        let view = LicenceCategoriesView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        return viewController
    }

    // MARK: -

    func licenceCategoryDetail(
        entitlement: Entitlement,
        analyticsService: AnalyticsServiceInterface,
        dismissAction: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = LicenceCategoryDetailViewModel(
            entitlement: entitlement,
            analyticsService: analyticsService,
            dismissAction: dismissAction
        )
        let view = LicenceCategoryDetailView(viewModel: viewModel)
        let viewController = HostingViewController(rootView: view)
        return viewController
    }
}
