import Foundation
import UIKit

class BaseCoordinator: NSObject,
                       UINavigationControllerDelegate,
                       UIAdaptivePresentationControllerDelegate {
    private(set) var childCoordinators: [BaseCoordinator] = []
    private var parentCoordinator: BaseCoordinator?
    private var stackedViewControllers: NSHashTable<UIViewController> = .weakObjects()
    private(set) var root: UINavigationController

    init(navigationController: UINavigationController) {
        self.root = navigationController
        super.init()
        navigationController.presentationController?.delegate = self
    }

    final func start() {
        start(url: nil)
    }

    func start(url: URL?) {
        assertionFailure("This needs overriding")
    }

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

    func push(_ viewController: UIViewController,
              animated: Bool = true) {
        stackedViewControllers.add(viewController)
        root.pushViewController(viewController, animated: animated)
    }

    func set(_ viewController: UIViewController,
             animated: Bool = true) {
        set([viewController], animated: animated)
    }

    func set(_ viewControllers: [UIViewController],
             animated: Bool = true) {
        viewControllers.forEach {
            stackedViewControllers.add($0)
        }
        root.setViewControllers(viewControllers, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        guard stackedViewControllers.allObjects.isEmpty ||
              stackedViewControllers.allObjects.filter({ $0.navigationController != nil }).isEmpty
        else { return }
        finish()
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        finish()
    }

    func finish() {
        parentCoordinator?.childDidFinish(self)
    }

    func childDidFinish(_ child: BaseCoordinator) {
        guard let index = childCoordinators.firstIndex(of: child)
        else { return }
        childCoordinators.remove(at: index)
    }

    func dismiss(animated: Bool) {
        if root.presentingViewController != nil {
            root.dismiss(animated: animated)
        } else {
            root.popViewController(animated: animated)
        }
    }
}
