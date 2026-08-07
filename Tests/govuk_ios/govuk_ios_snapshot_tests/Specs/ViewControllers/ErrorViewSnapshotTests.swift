import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class ErrorViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        let viewModel = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "There's a problem",
            subtitle: "GOV.UK Chat is not working.",
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: "",
            primaryAction: {},
            trackingName: ""
        )
        let view = ErrorView(viewModel: viewModel)
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
        let viewModel = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "There's a problem",
            subtitle: "GOV.UK Chat is not working.",
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: "",
            primaryAction: {},
            trackingName: ""
        )
        let view = ErrorView(viewModel: viewModel)
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

    func test_loadWithPrimaryButtonInNavigationController_light_rendersCorrectly() {
        let viewModel = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "There's a problem",
            subtitle: "GOV.UK Chat is not working.",
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: "Try again",
            primaryAction: {},
            trackingName: ""
        )
        let view = ErrorView(viewModel: viewModel)
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

    func test_loadWithPrimaryButtonInNavigationController_dark_rendersCorrectly() {
        let viewModel = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "There's a problem",
            subtitle: "GOV.UK Chat is not working.",
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: "Try again",
            primaryAction: {},
            trackingName: ""
        )
        let view = ErrorView(viewModel: viewModel)
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

    func test_loadWithSecondaryButtonInNavigationController_light_rendersCorrectly() {
        let viewModel = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "There's a problem",
            subtitle: "GOV.UK Chat is not working.",
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: "Try again",
            primaryAction: {},
            secondaryButtonTitle: "Dismiss",
            secondaryAction: {},
            trackingName: ""
        )
        let view = ErrorView(viewModel: viewModel)
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

    func test_loadWithSecondaryButtonInNavigationController_dark_rendersCorrectly() {
        let viewModel = ErrorViewModel(
            analyticsService: MockAnalyticsService(),
            title: "There's a problem",
            subtitle: "GOV.UK Chat is not working.",
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: "Try again",
            primaryAction: {},
            secondaryButtonTitle: "Dismiss",
            secondaryAction: {},
            trackingName: ""
        )
        let view = ErrorView(viewModel: viewModel)
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
