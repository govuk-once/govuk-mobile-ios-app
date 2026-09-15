import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
final class StatusRowViewSnapshotTests: SnapshotTestCase {
    /// Test when a link action is available (renders StatusLinkButton / StatusLinkContent)
    func testStatusRowView_WithLinkAction_light_rendersCorrectly() {
        let status = StatusInformation(
            title: "View service guidance",
            accessibilityLabel: "View service guidance accessibility label",
            linkAction: {
                // Dummy action for testing state
            },
        )

        let view = StatusRowView(status: status)
        let hostingViewController =  HostingViewController(
            rootView: view
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func testStatusRowView_WithLinkAction_dark_rendersCorrectly() {
        let status = StatusInformation(
            title: "View service guidance",
            accessibilityLabel: "View service guidance accessibility label",
            linkAction: {
                // Dummy action for testing state
            },
        )

        let view = StatusRowView(status: status)
        let hostingViewController =  HostingViewController(
            rootView: view
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }


    /// Test when there is no link action (renders plain Text)
    func testStatusRowView_PlainText_light_rendersCorrectly() {
        let status = StatusInformation(
            title: "View service guidance",
            accessibilityLabel: "View service guidance accessibility label",
            linkAction: nil)

        let view = StatusRowView(status: status)
        let hostingViewController =  HostingViewController(
            rootView: view
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func testStatusRowView_PlainText_dark_rendersCorrectly() {
        let status = StatusInformation(
            title: "View service guidance",
            accessibilityLabel: "View service guidance accessibility label",
            linkAction: nil)

        let view = StatusRowView(status: status)
        let hostingViewController =  HostingViewController(
            rootView: view
        )

        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }

}
