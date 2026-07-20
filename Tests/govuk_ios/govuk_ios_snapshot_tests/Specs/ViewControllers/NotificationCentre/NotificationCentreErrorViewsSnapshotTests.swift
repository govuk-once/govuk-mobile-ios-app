import Foundation
import XCTest
import SwiftUI

@testable import govuk_ios

@MainActor class NotificationCentreErrorViewsSnapshotTests: SnapshotTestCase {
    func test_error_loadInNavigationController_light_rendersCorrectly() {
        let view = NotificationCentreErrorView()
        VerifySnapshotInNavigationController(
            view: view,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_error_loadInNavigationController_dark_rendersCorrectly() {
        let view = NotificationCentreErrorView()
        VerifySnapshotInNavigationController(
            view: view,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_noInternet_loadInNavigationController_light_rendersCorrectly() {
        let view = NotificationCentreNoInternetView()
        VerifySnapshotInNavigationController(
            view: view,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_noInternet_loadInNavigationController_dark_rendersCorrectly() {
        let view = NotificationCentreNoInternetView()
        VerifySnapshotInNavigationController(
            view: view,
            mode: .dark,
            navBarHidden: true
        )
    }
}

