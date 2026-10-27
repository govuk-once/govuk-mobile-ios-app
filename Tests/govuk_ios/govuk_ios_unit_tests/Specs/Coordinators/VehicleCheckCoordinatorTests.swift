import Foundation
import GovKit
import SwiftUI
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct VehicleCheckCoordinatorTests {

    let mockViewControllerBuilder = MockViewControllerBuilder()
    let mockAnalyticsService = MockAnalyticsService()
    let mockConfigService = MockAppConfigService()
    let mockUrlOpener = MockURLOpener()
    let mockDvlaService = MockDVLAService()
    let mockRootNavigationController = MockNavigationController()

    private func makeCoordinator(
        closeBehaviour: VehicleCheckCoordinator.CloseBehaviour = .dismissAll
    ) -> VehicleCheckCoordinator {
        VehicleCheckCoordinator(
            navigationController: mockRootNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: mockAnalyticsService,
            configService: mockConfigService,
            urlOpener: mockUrlOpener,
            dvlaService: mockDvlaService,
            closeBehaviour: closeBehaviour
        )
    }

    // MARK: - Initial Flow & Start

    @Test
    func start_setsInitialInputState() {
        let sut = makeCoordinator()

        sut.start(url: nil)

        #expect(sut.state == .initialInput)
    }

    @Test
    func start_configuresRootNavigationControllerProperties() {
        let sut = makeCoordinator()

        sut.start(url: nil)

        #expect(mockRootNavigationController.view.backgroundColor == .clear)
        #expect(mockRootNavigationController.isNavigationBarHidden == true)
        #expect(mockRootNavigationController.modalTransitionStyle == .crossDissolve)
    }

    @Test
    func start_buildsAndSetsInitialRegistrationInputViewController() {
        let stubbedInputViewController = UIViewController()
        mockViewControllerBuilder._stubbedVehicleRegistrationInputViewController = stubbedInputViewController

        let sut = makeCoordinator()
        sut.start(url: nil)

        #expect(mockViewControllerBuilder._receivedVehicleRegistrationInputDvlaService != nil)
        #expect(mockRootNavigationController._setViewControllers?.first === stubbedInputViewController)
    }

    // MARK: - Initial Input Actions

    @Test
    func initialInput_cancelActionClosure_dismissesRootNavigationController() {
        let sut = makeCoordinator()
        sut.start(url: nil)

        guard let cancelAction = mockViewControllerBuilder._receivedVehicleRegistrationInputCancelAction else {
            Issue.record("Expected vehicleRegistrationInput cancelAction closure to be captured")
            return
        }

        cancelAction()

        #expect(mockRootNavigationController._dismissCalled == true)
        #expect(mockRootNavigationController._receivedDismissAnimated == true)
    }

    @Test
    func initialInput_completionActionClosure_updatesStateToResults() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter
        let vehicle = VehicleEnquiryResponse.Vehicle.arrange

        let sut = makeCoordinator()
        sut.start(url: nil)

        guard let completionAction = mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction else {
            Issue.record("Expected vehicleRegistrationInput completionAction closure to be captured")
            return
        }

        completionAction(vehicle)

        #expect(sut.state == .results(vehicle: vehicle))
    }

    @Test
    func initialInput_completionActionClosure_buildsVehicleCheckResultWithDependencies() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter
        let vehicle = VehicleEnquiryResponse.Vehicle.arrange

        let sut = makeCoordinator()
        sut.start(url: nil)

        guard let completionAction = mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction else {
            Issue.record("Expected vehicleRegistrationInput completionAction closure to be captured")
            return
        }

        completionAction(vehicle)

        #expect(mockViewControllerBuilder._receivedVehicleCheckResultVehicle?.vehicleId == vehicle.vehicleId)
        #expect(mockViewControllerBuilder._receivedVehicleCheckResultActions != nil)
    }

    @Test
    func initialInput_completionActionClosure_presentsResultSheetOnPresenter() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter
        let vehicle = VehicleEnquiryResponse.Vehicle.arrange

        let sut = makeCoordinator()
        sut.start(url: nil)

        guard let completionAction = mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction else {
            Issue.record("Expected vehicleRegistrationInput completionAction closure to be captured")
            return
        }

        completionAction(vehicle)

        #expect(mockPresenter._presentedViewController is UINavigationController)
    }

    // MARK: - Results Actions

    @Test
    func resultsActions_openURLActionClosure_callsURLOpener() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter
        let testURL = URL(string: "https://www.gov.uk/check-mot-status")!

        let sut = makeCoordinator()
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction?(VehicleEnquiryResponse.Vehicle.arrange)

        guard let actions = mockViewControllerBuilder._receivedVehicleCheckResultActions else {
            Issue.record("Expected vehicleCheckResult actions to be captured")
            return
        }

        actions.openURLAction(testURL)

        #expect(mockUrlOpener._receivedOpenIfPossibleUrl == testURL)
    }

    @Test
    func resultsActions_searchActionClosure_transitionsToNestedInputState() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter

        let sut = makeCoordinator()
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction?(VehicleEnquiryResponse.Vehicle.arrange)

        guard let actions = mockViewControllerBuilder._receivedVehicleCheckResultActions else {
            Issue.record("Expected vehicleCheckResult actions to be captured")
            return
        }

        actions.searchAction()

        #expect(sut.state == .nestedInput)
    }

    @Test
    func resultsActions_searchActionClosure_buildsNestedRegistrationInput() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter

        let sut = makeCoordinator()
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction?(VehicleEnquiryResponse.Vehicle.arrange)
        mockViewControllerBuilder._receivedVehicleRegistrationInputDvlaService = nil

        guard let actions = mockViewControllerBuilder._receivedVehicleCheckResultActions else {
            Issue.record("Expected vehicleCheckResult actions to be captured")
            return
        }

        actions.searchAction()

        #expect(mockViewControllerBuilder._receivedVehicleRegistrationInputDvlaService != nil)
        #expect(mockViewControllerBuilder._receivedVehicleRegistrationInputCancelAction != nil)
        #expect(mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction != nil)
    }

    // MARK: - Nested Flow & Stacked Sheets

    @Test
    func nestedRegistrationInput_completionActionClosure_updatesStateToNewVehicleResult() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter
        let initialVehicle = VehicleEnquiryResponse.Vehicle.arrange

        let sut = makeCoordinator()
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction?(initialVehicle)

        guard let actions = mockViewControllerBuilder._receivedVehicleCheckResultActions else {
            Issue.record("Expected vehicleCheckResult actions to be captured")
            return
        }

        actions.searchAction()

        guard let nestedCompletion = mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction else {
            Issue.record("Expected nested vehicleRegistrationInput completionAction to be captured")
            return
        }

        let newVehicle = VehicleEnquiryResponse.Vehicle.arrange
        nestedCompletion(newVehicle)

        #expect(sut.state == .results(vehicle: newVehicle))
        #expect(mockViewControllerBuilder._receivedVehicleCheckResultVehicle?.vehicleId == newVehicle.vehicleId)
    }

    // MARK: - Close & Dismissal Behaviour

    @Test
    func resultsActions_dismissActionClosure_whenDismissAll_dismissesFlow() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter

        let sut = makeCoordinator(closeBehaviour: .dismissAll)
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction?(VehicleEnquiryResponse.Vehicle.arrange)

        guard let actions = mockViewControllerBuilder._receivedVehicleCheckResultActions else {
            Issue.record("Expected vehicleCheckResult actions to be captured")
            return
        }

        actions.dismissAction()

        #expect(mockRootNavigationController._dismissCalled == true)
        #expect(mockRootNavigationController._receivedDismissAnimated == true)
    }

    @Test
    func resultsActions_dismissActionClosure_whenDismissTopmostOnPrimarySheet_dismissesFlow() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter

        let sut = makeCoordinator(closeBehaviour: .dismissTopmost)
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction?(VehicleEnquiryResponse.Vehicle.arrange)

        guard let actions = mockViewControllerBuilder._receivedVehicleCheckResultActions else {
            Issue.record("Expected vehicleCheckResult actions to be captured")
            return
        }

        actions.dismissAction()

        #expect(mockRootNavigationController._dismissCalled == true)
        #expect(mockRootNavigationController._receivedDismissAnimated == true)
    }

    // MARK: - UIPresentationControllerDelegate

    @Test
    func presentationControllerDidDismiss_whenPresentedViewControllerIsNotPrimarySheet_resetsStateToInitialInput() {
        let mockPresenter = MockNavigationController()
        mockRootNavigationController._stubbedPresentingViewController = mockPresenter

        let sut = makeCoordinator()
        sut.start(url: nil)
        mockViewControllerBuilder._receivedVehicleRegistrationInputCompletionAction?(VehicleEnquiryResponse.Vehicle.arrange)

        let nonPrimaryViewController = UIViewController()
        let presentationController = UIPresentationController(
            presentedViewController: nonPrimaryViewController,
            presenting: nil
        )

        sut.presentationControllerDidDismiss(presentationController)

        #expect(sut.state == .initialInput)
    }
}
