import SwiftUI
import GovKit

// swiftlint:disable:next type_body_length
class TopicDetailViewModel: TopicDetailViewModelInterface {
    @Published private(set) var topicActionCards = [ListCardViewModel]()
    @Published private(set) var sections = [GroupedListSection]()
    @Published private(set) var errorViewModel: AppErrorViewModel?
    @Published private(set) var subtopicCards = [ListCardViewModel]()
    var commerceItems = [TopicCommerceItem]()

    private var topicDetail: TopicDetailResponse?
    private var topic: DisplayableTopic

    private let topicsService: TopicsServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let activityService: ActivityServiceInterface
    private let configService: AppConfigServiceInterface
    private let userService: UserServiceInterface
    private let urlOpener: URLOpener
    private let topicAction: (DisplayableTopic) -> Void
    private let subtopicAction: (DisplayableTopic) -> Void
    private let stepByStepAction: ([TopicDetailResponse.Content]) -> Void
    private let openAction: (URL) -> Void

    var isLoaded: Bool = false

    var title: String {
        topic.title
    }

    var description: String? {
        guard shouldShowDescription
        else { return nil }
        return topic.topicDescription
    }

    var shouldShowDescription: Bool {
        !(topic is TopicDetailResponse.Subtopic)
    }


    init(topic: DisplayableTopic,
         topicsService: TopicsServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         activityService: ActivityServiceInterface,
         configService: AppConfigServiceInterface,
         userService: UserServiceInterface,
         urlOpener: URLOpener,
         actions: Actions) {
        self.topic = topic
        self.topicsService = topicsService
        self.analyticsService = analyticsService
        self.activityService = activityService
        self.configService = configService
        self.userService = userService
        self.urlOpener = urlOpener
        topicAction = actions.topicAction
        subtopicAction = actions.subtopicAction
        stepByStepAction = actions.stepByStepAction
        openAction = actions.openAction
    }

    @MainActor
    private func fetchContent() async {
        isLoaded = false
        async let topicDetailTask = fetchTopicDetails(topicRef: topic.ref)
        async let dvlaLinkStatusTask: () = fetchDvlaAccountLinkStatus()
        let (topicDetailResult, _) = await (topicDetailTask, dvlaLinkStatusTask)

        if case .success(let detail) = topicDetailResult {
            topicDetail = detail
            contentFetched()
        }
        handleError(topicDetailResult.getError())
    }

    private func contentFetched() {
        updateTopicActionCards()
        configureSections()
        createSubtopicCards()
        isLoaded = true
    }

    private func fetchTopicDetails(topicRef: String) async -> FetchTopicDetailsResult {
        await withCheckedContinuation { continuation in
            topicsService.fetchDetails(ref: topicRef) { result in
                continuation.resume(returning: result)
            }
        }
    }

    private func fetchDvlaAccountLinkStatus() async {
        guard configService.isFeatureEnabled(key: .dvla),
              topic.ref == "driving-transport" else {
            return
        }
        await userService.fetchAccountLinkStatus(
            accountType: .dvla
        )
        // tbc: how to handle error?
    }

    private func configureSections() {
        sections = [
            createPopularContentSection(),
            createStepByStepSection(),
            createOtherContentSection(),
            createRelatedSubtopicsSection()
        ].compactMap { $0 }
    }

    private func handleError(_ error: TopicsServiceError?) {
        guard let error else {
            errorViewModel = nil
            return
        }
        switch error {
        case .networkUnavailable:
            errorViewModel = AppErrorViewModel.networkUnavailable(
                action: {
                    Task {
                        await self.fetchContent()
                    }
                }
            )
        default:
            errorViewModel = topicErrorViewModel
        }
    }

    private func createPopularContentSection() -> GroupedListSection? {
        guard let content = topicDetail?.popularContent else { return nil }
        let sectionTitle = String.topics.localized("topicDetailPopularPagesHeader")
        return GroupedListSection(
            heading: GroupedListHeader(
                title: sectionTitle
            ),
            rows: content.map { createContentRow($0, sectionTitle: sectionTitle) },
            footer: nil
        )
    }

    private func createStepByStepSection() -> GroupedListSection? {
        guard let stepBySteps = topicDetail?.stepByStepContent
        else { return nil }
        var rows = [GroupedListRow]()
        let sectionTitle = String.topics.localized("topicDetailStepByStepHeader")
            rows = Array(stepBySteps.prefix(3)).map {
                createContentRow($0,
                                 sectionTitle: sectionTitle,
                                 imageName: "step_by_step")
            }

        var action: (() -> Void)?
        var actionTitle: String?
        var accessibilityActionTitle: String?
        if stepBySteps.count > 3 {
            actionTitle = String.topics.localized("topicDetailSeeAllButtonTitle")
            accessibilityActionTitle =
            String.topics.localized("topicDetailSeeAllStepByStepAccessibilityTitle")
            action = { [weak self] in
                self?.trackLinkEvent(
                    contentTitle: actionTitle!,
                    sectionTitle: sectionTitle,
                    external: false
                )
                self?.stepByStepAction(stepBySteps)
            }
        }

        return GroupedListSection(
            heading: GroupedListHeader(
                title: sectionTitle,
                actionTitle: actionTitle,
                accessibilityActionTitle: accessibilityActionTitle,
                action: action
            ),
            rows: rows,
            footer: nil
        )
    }

    private func createSubtopicCards() {
        guard let detail = topicDetail,
              detail.subtopics.count > 0,
              !isRelatedContent
        else { return }
        subtopicCards = detail.subtopics.map { content in
            createSubtopicCommerceItem(
                content,
                category: String.topics.localized("subtopicDetailSubtopicsHeader"))
            return ListCardViewModel(
                title: content.title,
                action: { [weak self] in
                    self?.trackSubtopicNavigationEvent(content)
                    self?.subtopicAction(content)
                }
            )
        }
    }

