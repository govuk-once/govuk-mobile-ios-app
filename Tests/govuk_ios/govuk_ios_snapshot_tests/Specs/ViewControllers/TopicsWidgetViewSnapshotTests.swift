import Foundation
import XCTest
import GovKit
import UIKit

@testable import govuk_ios

@MainActor
final class TopicsWidgetViewSnapshotTests: SnapshotTestCase {
    var coreData: CoreDataRepository!

    override func setUp() async throws {
        try await super.setUp()
        self.coreData = await CoreDataRepository.arrangeAndLoad
    }

    func test_loadInNavigationController_populated_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(selectedTab: .favourite),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_populated_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(selectedTab: .favourite),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_populated_allTopics_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(selectedTab: .all),
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_loadInNavigationController_populated_allTopics_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            viewController: viewController(selectedTab: .all),
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    private func viewController(selectedTab: TopicsTab) -> UIViewController {

        let mockTopicService = MockTopicsService()
        let favouriteOne = Topic.arrange(
            context: coreData.backgroundContext
        )
        favouriteOne.title = "test"
        mockTopicService._stubbedHasCustomisedTopics = true
        let allOne = Topic.arrange(context: coreData.backgroundContext)
        let allTwo = Topic.arrange(context: coreData.backgroundContext)
        allOne.title = "test2"
        allTwo.title = "test3"

        mockTopicService._stubbedFetchFavouriteTopics = [favouriteOne]
        mockTopicService._stubbedFetchAllTopics = [allOne, allTwo, favouriteOne]

        let viewModel = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: MockAnalyticsService(),
            userDefaultsService: MockUserDefaultsService(),
            topicAction: { _ in },
            dismissEditAction: { }
        )
        viewModel.selectedTab = selectedTab

        let view = TopicsWidgetView(
            viewModel: viewModel
        )
        return HostingViewController(
            rootView: view
        )
    }
}

