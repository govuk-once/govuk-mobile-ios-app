import Foundation
import CoreData

@testable import govuk_ios

class MockCoreDataRepository: CoreDataRepositoryInterface {
    var _mockBackgroundContext: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext {
        return _mockBackgroundContext
    }

    var _mockViewContext: NSManagedObjectContext
    var viewContext: NSManagedObjectContext {
        _mockViewContext
    }

    var _stubbedLoadCalled = false
    func load() async throws {
        _stubbedLoadCalled = true
    }

    init(entities: [NSEntityDescription] = [], storeType: String = NSSQLiteStoreType) {
        self.storeType = storeType
        let tempDir = NSTemporaryDirectory()
        let uuid = UUID().uuidString
        let tempStoreURL = URL(fileURLWithPath: tempDir).appendingPathComponent(
            "TestStore_\(uuid).sqlite"
        )
        self.storeURL = tempStoreURL
        let managedObjectModel = NSManagedObjectModel()
        managedObjectModel.entities = entities
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStore(
                ofType: storeType,
                configurationName: nil,
                at: tempStoreURL,
                options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                NSInferMappingModelAutomaticallyOption: true]
            )
        } catch {
            fatalError("Failed to add persistent store: \(error)")
        }

        _mockViewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _mockViewContext.persistentStoreCoordinator = persistentStoreCoordinator

        _mockBackgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _mockBackgroundContext.persistentStoreCoordinator = persistentStoreCoordinator
    }

    private var storeURL: URL?
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator
    private let storeType: String

    deinit {
        guard let storeURL = self.storeURL else { return }
        try? persistentStoreCoordinator.destroyPersistentStore(
            at: storeURL,
            type: NSPersistentStore.StoreType(rawValue: storeType))
        try? FileManager.default.removeItem(at: storeURL)
        var nextFilePath = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        try? FileManager.default.removeItem(at: nextFilePath)
        nextFilePath = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        try? FileManager.default.removeItem(at: nextFilePath)
    }
}
