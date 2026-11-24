import UIKit
import SwiftUI

import iOSSnapshotTestCase
import FactoryKit
import Lottie

@testable import govuk_ios

@MainActor
class SnapshotTestCase: FBSnapshotTestCase {
    
    //To allow for slight liquid glass snapshot shading differences
    nonisolated static let renderingPerPixelTolerance: CGFloat = 0.025

    override func setUp() {
        super.setUp()
        Container.shared.lottieConfiguration.register {
            LottieConfiguration(renderingEngine: .mainThread)
        }
//       self.recordMode = true
    }

    func VerifySnapshotInNavigationController(view: some View,
                                              mode: UIUserInterfaceStyle,
                                              navBarHidden: Bool = false,
                                              file: StaticString = #file,
                                              line: UInt = #line) {
        let wrappedView = UIHostingController(rootView: view)
        VerifySnapshotInNavigationController(
            viewController: wrappedView,
            mode: mode,
            navBarHidden: navBarHidden,
            file: file,
            line: line
        )
    }

    func VerifySnapshotInNavigationController(viewController: UIViewController,
                                              mode: UIUserInterfaceStyle,
                                              navBarHidden: Bool = false,
                                              prefersLargeTitles: Bool = false,
                                              file: StaticString = #file,
                                              line: UInt = #line) {
        let navigationController = makeNavigationController(
            rootViewController: viewController,
            mode: mode,
            navBarHidden: navBarHidden,
            prefersLargeTitles: prefersLargeTitles
        )
        VerifySnapshotInWindow(
            navigationController,
            overallTolerance: 0.001,
            file: file,
            line: line
        )
    }

    func VerifySnapshotInNavigationController(viewController: UIViewController,
                                              mode: UIUserInterfaceStyle,
                                              navBarHidden: Bool = false,
                                              prefersLargeTitles: Bool = false,
                                              timeout: Duration = .seconds(2),
                                              file: StaticString = #file,
                                              line: UInt = #line,
                                              waitUntil condition: () -> Bool) async {
        let navigationController = makeNavigationController(
            rootViewController: viewController,
            mode: mode,
            navBarHidden: navBarHidden,
            prefersLargeTitles: prefersLargeTitles
        )
        wrapInWindow(navigationController)

        guard await waitFor(condition, timeout: timeout) else {
            XCTFail("Snapshot state was not reached before timeout", file: file, line: line)
            return
        }

        verifyRenderedSnapshot(
            of: navigationController,
            perPixelTolerance: Self.renderingPerPixelTolerance,
            overallTolerance: 0.001,
            file: file,
            line: line
        )
    }