    func updateTopicActionCards() {
        // hard coded DVLA account linking action card
        guard configService.isFeatureEnabled(key: .dvla),
              topic.ref == "driving-transport" else { return }
        let title = userService.isDvlaAccountLinked
        ? "Unlink your driver and vehicles account"
        : "Add your driver and vehicles account"
        let content = TopicDetailResponse.Subtopic(
            ref: "dvla-link-account",
            title: title,
            topicDescription: nil)
        let dvlaAccountLinkingCard = ListCardViewModel(
            title: content.title,
            action: { [weak self] in
                self?.topicAction(content)
            }
        )
        topicActionCards = [dvlaAccountLinkingCard]
    }

    private func createRelatedSubtopicsSection() -> GroupedListSection? {
        guard let detail = topicDetail,
              detail.subtopics.count > 0,
              isRelatedContent
        else { return nil }
        return GroupedListSection(
            heading: GroupedListHeader(
                title: String.topics.localized("subtopicDetailSubtopicsHeader")
            ),
            rows: detail.subtopics.map { createSubtopicRow($0) },
            footer: nil
        )
    }

    private var isRelatedContent: Bool {
        topic is TopicDetailResponse.Subtopic && topicDetail?.content.isEmpty == false
    }


    private func createOtherContentSection() -> GroupedListSection? {
        guard let content = topicDetail?.otherContent
        else { return nil }
        let sectionTitle = String.topics.localized("topicDetailOtherContentHeader")
        return GroupedListSection(
            heading: GroupedListHeader(
                title: sectionTitle
            ),
            rows: content.map { createContentRow($0, sectionTitle: sectionTitle) },
            footer: nil
        )
    }

    private func createContentRow(_ content: TopicDetailResponse.Content,
                                  sectionTitle: String,
                                  imageName: String? = nil) -> LinkRow {
        createCommerceItem(content, category: sectionTitle)
        return LinkRow(
            id: UUID().uuidString,
            title: content.title,
            body: nil,
            imageName: imageName,
            showLinkImage: false,
            action: {
                self.openAction(content.url)
                self.activityService.save(topicContent: content)
                self.trackLinkEvent(
                    content: content,
                    sectionTitle: sectionTitle
                )
            }
        )
    }

    private func createSubtopicRow(_ content: TopicDetailResponse.Subtopic) -> NavigationRow {
        createSubtopicCommerceItem(
            content,
            category: String.topics.localized("subtopicDetailSubtopicsHeader")
        )
        return NavigationRow(
            id: content.ref,
            title: content.title,
            body: nil,
            action: { [weak self] in
                self?.trackSubtopicNavigationEvent(content)
                self?.subtopicAction(content)
            }
        )
    }

    @MainActor
    func viewDidAppear() async {
        if isLoaded {
            updateTopicActionCards()
            trackEcommerce()
        } else {
            await fetchContent()
        }
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func trackEcommerce() {
        let eCommerceEvent = AppEvent.viewItemList(
            name: "Topics",
            id: topic.title,
            items: commerceItems
        )
        analyticsService.track(event: eCommerceEvent)
    }

    private func trackLinkEvent(content: TopicDetailResponse.Content,
                                sectionTitle: String) {
        let event = AppEvent.topicLinkNavigation(
            content: content,
            sectionTitle: sectionTitle
        )
        analyticsService.track(event: event)
        guard let commerceEvent = createCommerceEvent(content.title) else { return }
        analyticsService.track(event: commerceEvent)
    }

    private func trackLinkEvent(contentTitle: String,
                                sectionTitle: String,
                                external: Bool = false) {
        let event = AppEvent.topicLinkNavigation(
            title: contentTitle,
            sectionTitle: sectionTitle,
            url: nil,
            external: external
        )
        analyticsService.track(event: event)
        guard let commerceEvent = createCommerceEvent(contentTitle) else { return }
        analyticsService.track(event: commerceEvent)
    }

    private func trackSubtopicNavigationEvent(_ subtopic: TopicDetailResponse.Subtopic) {
        let event = AppEvent.subtopicNavigation(subtopic: subtopic)
        analyticsService.track(event: event)
        guard let commerceEvent = createCommerceEvent(subtopic.title) else { return }
        analyticsService.track(event: commerceEvent)
    }

    private func createSubtopicCommerceItem(_ subtopic: TopicDetailResponse.Subtopic,
                                            category: String) {
        let appEventItem = TopicCommerceItem(
            name: subtopic.title,
            category: category,
            index: commerceItems.count + 1,
            itemId: nil,
            locationId: nil
        )
        commerceItems.append(appEventItem)
    }

    private func createSeeAllCommerceItem(_ rowTitle: String,
                                          category: String) {
        let appEventItem = TopicCommerceItem(
            name: rowTitle,
            category: category,
            index: commerceItems.count + 1,
            itemId: nil,
            locationId: nil
        )
        commerceItems.append(appEventItem)
    }

    private var topicErrorViewModel: AppErrorViewModel {
        .topicErrorWithAction { [weak self] in
            self?.urlOpener.openIfPossible(Constants.API.govukBaseUrl)
        }
    }
}

extension TopicDetailViewModel {
    struct Actions {
        let topicAction: (DisplayableTopic) -> Void
        let subtopicAction: (DisplayableTopic) -> Void
        let stepByStepAction: ([TopicDetailResponse.Content]) -> Void
        let openAction: (URL) -> Void
    }
}
