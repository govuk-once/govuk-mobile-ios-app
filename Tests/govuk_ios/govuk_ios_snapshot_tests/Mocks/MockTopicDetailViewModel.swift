import Foundation
import GovKit

@testable import govuk_ios

class MockTopicDetailViewModel: TopicDetailViewModelInterface {
    
    var title: String = ""
    var description: String? = nil
    var isLoaded: Bool = false
    var linkAccountCardViewModel: ServiceAccountLinkCardViewModel? = nil
    var sections: [GroupedListSection] = []
    var subtopicCards: [ListCardViewModel] = []
    var errorViewModel: AppErrorViewModel? = nil
    var commerceItems: [TopicCommerceItem] = []
    func trackScreen(screen: any TrackableScreen) {}
    func trackEcommerce() {}

    init(
        title: String = "",
        description: String? = nil,
        isLoaded: Bool = false,
        linkAccountCardViewModel: ServiceAccountLinkCardViewModel? = nil,
        sections: [GroupedListSection] = [],
        subtopicCards: [ListCardViewModel] = [],
        errorViewModel: AppErrorViewModel? = nil
    ) {
        self.title = title
        self.description = description
        self.isLoaded = isLoaded
        self.linkAccountCardViewModel = linkAccountCardViewModel
        self.sections = sections
        self.subtopicCards = subtopicCards
        self.errorViewModel = errorViewModel
    }

    static var arrangeStepByStep: MockTopicDetailViewModel {
         var rows = [LinkRow]()
         for i in 1...8 {
             rows.append(
                LinkRow(
                    id: UUID().uuidString,
                    title: "content_\(i)",
                    showLinkImage: false,
                    action: {}
                )
             )
         }
         let section = GroupedListSection(
            heading: nil,
            rows: rows,
            footer: nil
         )
        return .init(
            title: "Step-by-step guides",
            isLoaded: true,
            sections: [section]
        )
     }

     static var arrangeFetched: MockTopicDetailViewModel {
         let popularRow = LinkRow(id: "1", title: "content_1", showLinkImage: false, action: {})
         let popularSection = GroupedListSection(
            heading: GroupedListHeader(
                title: "Popular pages in this topic"
            ),
            rows: [popularRow],
            footer: nil)
         //step by step
         let stepByStepRows = [
            LinkRow(id: "2", title: "content_2", imageName: "step_by_step", showLinkImage: false, action: {}),
         ]
         let stepByStepSection = GroupedListSection(
            heading: GroupedListHeader(
                title: "Step-by-step guides"
            ),
            rows: stepByStepRows,
            footer: nil
         )
         //other content
         let otherRows = [
            LinkRow(id: "3", title: "content_3", showLinkImage: false, action: {}),
            LinkRow(id: "4", title: "content_4", showLinkImage: false, action: {}),
            LinkRow(id: "5", title: "content_5", showLinkImage: false, action: {})
         ]
         let otherSection = GroupedListSection(
            heading: GroupedListHeader(
                title: "Services and information"
            ),
            rows: otherRows,
            footer: nil
         )

         //sub topics
         let subtopicCards = [
            ListCardViewModel(title: "subtopic_title_1", action: {}),
            ListCardViewModel(title: "subtopic_title_2", action: {}),
            ListCardViewModel(title: "subtopic_title_3", action: {})
         ]

         return .init(
            title: "test_title",
            description: "test_description",
            isLoaded: true,
            sections: [popularSection, stepByStepSection, otherSection],
            subtopicCards: subtopicCards
         )
     }

    static var arrangeOnlySubtopics: MockTopicDetailViewModel {
        .init(
            title: "test_title",
            isLoaded: true,
            subtopicCards: [
                ListCardViewModel(title: "subtopic_title_1", action: {}),
                ListCardViewModel(title: "subtopic_title_2", action: {}),
                ListCardViewModel(title: "subtopic_title_3", action: {}),
                ListCardViewModel(title: "subtopic_title_4", action: {}),
                ListCardViewModel(title: "subtopic_title_5", action: {})
            ]
        )
    }

    static var arrangeManyStepBySteps: MockTopicDetailViewModel {
        let popularRow = LinkRow(id: "1", title: "content_1", showLinkImage: false, action: {})
        let popularSection = GroupedListSection(
           heading: GroupedListHeader(
               title: "Popular pages in this topic"
           ),
           rows: [popularRow],
           footer: nil)
        //step by step
        let stepByStepRows = [
           LinkRow(
            id: "2",
            title: "content_2",
            imageName: "step_by_step",
            showLinkImage: false,
            action: {}
           ),
           LinkRow(
            id: "6",
            title: "content_6",
            imageName: "step_by_step",
            showLinkImage: false,
            action: {}
           ),
           LinkRow(
            id: "7",
            title: "content_7",
            imageName: "step_by_step",
            showLinkImage: false,
            action: {}
           )
        ]
        let stepByStepSection = GroupedListSection(
           heading: GroupedListHeader(
               title: "Step-by-step guides",
               actionTitle: "See all"
           ),
           rows: stepByStepRows,
           footer: nil
        )
        //other content
        let otherRows = [
           LinkRow(id: "3", title: "content_3", showLinkImage: false, action: {}),
           LinkRow(id: "4", title: "content_4", showLinkImage: false, action: {}),
           LinkRow(id: "5", title: "content_5", showLinkImage: false, action: {})
        ]
        let otherSection = GroupedListSection(
           heading: GroupedListHeader(
               title: "Services and information"
           ),
           rows: otherRows,
           footer: nil
        )

        //sub topics
        let subtopicCards = [
           ListCardViewModel(title: "subtopic_title_1", action: {}),
           ListCardViewModel(title: "subtopic_title_2", action: {}),
           ListCardViewModel(title: "subtopic_title_3", action: {})
        ]

        return .init(
           title: "test_title",
           description: "test_description",
           isLoaded: true,
           sections: [popularSection, stepByStepSection, otherSection],
           subtopicCards: subtopicCards
        )
    }

    static var arrangeUnlinkedAccount: MockTopicDetailViewModel {
        let popularRow = LinkRow(id: "1", title: "content_1", showLinkImage: false, action: {})
        let popularSection = GroupedListSection(
           heading: GroupedListHeader(
               title: "Popular pages in this topic"
           ),
           rows: [popularRow],
           footer: nil)
        //step by step
        let stepByStepRows = [
           LinkRow(
            id: "2",
            title: "content_2",
            imageName: "step_by_step",
            showLinkImage: false,
            action: {}
           ),
           LinkRow(
            id: "7",
            title: "content_7",
            imageName: "step_by_step",
            showLinkImage: false,
            action: {}
           )
        ]
        let stepByStepSection = GroupedListSection(
           heading: GroupedListHeader(
               title: "Step-by-step guides",
               actionTitle: "See all"
           ),
           rows: stepByStepRows,
           footer: nil
        )
        let linkAccountCardViewModel = ServiceAccountLinkCardViewModel(
            title: "Add driver and vehicles account",
            subtitle: "Your tax, MOT, penalty points",
            action: {}
        )
        return .init(
            title: "test_title",
            description: "test_description",
            isLoaded: true,
            linkAccountCardViewModel: linkAccountCardViewModel,
            sections: [popularSection, stepByStepSection]
         )
    }
}
