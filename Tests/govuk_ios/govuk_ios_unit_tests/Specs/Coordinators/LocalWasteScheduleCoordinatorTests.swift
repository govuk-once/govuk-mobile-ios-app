import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct LocalWasteScheduleCoordinatorTests {

    @Test
    func start_setsLocalWastePostcodeEntryView() throws {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()
        mockViewControllerBuilder._stubbedLocalWasteScheduleViewController = expectedViewController

        let subject = LocalWasteScheduleCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            localWasteService: MockLocalWasteService(),
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
        let mockCoordinator = MockBaseCoordinator()
        mockViewControllerBuilder._stubbedLocalWasteScheduleViewController = expectedViewController

        await confirmation("dismiss called") { confirm in
            let sut = LocalWasteScheduleCoordinator(
                navigationController: navigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                dismissed: {
                    confirm()
                }
            )
            mockCoordinator.start(sut)
            sut.presentationControllerDidDismiss(sut.root.presentationController!)
        }
    }

    @Test
    func scheduleView_dismissAction_callsDismissed() async {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let mockNavigationController = MockNavigationController()
        let mockCoordinator = MockBaseCoordinator()

        mockViewControllerBuilder._stubbedLocalWasteScheduleViewController = expectedViewController

        var sut: LocalWasteScheduleCoordinator!
        await confirmation("dismiss called") { confirm in
            sut = LocalWasteScheduleCoordinator(
                navigationController: mockNavigationController,
                viewControllerBuilder: mockViewControllerBuilder,
                analyticsService: MockAnalyticsService(),
                localWasteService: MockLocalWasteService(),
                dismissed: {
                    confirm()
                }
            )
            mockCoordinator.start(sut)
            mockViewControllerBuilder._receivedLocalWasteScheduleDismissAction?()
        }

        #expect(mockCoordinator._childDidFinishReceivedChild == sut)
        #expect(sut != nil)
        #expect(mockNavigationController._dismissCalled)
        #expect(mockNavigationController._receivedDismissAnimated == true)
    }
}
