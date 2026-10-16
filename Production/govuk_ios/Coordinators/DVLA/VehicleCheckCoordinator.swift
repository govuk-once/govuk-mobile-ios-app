import Foundation
import UIKit
import GovKit

final class VehicleCheckCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let urlOpener: URLOpener

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         urlOpener: URLOpener) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.configService = configService
        self.urlOpener = urlOpener
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        // reg number input view not implemented yet
        setVehicleRegistrationInputView()
        // show result screen for mock vehicle
//        setVehicleCheckResult(for: mockVehicle)
    }

    private func setVehicleCheckResult(for vehicle: VehicleEnquiryResponse.Vehicle) {
        let actions = VehicleCheckResultActions(
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            searchAction: {
                print("search tapped - not implemented yet")
            },
            dismissAction: {  [weak self] in
                self?.root.dismiss(animated: true)
            }
        )
        let viewController = viewControllerBuilder.vehicleCheckResult(
            vehicle: vehicle,
            analyticsService: analyticsService,
            configService: configService,
            actions: actions
        )
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        if let sheet = root.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.large()]
        }
        set(viewController)
    }

    override func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        super.presentationControllerDidDismiss(presentationController)
        trackHandleCloseEvent()
    }

    private func trackHandleCloseEvent() {
        let event = AppEvent.buttonNavigation(
            text: "Handle close",
            external: false,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }
}

// KK: breadcrumb
import SwiftUI
extension VehicleCheckCoordinator {
    private func setVehicleRegistrationInputView() {
//        let viewController = ViewControllerBuilder.vehicleRegistrationInputView(
//           ... blah blah blah...
//           we would construct our SwiftUI view and its `HostingViewController` in this method
//        )
        let view = PlaceholderView(onSubmit: { enteredText, searchResults in
            print("Searched for: \(enteredText)")
            print("Got results:", searchResults)

//            // 1. Create the search results hosting controller
//            let resultsView = SearchResultsView(searchQuery: enteredText)
//            let resultsHostingController = UIHostingController(rootView: resultsView)
//
//            // 2. Unhide the navigation bar since we are entering a standard screen stack
//            navController.setNavigationBarHidden(false, animated: true)
//
//            // 3. Push the search results onto the stack
//            navController.pushViewController(resultsHostingController, animated: true)
        },
                                   onCancel: { [weak self] in self?.dismiss(animated: true) }
        )

        let viewController = HostingViewController(
            rootView: view
        )
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.view.backgroundColor = .clear
        viewController.shouldAutoFocusVoiceover = false

//        root.modalPresentationStyle = .overCurrentContext
        root.modalTransitionStyle = .crossDissolve
//        root.view.backgroundColor = .clear
//        root.isNavigationBarHidden = false
        set(viewController)
    }
}

// MARK: Temporary - for development

extension VehicleCheckCoordinator {
    private var mockVehicle: VehicleEnquiryResponse.Vehicle {
        .init(
            vehicleId: 100830769,
            registrationNumber: "DF04 FSY",
            taxStatus: .taxed,
            taxedUntil: Date(timeIntervalSince1970: 1793491200),
            motStatus: .valid,
            motExpiryDate: Date(timeIntervalSince1970: 1793491200),
            make: "FORD",
            dateOfFirstRegistration: Date(timeIntervalSince1970: 1083369600),
            engineCapacity: 1242,
            exhaustEmissionsCo2: 147,
            fuelType: .petrol,
            colour: "BLACK",
            secondaryColour: nil
        )
    }
}
