import Foundation
import XCTest
import SwiftUI

@testable import govuk_ios

@MainActor
class ServiceAccountLinkCardViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: view,
            mode: .light
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: view,
            mode: .dark
        )
    }

    var view: some View {
        let viewModel = ServiceAccountLinkCardViewModel(
            title: "Link your account",
            subtitle: "Test description of account linking",
            action: {}
        )
        return ServiceAccountLinkCardView(viewModel: viewModel)
    }
}
