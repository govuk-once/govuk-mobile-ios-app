import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class IconActionCardViewSnapshotTests: SnapshotTestCase {

    func test_withTitleAndDescription_light_rendersCorrectly() {
        let viewModel = IconActionCardViewModel(
            iconName: "plus.circle",
            title: "Add local authority",
            description: "Set your local authority to personalise content.",
            action: {}
        )
        let view = IconActionCardView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view,
            statusBarStyle: .darkContent
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_withTitleAndDescription_dark_rendersCorrectly() {
        let viewModel = IconActionCardViewModel(
            iconName: "plus.circle",
            title: "Add local authority",
            description: "Set your local authority to personalise content.",
            action: {}
        )
        let view = IconActionCardView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view,
            statusBarStyle: .darkContent
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    func test_withoutTitle_light_rendersCorrectly() {
        let viewModel = IconActionCardViewModel(
            iconName: "plus.circle",
            title: nil,
            description: "Set your local authority to personalise content.",
            action: {}
        )
        let view = IconActionCardView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view,
            statusBarStyle: .darkContent
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_withoutDescription_dark_rendersCorrectly() {
        let viewModel = IconActionCardViewModel(
            iconName: "plus.circle",
            title: "Add local authority",
            description: nil,
            action: {}
        )
        let view = IconActionCardView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view,
            statusBarStyle: .darkContent
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    func test_iconOnly_light_rendersCorrectly() {
        let viewModel = IconActionCardViewModel(
            iconName: "plus.circle",
            title: nil,
            description: nil,
            action: {}
        )
        let view = IconActionCardView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view,
            statusBarStyle: .darkContent
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }
}
