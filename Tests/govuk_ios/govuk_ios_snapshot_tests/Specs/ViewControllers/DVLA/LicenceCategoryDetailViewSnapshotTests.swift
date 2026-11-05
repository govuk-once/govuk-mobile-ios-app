import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class LicenceCategoryDetailViewSnapshotTests: SnapshotTestCase {
    func test_light_rendersCorrectly() {
        let viewModel = LicenceCategoryDetailViewModel(
            entitlement: .arrange,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let view = LicenceCategoryDetailView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_dark_rendersCorrectly() {
        let viewModel = LicenceCategoryDetailViewModel(
            entitlement: .arrange,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let view = LicenceCategoryDetailView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_noRestrictions_light_rendersCorrectly() {
        let entitlement = Entitlement.arrange(restrictions: [])
        let viewModel = LicenceCategoryDetailViewModel(
            entitlement: entitlement,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let view = LicenceCategoryDetailView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_noRestrictions_dark_rendersCorrectly() {
        let entitlement = Entitlement.arrange(restrictions: [])
        let viewModel = LicenceCategoryDetailViewModel(
            entitlement: entitlement,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let view = LicenceCategoryDetailView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_categoryWithoutImage_light_rendersCorrectly() {
        let entitlement = Entitlement.arrange(categoryCode: "l")
        let viewModel = LicenceCategoryDetailViewModel(
            entitlement: entitlement,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let view = LicenceCategoryDetailView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_categoryWithoutImage_dark_rendersCorrectly() {
        let entitlement = Entitlement.arrange(categoryCode: "l")
        let viewModel = LicenceCategoryDetailViewModel(
            entitlement: entitlement,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let view = LicenceCategoryDetailView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
