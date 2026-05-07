import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class SARResultViewControllerSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchUserStateResult = .success(
            UserState(
                userId: "ID",
                notifications: UserNotificationsPreferences(
                    consentStatus: .accepted,
                    pushId: "pushId"
                )
            )
        )

        let viewModel = SARResultViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            sarResultAction: { } )
        let sarResultView = SARResultView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: sarResultView,
            statusBarStyle: .darkContent
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let mockUserService = MockUserService()
        mockUserService._stubbedFetchUserStateResult = .success(
            UserState(
                userId: "ID",
                notifications: UserNotificationsPreferences(
                    consentStatus: .accepted,
                    pushId: "pushId"
                )
            )
        )

        let viewModel = SARResultViewModel(
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            sarResultAction: { } )
        let sarResultView = SARResultView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: sarResultView,
            statusBarStyle: .darkContent
        )
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }
}
