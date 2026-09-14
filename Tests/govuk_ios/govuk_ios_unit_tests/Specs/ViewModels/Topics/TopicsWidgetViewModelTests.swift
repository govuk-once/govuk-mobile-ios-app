import Testing
import Combine
import Foundation
import FactoryKit

@testable import govuk_ios

@Suite
class TopicsWidgetViewModelTests {
    let mockTopicService = MockTopicsService()
    let mockAnalyticsService = MockAnalyticsService()
    let mockUserDefaultsService = MockUserDefaultsService()

    @Test
    @MainActor
    func fetchTopics_downloadSuccess_returnsExpectedData() async throws {
        var cancellables = Set<AnyCancellable>()
        let mockTopicService = MockTopicsService()
        mockTopicService._stubbedFetchRemoteListResult = .success(TopicResponseItem.arrangeMultiple)
        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        let result = await withCheckedContinuation { continuation in
            sut.$fetchTopicsError
                .receive(on: DispatchQueue.main)
                .dropFirst()
                .sink(
                    receiveValue: { error in
                        continuation.resume(returning: error)
                        cancellables.removeAll()
                    }
                ).store(in: &cancellables)
            sut.fetchTopics()
        }
        #expect(result == false)
    }

    @Test
    @MainActor
    func fetchTopics_downloadFailure_returnsExpectedResult() async throws {
        var cancellables = Set<AnyCancellable>()
        let mockTopicService = MockTopicsService()
        mockTopicService._stubbedFetchRemoteListResult = .failure(.decodingError)
        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        let result = await withCheckedContinuation { continuation in
            sut.$fetchTopicsError
                .receive(on: DispatchQueue.main)
                .dropFirst()
                .sink(
                    receiveValue: { error in
                        continuation.resume(returning: error)
                        cancellables.removeAll()
                    }
                ).store(in: &cancellables)
            sut.fetchTopics()
        }
        #expect(result == true)
    }

