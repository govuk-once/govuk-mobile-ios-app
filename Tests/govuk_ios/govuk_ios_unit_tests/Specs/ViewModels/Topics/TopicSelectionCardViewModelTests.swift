import Testing
import SwiftUI

@testable import govuk_ios

@Suite
class TopicSelectionCardViewModelTests {
    var coreData: CoreDataRepository!

    init() {
        Task {
            self.coreData = await CoreDataRepository.arrangeAndLoad
        }
    }

    @Test
    func isOn_update_callsTapAction() async {
        await confirmation() { confirmation in
            let topic = Topic(context: coreData.backgroundContext)
            let sut = TopicSelectionCardViewModel(
                topic: topic,
                tapAction: { _ in confirmation() }
            )
            sut.isOn.toggle()
        }
    }

    @Test
    func title_returnsTitle() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.title = "Test title"
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.title == "Test title")
    }

    @Test
    func iconName_returnsCorrectIconName() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.ref = "business"
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.iconName == "business")
    }

    @Test
    func iconName_favourite_returnsCorrectIconName() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.ref = "business"
        topic.isFavourite = true
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.iconName == "topic_selected")
    }

    @Test
    func backgroundColor_returnsCorrectColor() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.isFavourite = false
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.backgroundColor == .govUK.fills.surfaceListUnselected)
    }

    @Test
    func backgroundColor_favourite_returnsCorrectColor() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.isFavourite = true
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.backgroundColor == .govUK.fills.surfaceListSelected)
    }

    @Test
    func titleColor_returnsCorrectColor() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.isFavourite = false
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.titleColor == .govUK.text.listUnselected)
    }

    @Test
    func titleColor_favourite_returnsCorrectColor() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.isFavourite = true
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.titleColor == .govUK.text.listSelected)
    }

    @Test
    func accessibilityHint_returnsCorrectHint() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.isFavourite = false
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.accessibilitySelectedState == "Unselected")
    }

    @Test
    func accessibilityHint_favourite_returnsCorrectHint() {
        let topic = Topic(context: coreData.backgroundContext)
        topic.isFavourite = true
        let sut = TopicSelectionCardViewModel(
            topic: topic,
            tapAction: { _ in }
        )
        #expect(sut.accessibilitySelectedState == "Selected")
    }
}
