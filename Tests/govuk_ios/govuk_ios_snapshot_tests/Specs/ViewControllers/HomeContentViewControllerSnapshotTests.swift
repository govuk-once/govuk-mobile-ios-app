import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class HomeContentViewControllerSnapshotTests: SnapshotTestCase {
    var coreData: CoreDataRepository!

    override func setUp() async throws {
        try await super.setUp()
        await coreData = CoreDataRepository.arrangeAndLoad
    }

    func test_loadInNavigationController_light_rendersCorrectly() async {
        let viewController = await viewController()
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() async  {
        let viewController = await viewController()
        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() async -> UIViewController {
        let topicsWidgetViewModel = TopicsWidgetViewModel(
            topicsService: MockTopicsService(),
            analyticsService: MockAnalyticsService(),
            topicAction: {_ in },
            dismissEditAction: { }
        )
        let configService = MockAppConfigService()
        configService._stubbedUserFeedbackBanner = UserFeedbackBanner(
            body: "",
            link: .init(
                title: "testUrl",
                url: URL(string: "https://www.gov.uk/")!)
        )

        let viewModel = HomeViewModel(
            analyticsService: MockAnalyticsService(),
            configService: configService,
            notificationService: MockNotificationService(),
            userDefaultsService: MockUserDefaultsService(),
            topicsWidgetViewModel: topicsWidgetViewModel,
            urlOpener: MockURLOpener(),
            searchService: MockSearchService(),
            activityService: MockActivityService(context: coreData.viewContext),
            localAuthorityService: MockLocalAuthorityService(),
            chatService: MockChatService(),
            localAuthorityAction: { },
            editLocalAuthorityAction: { },
            feedbackAction: { },
            notificationsAction: {},
            recentActivityAction: { } ,
            openURLAction: {_ in } ,
            openAction: {_ in }
        )
        let view = HomeContentView(
            viewModel: viewModel
        )
        return HostingViewController(rootView: view)
    }
}



