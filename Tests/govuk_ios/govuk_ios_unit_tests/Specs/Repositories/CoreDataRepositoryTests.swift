import Foundation
import CoreData
import Testing


@testable import govuk_ios

@Suite
@MainActor
struct CoreDataRepositoryTests {
    @Test
    func load_enablesDatabaseOperations() async throws {
        let sut = await CoreDataRepository.arrange

        #expect(sut.viewContext.concurrencyType == .mainQueueConcurrencyType)
    }

    @Test
    func load_addsViewContextObserver() async throws{
        let mockNotificationCenter = MockNotificationCenter()
        let sut = await CoreDataRepository.arrange(
            notificationCenter: mockNotificationCenter
        )
        try await sut.load()

        #expect(mockNotificationCenter._receivedObservers.count == 2)

        let containsContext = mockNotificationCenter._receivedObservers.contains(
            where: { tuple in
                (tuple.object as? NSObject) == sut.viewContext
            }
        )

        #expect(containsContext)
    }

    @Test
    func load_addsBackgroundContextObserver() async throws {
        let mockNotificationCenter = MockNotificationCenter()
        let sut = await CoreDataRepository.arrange(
            notificationCenter: mockNotificationCenter
        )

        try await sut.load()

        #expect(mockNotificationCenter._receivedObservers.count == 2)

        let containsContext = mockNotificationCenter._receivedObservers.contains(
            where: { tuple in
                (tuple.object as? NSObject) == sut.backgroundContext
            }
        )

        #expect(containsContext)
    }

    @Test
    func save_viewContext_mergesChanges() async throws {
        let sut = await CoreDataRepository.arrangeAndLoad

        let item = ActivityItem.arrange(
            context: sut.viewContext
        )

        try sut.viewContext.save()

        let expectedNewTitle = UUID().uuidString
        item.title = expectedNewTitle

        try sut.viewContext.save()

        let request = ActivityItem.fetchRequest()
        let items = try sut.backgroundContext.fetch(request)

        #expect(items.first?.title == expectedNewTitle)
    }

    @Test
    func save_backgroundContext_mergesChanges() async throws{
        let sut = await CoreDataRepository.arrangeAndLoad

        let item = ActivityItem.arrange(
            context: sut.backgroundContext
        )

        try sut.backgroundContext.save()

        let expectedTitle = UUID().uuidString
        item.title = expectedTitle

        try sut.backgroundContext.save()

        let request = ActivityItem.fetchRequest()
        let items = try sut.viewContext.fetch(request)

        #expect(items.first?.title == expectedTitle)
    }
}
