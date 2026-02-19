import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

final class TermsAndConditionsViewControllerSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        let termsViewController = ViewControllerBuilder()
            .termsAndConditions(
                termsAndConditionsService: MockTermsAndConditionsService(),
                completionAction: { },
                alertDismissAction: { },
                openURLAction: { _ in }
            )

        VerifySnapshotInNavigationController(
            viewController: termsViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let termsViewController = ViewControllerBuilder()
            .termsAndConditions(
                termsAndConditionsService: MockTermsAndConditionsService(),
                completionAction: { },
                alertDismissAction: { },
                openURLAction: { _ in }
            )

        VerifySnapshotInNavigationController(
            viewController: termsViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }
}
