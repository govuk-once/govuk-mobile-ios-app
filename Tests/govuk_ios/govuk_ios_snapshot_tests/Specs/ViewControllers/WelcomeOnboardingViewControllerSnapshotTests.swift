import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

class WelcomeOnboardingViewControllerSnapshotTests: SnapshotTestCase {
    let viewControllerBuilder = ViewControllerBuilder()

    func test_loadInNavigationController_light_rendersCorrectly() {
        let viewModel = WelcomeOnboardingViewModel(
            completeAction: { },
            openURLAction: { _ in },
            termsURL: Constants.API.govukBaseUrl
        )
        let welcomeOnboardingViewController = viewControllerBuilder.welcomeOnboarding(
            viewModel: viewModel
        )

        VerifySnapshotInNavigationController(
            viewController: welcomeOnboardingViewController,
            mode: .light
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let viewModel = WelcomeOnboardingViewModel(
            completeAction: { },
            openURLAction: { _ in },
            termsURL: Constants.API.govukBaseUrl
        )
        let welcomeOnboardingViewController = viewControllerBuilder.welcomeOnboarding(
            viewModel: viewModel
        )

        VerifySnapshotInNavigationController(
            viewController: welcomeOnboardingViewController,
            mode: .dark
        )
    }
}
