import Foundation
import UIKit
import Testing

@testable import govuk_ios

@MainActor
@Suite("Coordinator Finish Lifecycle Tests")
struct CoordinatorFinishScenarioTests {

    final class TestCoordinator: BaseCoordinator {
        override func start(url: URL? = nil) {}
    }

    // MARK: - Scenario 1: Child calls finish()
    // Resolves the child's retain cycle, but destroys parent's delegate tracking.
    @Test("Child calling finish() breaks its own cycle but leaks parent due to lost delegate")
    func testChildFinishBreaksChildCycleButLeaksParent() {
        let nav = UINavigationController()
        let grandParent = TestCoordinator(navigationController: nav)

        weak var weakParent: TestCoordinator?
        weak var weakChild: TestCoordinator?

        do {
            let parent = TestCoordinator(navigationController: nav)
            weakParent = parent
            grandParent.start(parent)

            let parentVC = UIViewController()
            parent.push(parentVC, animated: false)

            let child = TestCoordinator(navigationController: nav)
            weakChild = child
            parent.start(child)

            // Child concludes its flow and invokes finish()
            child.finish()
        }

        // 1. Verify child was freed: Because child called finish(), parent released it,
        // so the child's deinit ran and dropped its strong parentCoordinator pointer.
        #expect(
            weakChild == nil,
            "Child should deallocate once finish() is called"
        )

        // 2. However, parent's delegate was never restored!
        #expect(
            nav.delegate === weakParent,
            "Bug: root.delegate was not restored to parent when child finished (currently nil or dead)"
        )

        // Simulate interactive back pop of parent's screen
        nav.setViewControllers([], animated: false)
        if let currentDelegate = nav.delegate {
            let dummyVC = UIViewController()
            currentDelegate.navigationController?(nav, didShow: dummyVC, animated: false)
        }

        // 3. Because nav.delegate was nil, parent never got didShow, never finished,
        // and remains trapped in grandparent's array forever.
        #expect(
            !grandParent.childCoordinators.contains(where: { $0 === weakParent }),
            "Bug: Parent coordinator leaked in grandparent because it never received the pop callback"
        )
        #expect(
            weakParent == nil,
            "Bug: Parent coordinator failed to deallocate after being popped"
        )
    }

    // MARK: - Scenario 2: Parent calls finish()
    // Grandparent releases parent, but parent and active children form an isolated retain island.
    @Test("Parent calling finish() while children exist creates an isolated retain island")
    func testParentFinishWithActiveChildrenLeaksBoth() {
        let nav = UINavigationController()
        let grandParent = TestCoordinator(navigationController: nav)

        weak var weakParent: TestCoordinator?
        weak var weakChild: TestCoordinator?

        do {
            let parent = TestCoordinator(navigationController: nav)
            weakParent = parent
            grandParent.start(parent)

            let child = TestCoordinator(navigationController: nav)
            weakChild = child
            parent.start(child)

            // Parent prematurely terminates (e.g., flow cancelled, user logged out, forced reset)
            parent.finish()
        }

        // Grandparent cleanly dropped parent from its array
        #expect(
            !grandParent.childCoordinators.contains(where: { $0 === weakParent }),
            "Grandparent properly pruned parent from childCoordinators"
        )

        // BUG: Neither parent nor child deallocates!
        // parent.finish() notified grandparent, but did not teardown its own childCoordinators.
        // parent holds child in childCoordinators (strong)
        // child holds parent in parentCoordinator (strong)
        // Both exist as an orphaned reference island in memory.
        #expect(
            weakParent == nil,
            "Bug: Parent leaked because active child holds strong parentCoordinator reference"
        )
        #expect(
            weakChild == nil,
            "Bug: Child leaked because parent retains it in childCoordinators"
        )
    }
}
