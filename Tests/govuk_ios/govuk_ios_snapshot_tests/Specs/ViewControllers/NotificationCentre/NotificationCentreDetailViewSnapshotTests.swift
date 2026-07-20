import Foundation
import XCTest
import SwiftUI

@testable import govuk_ios

@MainActor class NotificationCentreDetailViewSnapshotTests: SnapshotTestCase {
    private static let markdownTest = """
        *Test*
        
        https://google.com 
        # Heading1 
        ## Heading 2
        ### Heading 3
        #### Heading 4
        ##### Heading 5
        ###### Heading 6
        `code`
        
        ```
        code block
        second line of block
        ```
        
        ---
        > block quote
        * item 1
        * item 2
        1. numbered 1
        1. numbered 2
        """
    private let testNotificationContent = NotificationCentreDetailViewModel
        .NotificationDetailContent(
            title: "Test",
            body: markdownTest,
            sender: "Test sender",
            date: "17th July",
            id: "1"
        )

    func test_loaded_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreDetailLoadedView(notification: testNotificationContent, onLinkTapped: { _ in }, onConfirmDelete: { }, onCancelDelete: { }, showDeleteConfirmation: false),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loaded_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreDetailLoadedView(notification: testNotificationContent, onLinkTapped: { _ in }, onConfirmDelete: { }, onCancelDelete: { }, showDeleteConfirmation: false),
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loading_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreDetailLoadingView(),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loading_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: NotificationCentreDetailLoadingView(),
            mode: .dark,
            navBarHidden: true
        )
    }
}

