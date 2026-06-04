import Testing
import FactoryKit
@testable import govuk_ios

class EditTopicsViewModelTests {
    let mockAnalyticsService = MockAnalyticsService()
    @Test
    func init_withTopics_createsTopicCardsCorrectly() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let topicService = TopicsService(
            topicsServiceClient: MockTopicsServiceClient(),
            analyticsService: mockAnalyticsService,
            userDefaultsService: MockUserDefaultsService(),
            topicsRepository: {
                TopicsRepository(coreData: coreData)
            })

        try createTopics(coreData)

        let sut = EditTopicsViewModel(
            topicsService: topicService,
            analyticsService: mockAnalyticsService
        )

        #expect(sut.topicSelectionCards.count == 3)
        #expect((sut.topicSelectionCards[0] as Any) is TopicSelectionCardViewModel)
    }

    @Test
    func tapAction_savesTopic() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let topicService = TopicsService(
            topicsServiceClient: MockTopicsServiceClient(),
            analyticsService: mockAnalyticsService,
            userDefaultsService: MockUserDefaultsService(),
            topicsRepository: {
                TopicsRepository(coreData: coreData)
            })

        try createTopics(coreData)

        let sut = EditTopicsViewModel(
            topicsService: topicService,
            analyticsService: mockAnalyticsService
        )

        let topicCard = sut.topicSelectionCards[0]
        topicCard.tapAction(true)
        #expect(topicService.fetchFavourites().count == 1)
        let trackedEvent = mockAnalyticsService._trackedEvents.first
        #expect(trackedEvent?.params?["text"] as? String == topicCard.title)
        #expect(trackedEvent?.params?["type"] as? String == "Button")
        #expect(trackedEvent?.params?["section"] as? String == "Edit topics")
        #expect(trackedEvent?.params?["action"] as? String == "add")
    }
}

private extension EditTopicsViewModelTests {
    func createTopics(_ coreData: CoreDataRepository) throws {
        var topics = [Topic]()
        for index in 0..<3 {
            let topic = Topic(context: coreData.backgroundContext)
            topic.ref = "ref\(index)"
            topic.title = "title\(index)"
            topic.isFavourite = false
            topics.append(topic)
        }
        try coreData.backgroundContext.save()
    }
}
