import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DWPAccountWidgetSnapshotTests: SnapshotTestCase {
    func test_linkAccountCard_light_rendersCorrectly() {
        let viewModel = DWPWidgetViewModel(
            analyticsService: MockAnalyticsService()
        )
        viewModel.state = .unlinked(
            linkCard: linkCardViewModel
        )
        let view = DWPWidgetView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }
    
    func test_linkAccountCard_dark_rendersCorrectly() {
        let viewModel = DWPWidgetViewModel(
            analyticsService: MockAnalyticsService()
        )
        viewModel.state = .unlinked(
            linkCard: linkCardViewModel
        )
        let view = DWPWidgetView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        hostingViewController.view.backgroundColor = .govUK.fills.surfaceBackground
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
    
    private var linkCardViewModel: ServiceAccountLinkCardViewModel {
        let linkCardTitle = String.dvla.localized("dvlaAccountLinkCardTitle")
        return ServiceAccountLinkCardViewModel(
            title: linkCardTitle,
            subtitle: String.dvla.localized("dvlaAccountLinkCardSubtitle"),
            action: { }
        )
    }
}

