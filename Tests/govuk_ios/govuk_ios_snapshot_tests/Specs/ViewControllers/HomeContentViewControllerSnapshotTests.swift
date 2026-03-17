import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class HomeContentViewControllerSnapshotTests: SnapshotTestCase {

    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController() -> UIViewController {
        let topicsWidgetViewModel = TopicsWidgetViewModel(
            topicsService: MockTopicsService(),
            analyticsService: MockAnalyticsService(),
            topicAction: {_ in },
            dismissEditAction: { }
        )
        let localWasteWidgetViewModel = LocalWasteWidgetViewModel(
            service: MockLocalWasteService()
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
            localWasteWidgetViewModel: localWasteWidgetViewModel,
            urlOpener: MockURLOpener(),
            searchService: MockSearchService(),
            activityService: MockActivityService(),
            localAuthorityService: MockLocalAuthorityService(),
            localWasteService: MockLocalWasteService(),
            chatService: MockChatService(),
            localAuthorityAction: { },
            editLocalAuthorityAction: { },
            editLocalWasteAction: { },
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



