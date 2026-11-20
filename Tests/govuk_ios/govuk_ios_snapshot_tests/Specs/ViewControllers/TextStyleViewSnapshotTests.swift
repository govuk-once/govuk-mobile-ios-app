import Foundation
import XCTest
import SwiftUI
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class TextStyleViewSnapshotTests: SnapshotTestCase {

    func test_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(view: allStylesView, mode: .light)
    }

    func test_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(view: allStylesView, mode: .dark)
    }

    // MARK: - Helpers

    private var allStylesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderText(verbatim: "Header Text")
            SectionHeaderText(verbatim: "Section Header Text")
            SubsectionHeaderText(verbatim: "Subsection Header Text")
            BodyText(verbatim: "Body Text")
        }
        .padding()
    }
}
