import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class ChatWidgetViewControllerSnapshotTests: SnapshotTestCase {

    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark
        )
    }

    private func viewController() -> UIViewController {
        let chatBanner = ChatBanner(
            id: "1234",
            title: "title",
            body: "body",
            link: ChatBanner.Link(title: "link", url: URL(string: "www.test.com")!)
        )
        let viewModel = PromoBannerWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            chatBanner: chatBanner,
            urlOpener: MockURLOpener(),
            dismissAction: {}
        )
        let view = PromoBannerWidgetView(
            viewModel: viewModel
        )
        return HostingViewController(rootView: view)
    }
}