    @Test
    @MainActor
    func didTapTopic_invokesExpectedAction() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        var expectedValue = false
        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in
                expectedValue = true
            },
            dismissEditAction: { }
        )

        sut.topicAction(Topic(context: coreData.viewContext))
        #expect(expectedValue == true)
    }

    @Test
    func fetchAllTopics_returnsCorrectCount() async throws  {
        let coreData = await CoreDataRepository.arrangeAndLoad
        var cancellables = Set<AnyCancellable>()
        let result = await withCheckedContinuation { continuation in

            let allOne = Topic.arrange(context: coreData.backgroundContext)
            let allTwo = Topic.arrange(context: coreData.backgroundContext)

            mockTopicService._stubbedFetchAllTopics = [allOne, allTwo]

            let sut = TopicsWidgetViewModel(
                topicsService: mockTopicService,
                analyticsService: mockAnalyticsService,
                userDefaultsService: mockUserDefaultsService,
                topicAction: { _ in },
                dismissEditAction: { }
            )
            sut.$allTopics
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { value in
                    continuation.resume(returning: value)
                    cancellables.removeAll()
                }.store(in: &cancellables)
            sut.updateAllTopics()
        }
        #expect(result.count == 2)
    }

    @Test
    func isThereFavouritedTopics_returnsCorrectValue() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let favouriteOne = Topic.arrange(context: coreData.backgroundContext)
        let favouriteTwo = Topic.arrange(context: coreData.backgroundContext)
        mockTopicService._stubbedHasCustomisedTopics = true

        let allOne = Topic.arrange(context: coreData.backgroundContext)
        let allTwo = Topic.arrange(context: coreData.backgroundContext)

        mockTopicService._stubbedFetchFavouriteTopics = [favouriteOne, favouriteTwo]
        mockTopicService._stubbedFetchAllTopics = [allOne, allTwo, favouriteOne, favouriteTwo]

        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        #expect(sut.hasFavouritedTopics == true)
    }


    @Test
    func topicsToBeDisplayed_topicsHaveBeenEdited_returnsFavourites() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        var cancellables = Set<AnyCancellable>()
        let favouriteOne = Topic.arrange(context: coreData.backgroundContext)
        let favouriteTwo = Topic.arrange(context: coreData.backgroundContext)
        let result = await withCheckedContinuation { continuation in
            mockTopicService._stubbedHasCustomisedTopics = true

            let allOne = Topic.arrange(context: coreData.backgroundContext)
            let allTwo = Topic.arrange(context: coreData.backgroundContext)

            mockTopicService._stubbedFetchFavouriteTopics = [favouriteOne, favouriteTwo]
            mockTopicService._stubbedFetchAllTopics = [allOne, allTwo, favouriteOne, favouriteTwo]

            let sut = TopicsWidgetViewModel(
                topicsService: mockTopicService,
                analyticsService: mockAnalyticsService,
                userDefaultsService: mockUserDefaultsService,
                topicAction: { _ in },
                dismissEditAction: { }
            )
            sut.$favouriteTopics
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { value in
                    continuation.resume(returning: value)
                    cancellables.removeAll()
                }.store(in: &cancellables)
            sut.updateFavouriteTopics()
        }
        #expect(result.count == 2)
        #expect(result.first ==  favouriteOne)
        #expect(result.last ==  favouriteTwo)
    }

    @Test
    func widgetTitle_returnsExpectedResult() {
        mockTopicService._stubbedHasCustomisedTopics = false
        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        #expect(sut.widgetTitle == "Topics")
    }

    @Test
    @MainActor
    func setSelectedTab_allTopics_createsExpectedECommerceEvent() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let allOne = Topic.arrange(context: coreData.backgroundContext)
        let allTwo = Topic.arrange(context: coreData.backgroundContext)

        mockTopicService._stubbedFetchAllTopics = [allOne, allTwo]

        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        sut.refreshTopics()
        sut.initialLoadComplete = true
        sut.selectedTab = .all
        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.name == "view_item_list")
        let eventParams = try #require(mockAnalyticsService._trackedEvents.first?.params)
        #expect((eventParams["item_list_name"] as? String) == "All topics")
        #expect((eventParams["item_list_id"] as? String) == "All topics")
        #expect((eventParams["results"] as? Int) == 2)
    }

    @Test
    @MainActor
    func setSelectedTab_favouriteTopics_createsExpectedECommerceEvent() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let favouriteOne = Topic.arrange(
            context: coreData.backgroundContext,
            isFavourite: true
        )
        let favouriteTwo = Topic.arrange(
            context: coreData.backgroundContext,
            isFavourite: true
        )

        mockTopicService._stubbedFetchFavouriteTopics = [favouriteOne, favouriteTwo]

        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        sut.initialLoadComplete = true
        sut.refreshTopics()
        sut.selectedTab = .all
        sut.selectedTab = .favourite
        #expect(mockAnalyticsService._trackedEvents.count == 2)
        #expect(mockAnalyticsService._trackedEvents.first?.name == "view_item_list")
        let eventParams = try #require(mockAnalyticsService._trackedEvents[1].params)
        #expect((eventParams["item_list_name"] as? String) == "Your topics")
        #expect((eventParams["results"] as? Int) == 2)
    }

    @Test
    @MainActor
    func setSelectedTab_isTheSameAsOldValue_doesNotCreateECommerceEvent() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let favouriteOne = Topic.arrange(
            context: coreData.backgroundContext,
            isFavourite: true
        )
        let favouriteTwo = Topic.arrange(
            context: coreData.backgroundContext,
            isFavourite: true
        )
        var lastSelectedTab = [TopicsTab]()

        mockTopicService._stubbedFetchFavouriteTopics = [favouriteOne, favouriteTwo]

        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        lastSelectedTab.append(sut.selectedTab)
        sut.initialLoadComplete = true
        sut.refreshTopics()
        sut.selectedTab = .favourite
        mockAnalyticsService._trackedEvents = []
        sut.selectedTab = .favourite
        #expect(mockAnalyticsService._trackedEvents.count == 0)
    }

    @Test
    @MainActor
    func setSelectedTab_initialLoadCompleteIsFalse_andTopicsIsDifferentFromOldValue_doesNotcreateECommerceEvent() async throws {

        let coreData = await CoreDataRepository.arrangeAndLoad
        let allOne = Topic.arrange(context: coreData.backgroundContext)
        let allTwo = Topic.arrange(context: coreData.backgroundContext)

        mockTopicService._stubbedFetchAllTopics = [allOne, allTwo]

        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        sut.initialLoadComplete = false
        sut.refreshTopics()
        sut.selectedTab = .all
        #expect(mockAnalyticsService._trackedEvents.count == 0)
        #expect(mockAnalyticsService._trackedEvents.first?.name == nil)
    }

    @Test
    func setSelectedTab_storesTabInUserDefaults() throws {
        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        sut.selectedTab = .all
        let storedTab = try #require(mockUserDefaultsService.value(forKey: .topicsSelectedTab)) as? String
        #expect(storedTab == TopicsTab.all.rawValue)
    }

    @Test
    func init_restoresSelectedTabFromUserDefaults() {
        let userDefaultsKey = UserDefaultsKeys.topicsSelectedTab.rawValue
        mockUserDefaultsService._stub(value: TopicsTab.all.rawValue, key: userDefaultsKey)
        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        #expect(sut.selectedTab == .all)
    }

    @Test
    func init_whenUserDefaultsSelectedTabIsNil_defaultsToFavourite() {
        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in },
            dismissEditAction: { }
        )
        #expect(sut.selectedTab == .favourite)
    }

    @Test
    @MainActor
    func selectingTopic_createsExpectedECommerceEvent() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let favouriteOne = Topic.arrange(
            context: coreData.backgroundContext,
            ref: "Care",
            title: "Care",
            isFavourite: true
        )
        let favouriteTwo = Topic.arrange(
            context: coreData.backgroundContext,
            isFavourite: true
        )

        mockTopicService._stubbedFetchFavouriteTopics = [favouriteOne, favouriteTwo]

        let sut = TopicsWidgetViewModel(
            topicsService: mockTopicService,
            analyticsService: mockAnalyticsService,
            userDefaultsService: mockUserDefaultsService,
            topicAction: { _ in},
            dismissEditAction: { }
        )

        sut.refreshTopics()
        sut.trackECommerceSelection("Care")
        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.name == "select_item")
        let eventParams = try #require(mockAnalyticsService._trackedEvents.first?.params)
        #expect((eventParams["item_list_name"] as? String) == "Your topics")
        #expect((eventParams["results"] as? Int) == 2)
    }
}
