import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class ExpiryProgressViewSnapshotTests: SnapshotTestCase {
    func test_empty_light_rendersCorrectly() {
        let viewModel = ExpiryProgressViewModel(
            progress: 0.0,
            daysLeft: 0
        )
        let view = ExpiryProgressView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_empty_dark_rendersCorrectly() {
        let viewModel = ExpiryProgressViewModel(
            progress: 0.0,
            daysLeft: 0
        )
        let view = ExpiryProgressView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_full_light_rendersCorrectly() {
        let viewModel = ExpiryProgressViewModel(
            progress: 1.0,
            daysLeft: 56
        )
        let view = ExpiryProgressView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_full_dark_rendersCorrectly() {
        let viewModel = ExpiryProgressViewModel(
            progress: 1.0,
            daysLeft: 56
        )
        let view = ExpiryProgressView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_halfFull_light_rendersCorrectly() {
        let viewModel = ExpiryProgressViewModel(
            progress: 0.5,
            daysLeft: 28
        )
        let view = ExpiryProgressView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_halfFull_dark_rendersCorrectly() {
        let viewModel = ExpiryProgressViewModel(
            progress: 0.5,
            daysLeft: 28
        )
        let view = ExpiryProgressView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
