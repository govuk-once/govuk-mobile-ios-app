import Foundation
import UIKit
import Testing

@testable import govuk_ios

@MainActor
@Suite("Coordinator Memory Leak Verifications")
struct CoordinatorLeakTests {

    final class TestCoordinator: BaseCoordinator {
        override func start(url: URL? = nil) {}
    }

    @Test("Demonstrate Parent-Child strong reference retain cycle")
    func testParentChildRetainCycle() {
        weak var weakParent: TestCoordinator?
        weak var weakChild: TestCoordinator?

        // Execute inside an isolated scope so strong local pointers go out of scope
        do {
            let parent = TestCoordinator(navigationController: UINavigationController())
            let child = TestCoordinator(navigationController: UINavigationController())

            weakParent = parent
            weakChild = child

            parent.start(child)
        }

        // Both objects retain each other indefinitely.
        #expect(weakParent != nil, "Expected memory leak: parent is retained by child")
        #expect(weakChild != nil, "Expected memory leak: child is retained by parent")
    }

    @Test("Demonstrate delegate hijacking prevents deallocation")
    func testDelegateHijackingLeak() {
        let nav = UINavigationController()
        let grandParent = TestCoordinator(navigationController: nav)

        weak var weakParent: TestCoordinator?

        do {
            let parent = TestCoordinator(navigationController: nav)
            weakParent = parent
            grandParent.start(parent)

            let parentVC = UIViewController()
            parent.push(parentVC, animated: false)

            // Child overrides nav.delegate
            let child = TestCoordinator(navigationController: nav)
            parent.start(child)
            child.finish() // child is pruned, but nav.delegate was left unrestored
        }

        // Clear view controllers to trigger navigationController(_:didShow:animated:)
        nav.setViewControllers([], animated: false)

        // Force call delegate manually to emulate the transition end callback
        if let currentDelegate = nav.delegate {
            let dummyVC = UIViewController()
            currentDelegate.navigationController?(nav, didShow: dummyVC, animated: false)
        }

        // Grandparent fails to prune parent because parent never received didShow
        #expect(
            grandParent.childCoordinators.contains(where: { $0 === weakParent }),
            "Expected leak: Grandparent failed to prune parent due to overwritten delegate"
        )
    }
}
