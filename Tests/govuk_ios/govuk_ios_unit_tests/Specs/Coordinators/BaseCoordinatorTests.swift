import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct BaseCoordinatorTests {

    @Test
    func init_setsPresentationController() {
        let navigationController = UINavigationController()
        let subject = BaseCoordinator(navigationController: navigationController)

        #expect(navigationController.presentationController?.delegate === subject)
    }

    @Test
    func presentationControllerDidDismiss_callsFinish() async {
        let navigationController = UINavigationController()
        let subject = TestCoordinator(navigationController: navigationController)
        let parentCoordinator = MockBaseCoordinator()
        parentCoordinator.start(subject)

        let child = await withCheckedContinuation { continuation in
            parentCoordinator._childDidFinishHandler = { child in
                continuation.resume(returning: child)
            }
            let presentationController = UIPresentationController(
                presentedViewController: .init(),
                presenting: .init()
            )
            subject.presentationControllerDidDismiss(presentationController)
        }

        #expect(child == subject)
    }

    @Test
    func push_addsViewControllerToStack() {
        let navigationController = UINavigationController()
        let subject = TestCoordinator(navigationController: navigationController)

        let viewController1 = UIViewController()
        navigationController.viewControllers = [viewController1]

        let viewController2 = UIViewController()

        subject.push(viewController2, animated: false)

        #expect(navigationController.viewControllers.contains(viewController1))
        #expect(navigationController.viewControllers.contains(viewController2))
    }

    @Test
    func setViewController_addsViewControllerToStack() {
        let navigationController = UINavigationController()
        let subject = TestCoordinator(navigationController: navigationController)

        let viewController1 = UIViewController()
        navigationController.viewControllers = [viewController1]

        let viewController2 = UIViewController()
        subject.set(viewController2, animated: false)

        #expect(navigationController.viewControllers.contains(viewController1) == false)
        #expect(navigationController.viewControllers.contains(viewController2))
    }

    @Test
    func setViewControllers_addsViewControllerToStack() {
        let navigationController = UINavigationController()
        let subject = TestCoordinator(navigationController: navigationController)

        let viewController1 = UIViewController()
        navigationController.viewControllers = [viewController1]

        let viewController2 = UIViewController()
        let viewController3 = UIViewController()
        subject.set(
            [
                viewController2,
                viewController3
            ],
            animated: false
        )

        #expect(navigationController.viewControllers.count == 2)
    }

    @Test
    func viewControllerPopped_finalViewController_callsFinish() async throws {
        let parentCoordinator = MockBaseCoordinator()
        let navigationController = parentCoordinator.root
        let window = try #require(UIApplication.shared.window)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        //Requires TestCoordinator to prevent crash when calling start()
        let subject = TestCoordinator(navigationController: navigationController)
        parentCoordinator.start(subject)

        navigationController.pushViewController(UIViewController(), animated: false)

        subject.push(UIViewController(), animated: false)

        let completed = await withCheckedContinuation { @MainActor continuation in
            parentCoordinator._childDidFinishHandler = { @MainActor child in
                continuation.resume(returning: true)
            }
            navigationController.popViewController(animated: false)
            // This fixes the timeout issue seen when running this test
            // in CI/CD.  The underlying reason for the time out is that
            // the childDidFinishHandler relies on navigationController:didShow:animated
            // delegate method being invoked after popping the viewController,
            // which would often fail because the view heirarchy didn't get a chance
            // to get in the right state for the call back to happen
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }

        #expect(completed)
    }

    @Test
    func startCoordinator_startsCoordinator() {
        let navigationController = UINavigationController()
        let child = MockBaseCoordinator(navigationController: navigationController)
        let subject = TestCoordinator(navigationController: navigationController)

        subject.start(child)

        #expect(child._startCalled)
    }

    @Test
    func presentCoordinator_startsCoordinator() throws {
        let childNavigationController = UINavigationController()
        let child = MockBaseCoordinator(navigationController: childNavigationController)

        let navigationController = MockNavigationController()
        let subject = TestCoordinator(navigationController: navigationController)
        let window = try #require(UIApplication.shared.window)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        subject.present(
            child,
            animated: false
        )

        #expect(child._startCalled)
        #expect(navigationController._presentedViewController == childNavigationController)
    }

    @Test
    func dismiss_modal_callsDismiss() throws {
        let mockNavigationController = MockNavigationController()
        let subject = TestCoordinator(navigationController: mockNavigationController)

        let parentNavigationController = UINavigationController()
        let parent = MockBaseCoordinator(navigationController: parentNavigationController)
        let window = try #require(UIApplication.shared.window)
        window.rootViewController = parentNavigationController
        window.makeKeyAndVisible()

        parent.present(subject, animated: false)

        mockNavigationController._stubbedPresentingViewController = parentNavigationController
        subject.dismiss(animated: false)

        #expect(mockNavigationController._dismissCalled)
    }

    @Test
    func dismiss_pushed_callsPop() {
        let mockNavigationController = MockNavigationController()
        let subject = TestCoordinator(navigationController: mockNavigationController)

        let parent = MockBaseCoordinator(navigationController: mockNavigationController)
        parent.start(subject)

        subject.dismiss(animated: false)

        #expect(mockNavigationController._popCalled)
    }
}

//@MainActor
//class BaseCoordinatorTests: XCTestCase {
//    func test_viewControllerPopped_remainingViewControllers_doesNothing() {
//        let navigationController = UINavigationController()
//        let subject = TestCoordinator(navigationController: navigationController)
//
//        let parentCoordinator = MockBaseCoordinator()
//        parentCoordinator.start(subject)
//
//        subject.push(UIViewController(), animated: false)
//        subject.push(UIViewController(), animated: false)
//
//        let expectation = expectation()
//        var completionCalled = false
//        parentCoordinator._childDidFinishHandler = { child in
//            completionCalled = true
//        }
//
//        navigationController.popViewController(animated: false)
//
//        expectation.fulfillAfter(0.2)
//        waitForExpectations(
//            timeout: 0.5,
//            handler: { _ in
//                Task { @MainActor in
//                    XCTAssertFalse(completionCalled)
//                }
//            }
//        )
//    }
//}

private class TestCoordinator: BaseCoordinator {

    override func start(url: URL?) { }

}
