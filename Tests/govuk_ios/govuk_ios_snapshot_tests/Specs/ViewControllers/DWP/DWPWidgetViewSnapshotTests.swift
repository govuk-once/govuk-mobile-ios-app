import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class BenefitsWidgetViewSnapshotTests: SnapshotTestCase {
    func test_linkAccountCard_light_rendersCorrectly() {
        let viewModel = BenefitsWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            state: .unlinked(
                linkCard: linkCardViewModel
            ),
            linkAction: {}
        )
        let view = BenefitsWidgetView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_linkAccountCard_dark_rendersCorrectly() {
        let viewModel = BenefitsWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            state: .unlinked(
                linkCard: linkCardViewModel
            ),
            linkAction: {}
        )
        let view = BenefitsWidgetView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
    
    private var linkCardViewModel: ServiceAccountLinkCardViewModel {
        let linkCardTitle = String.dwp.localized("dwpAccountLinkCardTitle")
        return ServiceAccountLinkCardViewModel(
            title: linkCardTitle,
            subtitle: String.dwp.localized("dwpAccountLinkCardSubtitle"),
            action: { /* no-op */ }
        )
    }
}
