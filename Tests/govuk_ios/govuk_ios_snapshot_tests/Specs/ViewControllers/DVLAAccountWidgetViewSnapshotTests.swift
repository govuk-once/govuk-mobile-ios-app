import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountWidgetViewSnapshotTests: SnapshotTestCase {
    func test_linkAccountCard_light_rendersCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeUnlinked)

        let viewModel = DVLAAccountWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            dvlaService: MockDVLAService(),
            actions: .empty
        )
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.viewDidAppear()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_linkAccountCard_dark_rendersCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeUnlinked)

        let viewModel = DVLAAccountWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            dvlaService: MockDVLAService(),
            actions: .empty
        )
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.viewDidAppear()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

    func test_actionCards_light_rendersCorrectly() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchAccountLinkStatusResult = .success(.arrangeLinked)

        let viewModel = DVLAAccountWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            dvlaService: MockDVLAService(),
            actions: .empty
        )
        let view = DVLAAccountWidgetView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.viewDidAppear()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }
}

extension DVLAAccountWidgetViewModel.Actions {
    static var empty: DVLAAccountWidgetViewModel.Actions {
        .init(
            linkAction: {},
            unlinkAction: {},
            viewLicenceAction: {},
            viewDriverSummaryAction: {},
            viewCustomerSummaryAction: {}
        )
    }
}
