import Foundation
import UIKit

/// An abstract base coordinator that manages UIKit navigation flows, child coordinator lifecycles, and view hierarchy transitions.
///
/// `BaseCoordinator` provides a foundational implementation of the Coordinator pattern built around a
/// `UINavigationController`. It is responsible for decoupling view controllers from navigation logic, maintaining
/// a parent-child coordinator hierarchy, and tracking view controllers to automate lifecycle cleanup.
///
/// ### Subclassing Guide
/// To implement a concrete navigation flow:
/// 1. **Override ``start(url:)``:** Construct initial view controllers, configure their dependencies/delegates,
///    and place them on the navigation stack using ``push(_:animated:)`` or ``set(_:animated:)``.
///    Do **not** call `super.start(url:)`, as the base implementation triggers an assertion failure.
/// 2. **Add Route Methods:** Define custom presentation methods (e.g., `showDetail()`) on the subclass
///    to push subsequent screens or spawn child coordinators.
/// 3. **Always use helper methods:** Call ``push(_:animated:)`` or ``set(_:animated:)`` rather than
///    invoking `root.pushViewController(...)` directly.
///
/// ### Lifecycle & Automatic Teardown
/// `BaseCoordinator` tracks every view controller added through ``push(_:animated:)`` and ``set(_:animated:)``
/// in an internal weak set.
/// - **Interactive Pops & Back Button:** When the user navigates back and none of the coordinator's tracked
///   view controllers remain on the navigation stack, ``finish()`` is invoked automatically.
/// - **Interactive Sheet Dismissals:** If presented modally as a sheet on iOS 13+, interactive pull-to-dismiss
///   gestures trigger ``finish()`` via `UIAdaptivePresentationControllerDelegate`.
/// - **Teardown:** Calling ``finish()`` informs the parent coordinator via ``childDidFinish(_:)`` to release
///   its strong reference from `childCoordinators`, breaking retention cycles cleanly.
///
/// ### Important Gotchas
/// - **Direct Navigation Calls:** Bypassing ``push(_:animated:)`` breaks back-button detection and will prevent
///   automatic coordinator deallocation.
/// - **Delegate Hijacking:** Starting a child coordinator assigns `coordinator.root.delegate = coordinator`.
///   If a parent and child share the same `UINavigationController` instance, the child will take over delegate
///   responsibilities, which stops the parent from receiving navigation events until the child finishes.
class BaseCoordinator: NSObject,
                       UINavigationControllerDelegate,
                       UIAdaptivePresentationControllerDelegate {
    private(set) var childCoordinators: [BaseCoordinator] = []
    private var parentCoordinator: BaseCoordinator?
    private var stackedViewControllers: NSHashTable<UIViewController> = .weakObjects()
    private(set) var root: UINavigationController

    /// Initializes a new coordinator instance with an associated navigation controller.
    ///
    /// Sets this coordinator as the presentation controller delegate on `navigationController`
    /// to listen for modal dismissal events.
    ///
    /// - Parameter navigationController: The navigation controller used to host and present this coordinator's views.
    init(navigationController: UINavigationController) {
        self.root = navigationController
        super.init()
        navigationController.presentationController?.delegate = self
    }

    /// Initiates the coordinator flow with default parameters.
    ///
    /// This final entry point forwards execution to ``start(url:)`` with a `nil` URL.
    /// Call this method to start the coordinator without deep-link or universal link context.
    final func start() {
        start(url: nil)
    }

    /// The primary configuration and presentation hook for the coordinator.
    ///
    /// Subclasses must override this method to construct initial view controllers,
    /// wire up dependencies, and place controllers onto ``root``.
    ///
    /// - Parameter url: An optional deep link or universal link URL used to route
    ///   directly to a nested destination within this flow.
    /// - Note: Subclasses must not call `super.start(url:)` because the base implementation
    ///   triggers an `assertionFailure`.
    func start(url: URL?) {
        assertionFailure("This needs overriding")
    }

    /// Starts a child coordinator without a routing URL and retains it in the coordinator hierarchy.
    ///
    /// A convenience overload that forwards to ``start(_:url:)`` with `url` set to `nil`.
    ///
    /// - Parameter coordinator: The child coordinator to attach and launch.
    func start(_ coordinator: BaseCoordinator) {
        start(coordinator, url: nil)
    }

    /// Starts a child coordinator and retains it in the coordinator hierarchy.
    ///
    /// Use this method when the child coordinator should operate within the existing navigation stack
    /// without presenting a new modal context. The child coordinator takes over navigation delegate
    /// responsibilities, establishes a parent-child relationship for lifecycle tracking, and initiates its flow.
    ///
    /// - Parameters:
    ///   - coordinator: The child coordinator to attach and launch.
    ///   - url: An optional deep link or universal link URL to route to a specific des
    func start(_ coordinator: BaseCoordinator,
               url: URL?) {
        childCoordinators.append(coordinator)
        coordinator.root.delegate = coordinator
        coordinator.parentCoordinator = self
        coordinator.start(url: url)
    }

    /// Starts a child coordinator and presents its navigation stack modally.
    ///
    /// Use this method for isolated, self-contained flows (such as sheets, onboarding, or forms)
    /// where the child coordinator manages its own distinct `UINavigationController`.
    /// This attaches the coordinator as a child, initiates its flow, and modally presents
    /// `coordinator.root` on top of this coordinator's `root`.
    ///
    /// - Parameters:
    ///   - coordinator: The child coordinator managing the modally presented navigation flow.
    ///   - animated: Pass `true` to animate the presentation transition; otherwise, `false`. Defaults to `true`.
    func present(_ coordinator: BaseCoordinator,
                 animated: Bool = true) {
        start(coordinator)
        root.present(coordinator.root, animated: animated)
    }

    /// Pushes a view controller onto the navigation stack and registers it for lifecycle tracking.
    ///
    /// Use this method instead of calling `root.pushViewController(_:animated:)` directly.
    /// In addition to performing the navigation push, it registers the view controller in an internal
    /// weak set (`stackedViewControllers`) so the coordinator can automatically detect when the controller
    /// has been popped and trigger ``finish()``.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to push onto the navigation stack.
    ///   - animated: Pass `true` to animate the transition; otherwise, `false`. Defaults to `true`.
    func push(_ viewController: UIViewController,
              animated: Bool = true) {
        stackedViewControllers.add(viewController)
        root.pushViewController(viewController, animated: animated)
    }

    /// Replaces the current navigation stack with a single root view controller.
    ///
    /// A convenience overload that forwards to ``set(_:animated:)`` with a single-element array.
    /// Typically used in ``start(url:)`` when launching a fresh or modally presented flow to establish
    /// the base screen without a push transition.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to establish as the sole content of the navigation stack.
    ///   - animated: Pass `true` to animate the transition; otherwise, `false`. Defaults to `true`.
    func set(_ viewController: UIViewController,
             animated: Bool = true) {
        set([viewController], animated: animated)
    }

    /// Replaces the navigation stack with the specified view controllers and registers them for lifecycle tracking.
    ///
    /// Clears the existing stack, updates `root.viewControllers`, and tracks each supplied view controller
    /// in the internal weak set (`stackedViewControllers`) to monitor when the entire flow has been popped.
    ///
    /// - Parameters:
    ///   - viewControllers: The array of view controllers to set as the navigation stack. The last item
    ///     becomes the top, visible view controller.
    ///   - animated: Pass `true` to animate the transition; otherwise, `false`. Defaults to `true`.
    func set(_ viewControllers: [UIViewController],
             animated: Bool = true) {
        viewControllers.forEach {
            stackedViewControllers.add($0)
        }
        root.setViewControllers(viewControllers, animated: animated)
    }

    /// Tells the delegate that the navigation controller showed a view controller.
    ///
    /// Monitors the navigation stack to determine whether all tracked view controllers
    /// registered via ``push(_:animated:)`` or ``set(_:animated:)`` have been popped off.
    /// If no tracked view controllers remain in the navigation hierarchy, it automatically calls ``finish()``.
    ///
    /// - Parameters:
    ///   - navigationController: The navigation controller that displayed the view controller.
    ///   - viewController: The view controller that was shown.
    ///   - animated: `true` if the transition was animated; otherwise, `false`.
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        guard stackedViewControllers.allObjects.isEmpty ||
              stackedViewControllers.allObjects.filter({ $0.navigationController != nil }).isEmpty
        else { return }
        finish()
    }

    /// Tells the delegate that the presented view controller was dismissed interactively.
    ///
    /// Intercepts pull-to-dismiss gestures on iOS modal sheet presentations to notify
    /// the coordinator lifecycle that the presentation has ended by invoking ``finish()``.
    ///
    /// - Parameter presentationController: The presentation controller that was dismissed.
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        finish()
    }

    /// Concludes this coordinator's lifecycle and notifies its parent.
    ///
    /// Subclasses can call this method when the flow reaches a natural terminal state
    /// (e.g., checkout complete, logout, cancellation), prompting the parent coordinator
    /// to release its reference via ``childDidFinish(_:)``.
    func finish() {
        parentCoordinator?.childDidFinish(self)
    }

    /// Removes a completed child coordinator from memory.
    ///
    /// Called by a terminating child coordinator's ``finish()`` invocation to prune the child
    /// from `childCoordinators`, breaking retention and tearing down the child hierarchy.
    ///
    /// - Parameter child: The child coordinator that has completed its task.
    func childDidFinish(_ child: BaseCoordinator) {
        guard let index = childCoordinators.firstIndex(of: child)
        else { return }
        childCoordinators.remove(at: index)
    }

    /// Reverses the presentation or navigation step for this coordinator's root.
    ///
    /// If `root` has an active `presentingViewController`, it dismisses the modal presentation.
    /// Otherwise, it pops the top view controller off `root`'s navigation stack.
    ///
    /// - Parameter animated: Pass `true` to animate the transition; otherwise, `false`.
    func dismiss(animated: Bool) {
        if root.presentingViewController != nil {
            root.dismiss(animated: animated)
        } else {
            root.popViewController(animated: animated)
        }
    }
}
