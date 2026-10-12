import Foundation
import XCTest

@testable import govuk_ios

@MainActor
final class TravelLoadingViewSnapshotTests: SnapshotTestCase {
    func test_travelLoadingView_light_rendersCorrectly() {
        let view = TravelLoadingView()

        VerifySnapshotInNavigationController(
            view: view,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_travelLoadingView_dark_rendersCorrectly() {
        let view = TravelLoadingView()

        VerifySnapshotInNavigationController(
            view: view,
            mode: .dark,
            navBarHidden: true
        )
    }
}
