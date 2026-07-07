import Foundation
import XCTest
import UIKit

@testable import govuk_ios

@MainActor
class HomeViewControllerSnapshotTests: SnapshotTestCase {
    let mockTopicService = MockTopicsService()
    let mockAnalyticsService = MockAnalyticsService()
    var coreData: CoreDataRepository!

    override func setUp() async throws {
        try await super.setUp()
        await coreData = CoreDataRepository.arrangeAndLoad
    }

    func test_loadInNavigationController_light_rendersCorrectly() {
        mockTopicService._stubbedHasCustomisedTopics = true
        mockTopicService._stubbedFetchRemoteListResult = .success(TopicResponseItem.arrangeMultiple)
        var topics = Topic.arrangeMultipleFavourites(
            context: coreData.viewContext
        )
        mockTopicService._stubbedFetchAllTopics = topics

        topics.removeLast()
        mockTopicService._stubbedFetchFavouriteTopics = topics
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        mockTopicService._stubbedFetchRemoteListResult = .success(TopicResponseItem.arrangeMultiple)
        let topics = Topic.arrangeMultipleFavourites(
            context: coreData.viewContext
        )
        mockTopicService._stubbedFetchAllTopics = topics
        mockTopicService._stubbedFetchFavouriteTopics = topics

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_deselectedAllTopics_rendersCorrectly() {
        let topics = Topic.arrangeMultipleFavourites(
            context: coreData.viewContext
        )
        mockTopicService._stubbedFetchAllTopics = topics
        mockTopicService._stubbedHasCustomisedTopics = true
        mockTopicService._stubbedFetchFavouriteTopics = []
        mockTopicService._stubbedFetchRemoteListResult = .success([])

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_deselectedAllTopics_dark_rendersCorrectly() {
        let topics = Topic.arrangeMultipleFavourites(
            context: coreData.viewContext
        )
        mockTopicService._stubbedFetchAllTopics = topics
        mockTopicService._stubbedHasCustomisedTopics = true
        mockTopicService._stubbedFetchFavouriteTopics = []
        mockTopicService._stubbedFetchRemoteListResult = .success([])

        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            navBarHidden: true
        )
    }

    func viewController() -> HomeViewController {
        let topicsViewModel = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedShouldRequestPermission = true

        let configService = MockAppConfigService()
        let promoLink1 = PromoBanner.Link(
            title: "View travel advice",
            url: URL(string: "govuk://gov.uk/chat")!
        )
        let promoLink2 = PromoBanner.Link(
            title: "View travel advice",
            url: URL(string: "https://www.gov.uk/foreign-travel-advice")!
        )
        let banners = [
            PromoBanner(
                id: UUID().uuidString,
                title: "Going on holibobs?",
                body: "Make sure you check out travel advice first",
                link: promoLink1
            ),
            PromoBanner(
                id: UUID().uuidString,
                title: "Going on holz?",
                body: "Make sure you check out travel advice first",
                link: promoLink2
            ),
        ]
        configService._stubbedPromoBanners = banners
        let viewModel = HomeViewModel(
            analyticsService: mockAnalyticsService,
            configService: configService,
            notificationService: MockNotificationService(),
            userDefaultsService: MockUserDefaultsService(),
            topicsWidgetViewModel: topicsViewModel,
            urlOpener: MockURLOpener(),
            searchService: MockSearchService(),
            activityService: MockActivityService(context: coreData.viewContext),
            localAuthorityService: MockLocalAuthorityService(),
            chatService: MockChatService(),
            localAuthorityAction: { },
            editLocalAuthorityAction: { },
            feedbackAction: { },
            notificationsAction: { },
            recentActivityAction: { },
            openURLAction: { _ in },
            openAction: { _ in }
        )
        return HomeViewController(viewModel: viewModel)
    }
}
