import Foundation
import UIKit
import Testing


@testable import govuk_ios

@Suite
@MainActor
struct UIViewController_ExtensionsTests {

    @Test
    @MainActor
    func viewWillReAppear_animated_callsTransitions() {
        let subject = MockBaseViewController(
            analyticsService: MockAnalyticsService()
        )
        subject.viewWillReAppear(
            isAppearing: true,
            animated: false
        )

        #expect(subject._receivedBeginAppearanceTransitionAnimated == false)
        #expect(subject._endAppearanceTransitionCalled)
    }

    @Test
    @MainActor
    func getTopController_returnsExpectedController() {
        let window = UIApplication.shared.window
        guard let window = window else { return }
        let controllerOne = UIViewController()
        let controllerTwo = UIViewController()
        window.rootViewController = controllerOne
        controllerOne.present(controllerTwo, animated: false)
        let top = controllerOne.topController
        #expect(top === controllerTwo)
    }
}
