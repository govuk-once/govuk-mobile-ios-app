import Foundation
import CoreData
import FactoryKit

@testable import govuk_ios

extension CoreDataRepository {
    static var arrangeAndLoad: CoreDataRepository {
        get async {
            await arrange(shouldLoad: true)
        }
    }

    static var arrange: CoreDataRepository {
        get async {
            await arrange()
        }
    }

    static func arrange(notificationCenter: NotificationCenter = .default,
                        shouldLoad: Bool = false
    ) async -> CoreDataRepository {
        let container = NSPersistentContainer(
            name: "GOV",
            managedObjectModel: Container.shared.coreDataModel.resolve()
        )
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        let coredataRepository = CoreDataRepository(
            persistentContainer: container,
            notificationCenter: notificationCenter
        )
        if shouldLoad {
            try? await coredataRepository.load()
        }
        return coredataRepository
    }
    
}
