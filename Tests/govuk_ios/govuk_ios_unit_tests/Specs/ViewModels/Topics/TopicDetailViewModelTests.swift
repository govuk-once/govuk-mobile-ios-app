import Testing
import UIKit

@testable import govuk_ios
@testable import GovKit

struct TopicDetailViewModelTests {

    let mockTopicsService = MockTopicsService()
    let mockAnalyticsService = MockAnalyticsService()
    let mockActivityService = MockActivityService()
    let mockURLOpener = MockURLOpener()
    
    @Test
    func viewDidAppear_noUnpopularContent_doesCreateSectionsCorrectly() async throws {
        mockTopicsService._stubbedFetchTopicDetailsResult = .success(
            .arrange(
                fileName: "NoUnpopularContent"
            )
        )
        let coreData = CoreDataRepository.arrangeAndLoad
        let sut = TopicDetailViewModel(
            topic: Topic.arrange(context: coreData.viewContext),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: .empty
        )
        await sut.viewDidAppear()

        try #require(sut.sections.count == 2)
        #expect(sut.sections[0].heading?.title == "Popular pages in this topic")
        #expect(sut.sections[0].heading?.icon == nil)

        #expect(sut.sections[1].heading?.title == "Step-by-step guides")
        #expect(sut.sections[1].heading?.icon == nil)

        #expect(sut.sections[0].rows.first is LinkRow)
        #expect(sut.sections[1].rows.last is LinkRow)
        #expect(sut.subtopicCards.count == 7)
        #expect(sut.shouldShowDescription)
    }
    
    @Test
    func viewDidAppear_fiveStepByStep_doesCreateSectionsCorrectly() async throws {
        mockTopicsService._stubbedFetchTopicDetailsResult = .success(
            .arrange(
                fileName: "FiveStepByStep"
            )
        )
        let coreData = CoreDataRepository.arrangeAndLoad
        let sut = TopicDetailViewModel(
            topic: Topic.arrange(context: coreData.viewContext),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: .empty
        )
        await sut.viewDidAppear()

        try #require(sut.sections.count == 2)
        #expect(sut.sections[0].heading?.title == "Popular pages in this topic")
        #expect(sut.sections[0].heading?.icon == nil)

        #expect(sut.sections[1].heading?.title == "Step-by-step guides")
        #expect(sut.sections[1].heading?.icon == nil)
        #expect(sut.sections[1].heading?.actionTitle == "See all")

        #expect(sut.subtopicCards.count == 7)

        #expect(sut.sections[0].rows.first is LinkRow)
        
        #expect(sut.sections[1].rows.count == 3)
        #expect(sut.sections[1].rows.first is LinkRow)
        #expect(sut.sections[1].rows.last is LinkRow)
    }
    
    @Test
    func viewDidAppear_hasUnpopularContent_doesCreateSectionsCorrectly() async throws {
        mockTopicsService._stubbedFetchTopicDetailsResult = .success(
            .arrange(
                fileName: "UnpopularContent"
            )
        )
        let coreData = CoreDataRepository.arrangeAndLoad
        let sut = TopicDetailViewModel(
            topic: Topic.arrange(context: coreData.viewContext),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: .empty,
        )
        await sut.viewDidAppear()

        try #require(sut.sections.count == 3)
        #expect(sut.sections[0].heading?.title == "Popular pages in this topic")
        #expect(sut.sections[0].heading?.icon == nil)

        #expect(sut.sections[1].heading?.title == "Step-by-step guides")
        #expect(sut.sections[1].heading?.icon == nil)

        #expect(sut.sections[2].heading?.title == "Services and information")
        #expect(sut.sections[2].heading?.icon == nil)

        #expect(sut.subtopicCards.count == 7)

        #expect(sut.sections[0].rows.first is LinkRow)
        #expect(sut.sections[1].rows.first is LinkRow)
        #expect(sut.sections[2].rows.last is LinkRow)
        #expect(sut.sections[2].rows.count == 3)
    }

    @Test
    func viewDidAppear_subtopic_noOtherContent_returnsCorrectHeader() async throws {
        let expectedContent = TopicDetailResponse.arrange()
        mockTopicsService._stubbedFetchTopicDetailsResult = .success(expectedContent)
        let sut = TopicDetailViewModel(
            topic: TopicDetailResponse.Subtopic(ref: "test", title: "test", topicDescription: "description"),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: .empty,
        )
        await sut.viewDidAppear()

        #expect(sut.sections[3].heading?.title == "Related")
        #expect(sut.sections[3].heading?.icon == nil)
        #expect(sut.sections[3].rows.count == expectedContent.subtopics.count)
    }

