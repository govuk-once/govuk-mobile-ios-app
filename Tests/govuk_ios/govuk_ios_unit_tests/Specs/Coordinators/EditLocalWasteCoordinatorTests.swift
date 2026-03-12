import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct EditLocalWasteCoordinatorTests {

    @Test
    func start_setsLocalWastePostcodeEntryView() throws {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        mockViewControllerBuilder._stubbedLocalWastePostcodeEntryViewController = expectedViewController

        let subject = EditLocalWasteCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            localWasteService: MockLocalWasteService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            dismissed: {}
        )

        subject.start()
        #expect(navigationController.viewControllers.first == expectedViewController)
    }

    @Test
    func cancelButton_callsDismissed() async {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()

        mockViewControllerBuilder._stubbedLocalWastePostcodeEntryViewController = expectedViewController
        var sut: EditLocalWasteCoordinator!
        let dismissed = await withCheckedContinuation { continuation in
              sut = EditLocalWasteCoordinator(
                navigationController: mockNavigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                dismissed: {
                    continuation.resume(returning: true)
                }
            )
            mockCoordinator.start(sut)
            mockViewControllerBuilder._receivedLocalWastePostcodeDismissAction?()
        }
        
        #expect(dismissed)
        #expect(mockCoordinator._childDidFinishReceivedChild == sut)
        #expect(sut != nil)
        #expect(mockNavigationController._dismissCalled)
        #expect(mockNavigationController._receivedDismissAnimated == true)
    }

    @Test
    func dragToDismiss_callsDismissed() async {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()
        mockViewControllerBuilder._stubbedLocalWastePostcodeEntryViewController = expectedViewController

        let dismissed = await withCheckedContinuation { continuation in
            let sut = EditLocalWasteCoordinator(
                navigationController: navigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                dismissed: {
                    continuation.resume(returning: true)
                }
            )
            mockCoordinator.start(sut)
            sut.presentationControllerDidDismiss(sut.root.presentationController!)
        }
        #expect(dismissed)
    }

    @Test
    func postcodeEntryView_doneAction_navigatesToAddressSelectionView() async throws {
        let expectedAddresses = [
            LocalWasteAddress(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1")
        ]
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()
        mockViewControllerBuilder._stubbedLocalWasteAddressSelectionEntryViewController = expectedViewController

        let sut = EditLocalWasteCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            localWasteService: MockLocalWasteService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            dismissed: {}
        )
        mockCoordinator.start(sut)
        mockViewControllerBuilder._receivedLocalWastePostcodeDoneAction?(expectedAddresses)
        #expect(navigationController.viewControllers.last == expectedViewController)
        #expect(mockViewControllerBuilder._receivedLocalWasteAddressSelectionAddresses == expectedAddresses)
    }
}