    func VerifySnapshotWindowWithDelay(view: some View,
                                       mode: UIUserInterfaceStyle,
                                       overallTolerance: CGFloat = 0.001,
                                       file: StaticString = #file,
                                       line: UInt = #line,
                                       delay: Double = 0.3) {
        let wrappedViewController = UIHostingController(rootView: view)
        wrappedViewController.overrideUserInterfaceStyle = mode
        let window = UIApplication.shared.window
        guard let window = window else { return }
        window.rootViewController = wrappedViewController

        let expectation = XCTestExpectation(description: "Snapshot capture")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.VerifySnapshot(
                window,
                overallTolerance: overallTolerance,
                file: file,
                line: line
            )
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: delay * 2)
    }

    func VerifySnapshotInWindow(_ viewController: UIViewController,
                                perPixelTolerance: CGFloat = SnapshotTestCase.renderingPerPixelTolerance,
                                overallTolerance: CGFloat = 0,
                                file: StaticString = #file, 
                                line: UInt = #line) {
        wrapInWindow(viewController)
        verifyRenderedSnapshot(
            of: viewController,
            perPixelTolerance: perPixelTolerance,
            overallTolerance: overallTolerance,
            file: file,
            line: line
        )
    }

    func VerifySnapshot(_ viewController: UIViewController,
                        file: StaticString = #file,
                        line: UInt = #line) {
        FBSnapshotVerifyViewController(
            viewController,
            file: file,
            line: line
        )
    }

    func VerifySnapshot(_ view: UIView, 
                        overallTolerance: CGFloat = 0,
                        file: StaticString = #file,
                        line: UInt = #line) {
        view.sizeToFit()
        FBSnapshotVerifyView(
            view,
            overallTolerance: overallTolerance,
            file: file,
            line: line
        )
    }

    func VerifySnapshot(_ layer: CALayer, 
                        file: StaticString = #file,
                        line: UInt = #line) {
        FBSnapshotVerifyLayer(
            layer,
            file: file,
            line: line
        )
    }

    func RecordSnapshotInNavigationController(view: some View,
                                              mode: UIUserInterfaceStyle,
                                              navBarHidden: Bool = false,
                                              prefersLargeTitles: Bool = false,
                                              file: StaticString = #file,
                                              line: UInt = #line) {
        let wrappedView = UIHostingController(rootView: view)
        RecordSnapshotInNavigationController(
            viewController: wrappedView,
            mode: mode,
            navBarHidden: navBarHidden,
            prefersLargeTitles: prefersLargeTitles,
            file: file,
            line: line
        )
    }

    func RecordSnapshotInNavigationController(viewController: UIViewController,
                                              mode: UIUserInterfaceStyle,
                                              navBarHidden: Bool = false,
                                              prefersLargeTitles: Bool = false,
                                              file: StaticString = #file,
                                              line: UInt = #line) {
        let navigationController = makeNavigationController(
            rootViewController: viewController,
            mode: mode,
            navBarHidden: navBarHidden,
            prefersLargeTitles: prefersLargeTitles
        )
        RecordSnapshotInWindow(
            navigationController,
            file: file,
            line: line
        )
    }

    func RecordSnapshotInWindow(_ viewController: UIViewController,
                                file: StaticString = #file,
                                line: UInt = #line) {
        let initialRecordMode = recordMode
        recordMode = true
        wrapInWindow(viewController)
        verifyRenderedSnapshot(
            of: viewController,
            perPixelTolerance: 0,
            overallTolerance: 0,
            file: file,
            line: line
        )
        recordMode = initialRecordMode
    }

    func RecordSnapshot(_ viewController: UIViewController, 
                        file: StaticString = #file,
                        line: UInt = #line) {
        let initialRecordMode = recordMode
        recordMode = true
        FBSnapshotVerifyViewController(
            viewController,
            file: file,
            line: line
        )
        recordMode = initialRecordMode
    }

    func RecordSnapshot(_ view: UIView, 
                        file: StaticString = #file,
                        line: UInt = #line) {
        let initialRecordMode = recordMode
        recordMode = true
        FBSnapshotVerifyView(
            view,
            file: file,
            line: line
        )
        recordMode = initialRecordMode
    }

    func RecordSnapshot(_ layer: CALayer, 
                        file: StaticString = #file,
                        line: UInt = #line) {
        let initialRecordMode = recordMode
        recordMode = true
        FBSnapshotVerifyLayer(
            layer,
            file: file,
            line: line
        )
        recordMode = initialRecordMode
    }

    func wrapInWindow(_ viewController: UIViewController) {
        let window = UIApplication.shared.window
        guard let window = window else { return }
        window.rootViewController = viewController
    }

    private func makeNavigationController(rootViewController: UIViewController,
                                          mode: UIUserInterfaceStyle,
                                          navBarHidden: Bool,
                                          prefersLargeTitles: Bool) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.setNavigationBarHidden(navBarHidden, animated: false)
        navigationController.overrideUserInterfaceStyle = mode
        navigationController.navigationBar.prefersLargeTitles = prefersLargeTitles
        return navigationController
    }

    private func verifyRenderedSnapshot(of viewController: UIViewController,
                                        perPixelTolerance: CGFloat,
                                        overallTolerance: CGFloat,
                                        file: StaticString,
                                        line: UInt) {
        viewController.view.bounds = UIScreen.main.bounds
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
        let view: UIView = viewController.view
        view.layoutIfNeeded()
        removeAnimations(from: view.layer)

        let format = UIGraphicsImageRendererFormat()
        format.preferredRange = .standard
        let image = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        FBSnapshotVerifyView(
            UIImageView(image: image),
            perPixelTolerance: perPixelTolerance,
            overallTolerance: overallTolerance,
            file: file,
            line: line
        )
    }

    private func waitFor(_ condition: () -> Bool,
                         timeout: Duration,
                         pollInterval: Duration = .milliseconds(10)) async -> Bool {
        let deadline = ContinuousClock.now + timeout
        while !condition() {
            guard ContinuousClock.now < deadline, !Task.isCancelled else {
                return false
            }
            try? await Task.sleep(for: pollInterval)
        }
        return true
    }

    private func removeAnimations(from layer: CALayer) {
        layer.removeAllAnimations()
        layer.sublayers?.forEach { removeAnimations(from: $0) }
    }
}
