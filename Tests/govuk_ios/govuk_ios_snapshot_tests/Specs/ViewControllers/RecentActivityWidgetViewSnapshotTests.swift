import Foundation
import XCTest
import UIKit
import GovKit
import CoreData
import SwiftUI

@testable import govuk_ios

@MainActor
final class RecentActivityWidgetViewSnapshotTests: SnapshotTestCase {
    var coreData: CoreDataRepository!

    override func setUp() async throws {
        try await super.setUp()
        self.coreData = await CoreDataRepository.arrangeAndLoad

    }


    func test_loadInNavigationController_activities_light_renderCorrectly() async throws {
        VerifySnapshotInNavigationController(
            viewController: viewController(true),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_activities_dark_renderCorrectly() async throws {
        VerifySnapshotInNavigationController(
            viewController: viewController(true),
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_emptyActivities_light_rendersCorrectly() async throws {
        VerifySnapshotInNavigationController(
            viewController: viewController(false),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_emptyActivities_dark_rendersCorrectly() async throws {
        VerifySnapshotInNavigationController(
            viewController: viewController(false),
            mode: .dark,
            navBarHidden: true
        )
    }

    private func viewController(_ loadActivities: Bool) -> UIViewController {
        if (loadActivities) {
            _ = ActivityItem.arrange(
                title: "Test 1",
                date: .arrange("01/10/2023"),
                context: coreData.viewContext
            )
            _ = ActivityItem.arrange(
                title: "Test 2",
                date: .arrange("02/02/2024"),
                context: coreData.viewContext
            )
            _ = ActivityItem.arrange(
                title: "Test 3",
                date: .arrange("10/04/2024"),
                context: coreData.viewContext
            )
        }

        let viewModel = RecentActivityHomepageWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            activityService: MockActivityService(context: coreData.viewContext),
            seeAllAction: {},
            openURLAction: { _ in }
        )
        let view = RecentActivityWidgetView(viewModel: viewModel)
        return UIHostingController(rootView: view)
    }
}

