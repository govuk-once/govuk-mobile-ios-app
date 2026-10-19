import Foundation
import UIKit
import GovKit

final class VehicleCheckCoordinatorOLD: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let urlOpener: URLOpener

    private weak var frontMostViewController: UIViewController?

    private enum State {
        case inputRegistration
        case loading
        case result(String, [PlaceholderVehicleSearchResult]) // (VehicleEnquiryResponse.Vehicle)
    }

    private var currentState: State = .inputRegistration {
        didSet {
            render(state: currentState)
        }
    }

    private func render(state: State) {
        switch state {
        case .inputRegistration:
            setVehicleRegistrationInputView()
        case .loading:
            // do we need this, as our inputview will have the spinner?
            // setLoadingView())
            break
        case .result(let searchTerm, let searchResults):
            setShowSearchResults(searchTerm: searchTerm, results: searchResults)
//          setVehicleCheckResult(for: vehicle)
        }
    }

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
        currentState = .inputRegistration

        // reg number input view not implemented yet
//        setVehicleRegistrationInputView()
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
extension VehicleCheckCoordinatorOLD {
    private func setVehicleRegistrationInputView() {
        let viewController = createInputViewController()
        root.modalTransitionStyle = .crossDissolve

        if let frontMostViewController = frontMostViewController {
            frontMostViewController.topController.present(viewController, animated: true)
        } else {
            set(viewController)
        }
    }

    private func createInputViewController() -> UIViewController {
        //        let viewController = ViewControllerBuilder.vehicleRegistrationInputView(
        //           ... blah blah blah...
        //           we would construct our SwiftUI view and its `HostingViewController` in this method
        //        )

        let view = PlaceholderView(
            onSubmit: { [weak self] searchTerm, results in
                guard let self else { return }
                self.currentState = .result(searchTerm, results)
            },
            onCancel: { [weak self] in self?.dismiss(animated: true) }
        )

        let viewController = HostingViewController(
            rootView: view
        )
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.view.backgroundColor = .clear
        viewController.shouldAutoFocusVoiceover = false

        return viewController
    }

    private func setShowSearchResults(searchTerm: String,
                                      results: [PlaceholderVehicleSearchResult]) {
        print("Searched for: \(searchTerm)")
        print("Got placeholder results:", results)

        let resultsView = PlaceholderSearchResultsView(
            searchQuery: searchTerm,
            results: results,
            closeAction: { [weak self] in
                guard let self else { return }
                // KKTODO: do we need frontMostViewController?
                //          do we have it referenced somewhere in
                //          this coordinator or BaseCoordinator??
                self.frontMostViewController?.dismiss(animated: true)

                // following failed to dismiss the search results:
//                self.root.popViewController(animated: true)
//                self.root.dismiss(animated: true)
//                self.root.topViewController?.dismiss(animated: true)
//                self.root.dismiss(animated: true)
            },
            searchAction: {  [weak self] in
                guard let self else { return }
                self.currentState = .inputRegistration
            }
        )
        let resultsHostingController = UIHostingController(rootView: resultsView)

        // we need to create the navcontroller, because for some reason the
        // swiftui navstack does not appear...
        let navController = UINavigationController(rootViewController: resultsHostingController)
        navController.setNavigationBarHidden(false, animated: false)

        // configure it to present as a sheet...
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.large()]
        }

        // capture the presenting view controller before dismissing root
        guard let presentingViewController = root.presentingViewController else {
            // Fallback if root wasn't presented modally (e.g., pushed instead)
            root.pushViewController(resultsHostingController, animated: true)
            return
        }

//        // dismiss the input view's navigation controller, then present the search results sheet
//        root.dismiss(animated: false) {
//            presentingViewController.present(resultsHostingController, animated: true)
//        }

        // Dismiss root, and present the new sheet *after* the dismissal animation finishes,
        // or use a small DispatchQueue main async block to let UIKit settle its window hierarchy.
//        root.dismiss(animated: true) {
//            // Dispatching to main async prevents the layout/presentation collision
//            DispatchQueue.main.async {
//                presentingViewController.present(navController, animated: true)
//            }
//        }

        // 5. Use the native UIKit completion handler (No Task.sleep needed!)
        root.dismiss(animated: false) { [weak self] in
            guard let self else { return }
            // This block runs natively the exact moment the dismissal finishes.
            self.frontMostViewController = presentingViewController
            presentingViewController.present(navController, animated: true)
        }
    }
}

// MARK: Temporary - for development

extension VehicleCheckCoordinatorOLD {
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
