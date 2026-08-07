import Foundation
import UIKit
import Testing

@testable import govuk_ios

@MainActor
@Suite
struct BaseNavigationControllerTests {

    @Test
    func childForStatusBar_returnsTopViewController() {
        let mockViewController = UIViewController()
        let sut = BaseNavigationController(rootViewController: mockViewController)

        let result = sut.childForStatusBarStyle
        #expect(result == mockViewController)
    }

}
