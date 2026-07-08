import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class InlineActionErrorViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        let viewModel = InlineActionErrorViewModel(
            title: "There's been a problem",
            markdownBody: "Try again later or [go to the website](https://gov.uk)",
            openURLAction: { _ in }
        )
        let view = InlineActionErrorView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view,
            statusBarStyle: .darkContent
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let viewModel = InlineActionErrorViewModel(
            title: "There's been a problem",
            markdownBody: "Try again later or [go to the website](https://gov.uk)",
            openURLAction: { _ in }
        )
        let view = InlineActionErrorView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view,
            statusBarStyle: .darkContent
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }
}
