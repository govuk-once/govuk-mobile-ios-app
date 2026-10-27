import Foundation
import GovKit
import SwiftUI
import UIKit

/// Manages the vehicle check flow, coordinating registration plate input, DVLA lookups, and stacked result sheets.
///
/// Coordinates transitions between registration plate entry forms and search results.
/// Supports nested searches and managing UIKit modal sheet dismissal lifecycles.
@MainActor
final class VehicleCheckCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let urlOpener: URLOpener
    private let dvlaService: DVLAServiceInterface
    private let closeBehaviour: CloseBehaviour

    private weak var primarySheet: UINavigationController?

    enum CloseBehaviour {
        case dismissAll
        case dismissTopmost
    }

    enum FlowState: Equatable {
        case initialInput
        case results(vehicle: VehicleEnquiryResponse.Vehicle)
        case nestedInput

        static func == (lhs: FlowState, rhs: FlowState) -> Bool {
            switch (lhs, rhs) {
            case (.initialInput, .initialInput),
                 (.nestedInput, .nestedInput):
                return true

            case (.results(let lhsVehicle), .results(let rhsVehicle)):
                return lhsVehicle.vehicleId == rhsVehicle.vehicleId

            default:
                return false
            }
        }
    }
    private(set) var state: FlowState = .initialInput

    init(
        navigationController: UINavigationController,
        viewControllerBuilder: ViewControllerBuilder,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface,
        urlOpener: URLOpener,
        dvlaService: DVLAServiceInterface,
        closeBehaviour: CloseBehaviour = .dismissAll
    ) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.configService = configService
        self.urlOpener = urlOpener
        self.dvlaService = dvlaService
        self.closeBehaviour = closeBehaviour
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        transition(to: .initialInput)
    }

    // MARK: - State Machine

    private func transition(to newState: FlowState) {
        state = newState

        switch newState {
        case .initialInput:
            showInitialInput()
        case .results(let vehicle):
            showResultsView(vehicle: vehicle)
        case .nestedInput:
            showNestedInput()
        }
    }

    // MARK: - Navigation & Presentation Logic

    private var topmostViewController: UIViewController {
        var current: UIViewController = primarySheet ?? root
        while let next = current.presentedViewController, !next.isBeingDismissed {
            current = next
        }
        return current
    }

    private func showInitialInput() {
        let viewController = viewControllerBuilder.vehicleRegistrationInput(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            cancelAction: { [weak self] in
                guard let self else { return }
                VehicleCheckAnalytics.trackCancelButtonTapEvent(
                    analyticsService: self.analyticsService
                )
                self.dismissFlow()
            },
            completionAction: { [weak self] vehicle in
                self?.transition(to: .results(vehicle: vehicle))
            }
        )
        root.view.backgroundColor = .clear
        root.setNavigationBarHidden(true, animated: false)
        root.modalTransitionStyle = .crossDissolve
        set(viewController)
    }

    private func showNestedInput() {
        let viewController = viewControllerBuilder.vehicleRegistrationInput(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            cancelAction: { [weak self] in
                guard let self else { return }
                VehicleCheckAnalytics.trackCancelButtonTapEvent(
                    analyticsService: self.analyticsService
                )
                self.topmostViewController.dismiss(animated: true)
            },
            completionAction: { [weak self] vehicle in
                self?.transition(to: .results(vehicle: vehicle))
            }
        )

        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        navController.view.backgroundColor = .clear

        topmostViewController.present(navController, animated: true)
    }

    private func showResultsView(vehicle: VehicleEnquiryResponse.Vehicle) {
        let actions = VehicleCheckResultActions(
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            searchAction: { [weak self] in
                self?.transition(to: .nestedInput)
            },
            dismissAction: { [weak self] in
                self?.handleClose()
            }
        )

        let hostingController = viewControllerBuilder.vehicleCheckResult(
            vehicle: vehicle,
            analyticsService: analyticsService,
            configService: configService,
            actions: actions
        )

        let newSheet = UINavigationController(rootViewController: hostingController)
        newSheet.presentationController?.delegate = self

        if primarySheet == nil {
            presentAsFirstSheet(newSheet)
        } else {
            presentAsStackedSheet(newSheet)
        }
    }

    private func presentAsFirstSheet(_ sheet: UINavigationController) {
        guard let presenter = root.presentingViewController else {
            assertionFailure("root has no presentingViewController — cannot present results")
            return
        }

        primarySheet = sheet
        presenter.present(sheet, animated: true) { [weak self] in
            self?.root.dismiss(animated: false)
        }
    }

    private func presentAsStackedSheet(_ sheet: UINavigationController) {
        let topVC = topmostViewController
        let presentingContext = topVC.presentingViewController ?? topVC

        topVC.dismiss(animated: false) {
            presentingContext.present(sheet, animated: true)
        }
    }

    // MARK: - Dismissal Logic

    private func handleClose() {
        switch closeBehaviour {
        case .dismissAll:
            dismissFlow()
        case .dismissTopmost:
            dismissTopmostSheet()
        }
    }

    private func dismissTopmostSheet() {
        let topVC = topmostViewController
        // Resolve target sheet against navigation hierarchy container
        let targetNav = (topVC as? UINavigationController) ?? topVC.navigationController

        // Only tear down the whole flow if the sheet being closed is the primary sheet
        if targetNav === primarySheet || topVC === primarySheet {
            dismissFlow()
        } else {
            topVC.dismiss(animated: true)
        }
    }

    private func dismissFlow() {
        if let sheet = primarySheet,
           let presenter = sheet.presentingViewController {
            presenter.dismiss(animated: true) { [weak self] in
                self?.cleanupAndFinish()
            }
        } else {
            root.dismiss(animated: true) { [weak self] in
                self?.cleanupAndFinish()
            }
        }
    }

    private func cleanupAndFinish() {
        primarySheet = nil
        finish()
    }

    // MARK: - UIPresentationControllerDelegate

    override func presentationControllerDidDismiss(_
                presentationController: UIPresentationController
    ) {
        let dismissedVC = presentationController.presentedViewController

        if dismissedVC === primarySheet {
            super.presentationControllerDidDismiss(presentationController)
            cleanupAndFinish()
        } else {
            // A nested stacked sheet was swiped away - keep the coordinator alive
            // and sync state back to the active underlying sheet.
            state = .initialInput // or update to reflect the underlying active result
        }
    }
}
