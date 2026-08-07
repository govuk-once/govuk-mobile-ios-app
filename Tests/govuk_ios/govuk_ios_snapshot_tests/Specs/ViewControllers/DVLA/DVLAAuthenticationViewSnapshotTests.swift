import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class DVLAAuthenticationViewSnapshotTests: SnapshotTestCase {
    func test_loadingView_light_rendersCorrectly() {
        let viewModel = DVLAAuthenticationViewModel(
            authenticationService: MockAuthenticationService(),
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: { }
        )
        let view = DVLAAuthenticationView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_loadingView_dark_rendersCorrectly() {
        let viewModel = DVLAAuthenticationViewModel(
            authenticationService: MockAuthenticationService(),
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: { }
        )
        let view = DVLAAuthenticationView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}


