import Foundation

import Testing
import SwiftUI
import GovKit

@testable import govuk_ios

@Suite
@MainActor
struct RecentActivityListViewControllerTests {
        
    func test_isLandscapeDuoFoldedOpen_withNoWindow_returnsFalse() async {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockActivityService = MockActivityService(
            context: coreData.viewContext
        )
        let viewController = RecentActivityListViewController(
            viewModel: .init(
                activityService: mockActivityService,
                analyticsService: MockAnalyticsService(),
                selectedAction: { _ in }
            )
        )
        #expect(!viewController.isLandscapeDuoFoldedOpen)
    }
}
