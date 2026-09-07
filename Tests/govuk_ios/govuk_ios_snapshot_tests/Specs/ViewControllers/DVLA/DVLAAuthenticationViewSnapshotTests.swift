import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class DVLAAuthenticationViewSnapshotTests: SnapshotTestCase {
    func test_loadingView_light_rendersCorrectly() {
        let authenticationService = MockAuthenticationService()
        authenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(token: "test_token")
        )
        let viewModel = DVLAAuthenticationViewModel(
            authenticationService: authenticationService,
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: { }
        )
        let view = DVLAAuthenticationView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_loadingView_dark_rendersCorrectly() {
        let authenticationService = MockAuthenticationService()
        authenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(token: "test_token")
        )
        let viewModel = DVLAAuthenticationViewModel(
            authenticationService: authenticationService,
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: { }
        )
        let view = DVLAAuthenticationView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}