    @Test
    func tappingSubtopic_doesFireNavigationEvent() async throws {
        var didNavigate = false
        mockTopicsService._stubbedFetchTopicDetailsResult = .success(
            .arrange(
                fileName: "UnpopularContent"
            )
        )
        let actions = TopicDetailViewModel.Actions(
            subtopicAction: { _ in
                didNavigate = true
            },
            stepByStepAction: { _ in },
            openAction: { _ in },
        )
        let sut = TopicDetailViewModel(
            topic: MockDisplayableTopic(ref: "", title: "", topicDescription: nil),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: actions
        )
        await sut.viewDidAppear()

        try #require(sut.sections.count == 3)
        let subTopicRow = try #require(sut.subtopicCards.first)
        subTopicRow.action()
        #expect(didNavigate)
        #expect(mockAnalyticsService._trackedEvents.count == 2)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Driving")
    }
    
    @Test
    func tappingContent_doesFireLinkEvent() async throws {
        mockTopicsService._stubbedFetchTopicDetailsResult = .success(
            .arrange(
                fileName: "UnpopularContent"
            )
        )
        let sut = TopicDetailViewModel(
            topic: MockDisplayableTopic(ref: "", title: "", topicDescription: nil),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: .empty
        )
        await sut.viewDidAppear()

        try #require(sut.sections.count == 3)
        let contentRow = try #require(sut.sections[0].rows.first as? LinkRow)
        contentRow.action()
        #expect(mockAnalyticsService._trackedEvents.count == 2)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["url"] as? String == "https://www.gov.uk/view-driving-licence")
    }

    @Test
    func viewDidAppear_apiUnavailable_doesCreateCorrectErrorViewModel() async throws {
        mockTopicsService._stubbedFetchTopicDetailsResult = .failure(.apiUnavailable)
        let sut = TopicDetailViewModel(
            topic: MockDisplayableTopic(ref: "", title: "", topicDescription: nil),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: .empty
        )
        await sut.viewDidAppear()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("genericErrorTitle"))
        #expect(errorViewModel.body == String.topics.localized("topicFetchErrorSubtitle"))
        #expect(errorViewModel.buttonTitle == String.common.localized("genericErrorButtonTitle"))
        #expect(errorViewModel.buttonAccessibilityLabel
                == String.common.localized("genericErrorButtonTitleAccessibilityLabel")
        )
        #expect(errorViewModel.isWebLink)
        errorViewModel.action?()
        #expect(mockURLOpener._receivedOpenIfPossibleUrl == Constants.API.govukBaseUrl)
    }
    
    @Test
    func viewDidAppear_networkUnavailable_doesCreateCorrectErrorViewModel() async throws {
        mockTopicsService._stubbedFetchTopicDetailsResult = .failure(.networkUnavailable)
        let sut = TopicDetailViewModel(
            topic: MockDisplayableTopic(ref: "", title: "", topicDescription: nil),
            topicsService: mockTopicsService,
            analyticsService: mockAnalyticsService,
            activityService: mockActivityService,
            urlOpener: mockURLOpener,
            actions: .empty
        )
        await sut.viewDidAppear()
        let errorViewModel = try #require(sut.errorViewModel)
        #expect(errorViewModel.title == String.common.localized("networkUnavailableErrorTitle"))
        #expect(errorViewModel.body == String.common.localized("networkUnavailableErrorBody"))
        #expect(errorViewModel.buttonTitle == String.common.localized("networkUnavailableButtonTitle"))
        #expect(errorViewModel.buttonAccessibilityLabel == nil)
        #expect(errorViewModel.isWebLink == false)
        mockTopicsService._fetchDetailsCalled = false

        await withCheckedContinuation { continuation in
            mockTopicsService._fetchTopicDetailsCompletion = {
                continuation.resume()
            }
            errorViewModel.action?()
        }
        #expect(mockTopicsService._fetchDetailsCalled)
    }
}

extension TopicDetailViewModel.Actions {
    static var empty: TopicDetailViewModel.Actions {
        .init(
            subtopicAction: { _ in },
            stepByStepAction: { _ in },
            openAction: { _ in }
        )
    }
}
