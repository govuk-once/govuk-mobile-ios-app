//import Foundation
//import Testing
//import Combine
//import CoreData
//@testable import GovKit
//
//@testable import govuk_ios
//struct RecentActivtyHomepageWidgetViewModelTests {
//
//    @Test
//    func recentActivities_count_isLessOrEqualToThree() async throws {
//        var cancellables = Set<AnyCancellable>()
//        let result = await withCheckedContinuation { continuation in
//            let mockActivityService = MockActivityService()
//            let sut = RecentActivityHomepageWidgetViewModel(
//                analyticsService: MockAnalyticsService(),
//                activityService: mockActivityService,
//                seeAllAction: {},
//                openURLAction: { _ in }
//            )
//         //   let coreData = await CoreDataRepository.arrangeAndLoad
//
//            _ = ActivityItem.arrange(
//                context: mockActivityService.
//            )
//
//            _ = ActivityItem.arrange(
//                context: coreData.backgroundContext
//            )
//
//            _ = ActivityItem.arrange(
//                context: coreData.backgroundContext
//            )
//
//            _ = ActivityItem.arrange(
//                context: coreData.backgroundContext
//            )
//
//            try? coreData.backgroundContext.save()
//
//            sut.$sections
//                .receive(on: DispatchQueue.main)
//                .sink { value in
//                    continuation.resume(returning: value)
//                }.store(in: &cancellables)
//        }
//        #expect(result[0].rows.count == 3)
//    }
//}
//
