import Foundation
import Testing
import Combine
import CoreData
@testable import GovKit

@testable import govuk_ios
struct RecentActivtyHomepageWidgetViewModelTests {
    @Test
    func recentActivities_count_isLessOrEqualToThree() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let mockActivityService = MockActivityService(context: coreData.viewContext)

        let sut = RecentActivityHomepageWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            activityService: mockActivityService,
            seeAllAction: {},
            openURLAction: { _ in }
        )

        for _ in 0..<4 {
            _ = ActivityItem.arrange(context: coreData.viewContext)
        }
        try coreData.viewContext.save()
        try mockActivityService.activitiesFetchResultsController.performFetch()
        sut.controllerDidChangeContent(mockActivityService.activitiesFetchResultsController)

        #expect(!sut.sections.isEmpty)
        if let firstSection = sut.sections.first {
            #expect(firstSection.rows.count == 3)
        }
    }
}

