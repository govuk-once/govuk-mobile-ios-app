import Foundation
import UIKit
import Testing

@testable import govuk_ios

@MainActor
@Suite("Coordinator Memory Cleanup Verifications")
struct CoordinatorLeakTests {

    final class TestCoordinator: BaseCoordinator {
        override func start(url: URL? = nil) {}
    }

    @Test("Verify Parent and Child deallocate cleanly without retain cycles")
    func testParentChildRetainCycle() {
        weak var weakParent: TestCoordinator?
        weak var weakChild: TestCoordinator?

        do {
            let parent = TestCoordinator(navigationController: UINavigationController())
            let child = TestCoordinator(navigationController: UINavigationController())

            weakParent = parent
            weakChild = child

            parent.start(child)
        }

        // Fails if parentCoordinator is strong: parent and child retain each other indefinitely.
        #expect(
            weakParent == nil,
            "Memory leak detected: Parent coordinator was retained by child (strong retain cycle)"
        )
        #expect(
            weakChild == nil,
            "Memory leak detected: Child coordinator was retained in memory"
        )
    }

    @Test("Verify delegate restoration allows parent to finish and deallocate after pop")
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
            child.finish() // In buggy code: nav.delegate is left unrestored
        }

        // Pop all view controllers to trigger navigationController(_:didShow:animated:)
        nav.setViewControllers([], animated: false)

        // Simulate transition completion callback
        if let currentDelegate = nav.delegate {
            let dummyVC = UIViewController()
            currentDelegate.navigationController?(nav, didShow: dummyVC, animated: false)
        }

        // Fails if root.delegate was not restored to parent: parent never gets `didShow`,
        // never calls finish(), and remains trapped in grandParent's childCoordinators.
        #expect(
            !grandParent.childCoordinators.contains(where: { $0 === weakParent }),
            "Memory leak detected: Grandparent failed to prune parent because nav.delegate was hijacked"
        )
        #expect(
            weakParent == nil,
            "Memory leak detected: Parent coordinator failed to deallocate after being popped"
        )
    }
}
