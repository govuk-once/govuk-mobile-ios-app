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
            addressSelectedAction: {},
            dismissed: {}
        )

        subject.start()
        #expect(navigationController.viewControllers.first == expectedViewController)
    }

    @Test
    func dragToDismiss_callsDismissed() async {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()
        mockViewControllerBuilder._stubbedLocalWastePostcodeEntryViewController = expectedViewController

        await confirmation("dismiss called") { confirm in
            let sut = EditLocalWasteCoordinator(
                navigationController: navigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                addressSelectedAction: {},
                dismissed: {
                    confirm()
                }
            )
            mockCoordinator.start(sut)
            sut.presentationControllerDidDismiss(sut.root.presentationController!)
        }
    }

    @Test
    func postcodeEntryView_dismissAction_callsDismissed() async {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()

        mockViewControllerBuilder._stubbedLocalWastePostcodeEntryViewController = expectedViewController

        var sut: EditLocalWasteCoordinator!
        await confirmation("dismiss called") { confirm in
            sut = EditLocalWasteCoordinator(
                navigationController: mockNavigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                addressSelectedAction: {},
                dismissed: {
                    confirm()
                }
            )
            mockCoordinator.start(sut)
            mockViewControllerBuilder._receivedLocalWastePostcodeDismissAction?()
        }

        #expect(mockCoordinator._childDidFinishReceivedChild == sut)
        #expect(sut != nil)
        #expect(mockNavigationController._dismissCalled)
        #expect(mockNavigationController._receivedDismissAnimated == true)
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
            addressSelectedAction: {},
            dismissed: {}
        )
        mockCoordinator.start(sut)
        mockViewControllerBuilder._receivedLocalWastePostcodeDoneAction?(expectedAddresses)
        #expect(navigationController.viewControllers.last == expectedViewController)
        #expect(mockViewControllerBuilder._receivedLocalWasteAddressSelectionAddresses == expectedAddresses)
    }

    @Test
    func addressSelectionView_dismissAction_callsDismissed() async throws {
        let expectedAddresses = [
            LocalWasteAddress(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1")
        ]
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()
        mockViewControllerBuilder._stubbedLocalWasteAddressSelectionEntryViewController = expectedViewController

        var sut: EditLocalWasteCoordinator!
        await confirmation("dismiss called") { confirm in
            var addressSelectedCalled = false
            var confirmOnDismiss = false
            sut = EditLocalWasteCoordinator(
                navigationController: mockNavigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                addressSelectedAction: {
                    addressSelectedCalled = true
                },
                dismissed: {
                    if confirmOnDismiss && !addressSelectedCalled {
                        confirm()
                    }
                }
            )

            mockCoordinator.start(sut)
            mockViewControllerBuilder._receivedLocalWastePostcodeDoneAction?(expectedAddresses)

            confirmOnDismiss = true
            mockViewControllerBuilder._receivedLocalWasteAddressSelectionDismissAction?()
        }
        #expect(mockCoordinator._childDidFinishReceivedChild == sut)
        #expect(sut != nil)
        #expect(mockNavigationController._dismissCalled)
        #expect(mockNavigationController._receivedDismissAnimated == true)
    }

    @Test
    func addressSelectionView_doneAction_callsAddressSelectedActionAndDismissed() async throws {
        let expectedAddresses = [
            LocalWasteAddress(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1")
        ]
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()
        mockViewControllerBuilder._stubbedLocalWasteAddressSelectionEntryViewController = expectedViewController

        var sut: EditLocalWasteCoordinator!
        await confirmation("dismiss called") { confirm in
            var addressSelectedCalled = false
            var confirmOnDismiss = false
            sut = EditLocalWasteCoordinator(
                navigationController: mockNavigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                addressSelectedAction: {
                    addressSelectedCalled = true
                },
                dismissed: {
                    if confirmOnDismiss && addressSelectedCalled {
                        confirm()
                    }
                }
            )

            mockCoordinator.start(sut)
            mockViewControllerBuilder._receivedLocalWastePostcodeDoneAction?(expectedAddresses)

            confirmOnDismiss = true
            mockViewControllerBuilder._receivedLocalWasteAddressSelectionDoneAction?()
        }
        #expect(mockCoordinator._childDidFinishReceivedChild == sut)
        #expect(sut != nil)
        #expect(mockNavigationController._dismissCalled)
        #expect(mockNavigationController._receivedDismissAnimated == true)
    }
}
