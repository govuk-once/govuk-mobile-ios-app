import Foundation
import XCTest
import SwiftUI

@testable import govuk_ios

@MainActor class NotificationCentreViewSnapshotTests: SnapshotTestCase {
    private let testNotifications = NotificationCentreViewModel.NotificationGroups(
        recent: [
            NotificationCentreViewModel.NotificationListItem(
                title: "Test 1", date: "Today", isUnread: true, id: "1"
            )
        ],
        older: [
            NotificationCentreViewModel.NotificationListItem(
                title: "Test 2", date: "19th June", isUnread: false, id: "2"
            )
        ]
    )

    func test_loading_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreLoadingView(),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loading_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreLoadingView(),
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loaded_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreLoadedView(notifications: testNotifications, onNotificationTap: {_ in }),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loaded_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreLoadedView(notifications: testNotifications, onNotificationTap: {_ in }),
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_empty_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreEmptyView(),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_empty_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreEmptyView(),
            mode: .dark,
            navBarHidden: true
        )
    }
}

