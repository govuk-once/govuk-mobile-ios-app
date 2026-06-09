import Foundation
import Testing
import CoreData

@testable import govuk_ios

struct ChatRespositoryTests {

    @Test
    func save_chatItem_savesConversationId() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let sut = ChatRepository(coreData: coreData)
        let expectedConversationId = "conversation_id"

        sut.saveConversation(expectedConversationId)

        let context = coreData.backgroundContext
        context.performAndWait {
            let fetchRequest = ChatItem.fetchRequest()
            let results = (try? context.fetch(fetchRequest)) ?? []
            #expect(results.count == 1)
            #expect(results.first?.conversationId == expectedConversationId)
        }
    }

    @Test
    func save_chatItem_savesOnlyOneConversationId() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let sut = ChatRepository(coreData: coreData)
        let expectedConversationId = "conversation_id"
        let secondExpectedConversationId = "second_conversation_id"

        sut.saveConversation(expectedConversationId)
        sut.saveConversation(secondExpectedConversationId)

        let context = coreData.backgroundContext
        context.performAndWait {
            let fetchRequest = ChatItem.fetchRequest()
            let  results = (try? context.fetch(fetchRequest)) ?? []
            #expect(results.count == 1)
            #expect(results.first?.conversationId == secondExpectedConversationId)
        }
    }

    @Test
    func save_chatItem_savesNilConversationId() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let sut = ChatRepository(coreData: coreData)

        sut.saveConversation(nil)

        let context = coreData.backgroundContext
        context.performAndWait {
            let fetchRequest = ChatItem.fetchRequest()
            let results = (try? context.fetch(fetchRequest)) ?? []
            #expect(results.count == 1)
            #expect(results.first?.conversationId == nil)
        }
    }

    @Test
    func fetchConversation_fetchesExpectedItem() async throws {
        let coreData = await CoreDataRepository.arrangeAndLoad
        let sut = ChatRepository(coreData: coreData)
        let expectedConversationId = "conversation_id"

        let context = coreData.backgroundContext
        let chatItem = ChatItem(context: context)
        chatItem.conversationId = expectedConversationId
        context.performAndWait {
            try? context.save()
        }

        let conversationId = sut.fetchConversation()
        #expect(conversationId == expectedConversationId)
    }
}
