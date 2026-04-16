import CoreData
import UIKit
import Foundation

class CoreDataRepository: CoreDataRepositoryInterface {
    private let persistentContainer: NSPersistentContainer
    private let notificationCenter: NotificationCenter
    private var isLoaded = false
    private var loadingTask: Task<Void, Error>?

    init(persistentContainer: NSPersistentContainer,
         notificationCenter: NotificationCenter) {
        self.persistentContainer = persistentContainer
        self.notificationCenter = notificationCenter
    }

    func load() async throws {
        // prevents the database being attatched twice
        if let task = loadingTask {
           try await task.value
            return
        }
        let task = Task<Void, Error> {
            do {
                if await !UIApplication.shared.isProtectedDataAvailable {
                    _ = await NotificationCenter.default.notifications(
                        named: UIApplication.protectedDataDidBecomeAvailableNotification
                    ).first { _ in true }
                }
                try await initiliseStack()
            } catch {
                self.loadingTask = nil
                throw error
            }
        }
        loadingTask = task
        try await task.value
    }

    private func initiliseStack() async throws {
        persistentContainer.persistentStoreDescriptions.forEach { [weak self] in
            self?.setDescriptionProtection(description: $0)
            $0.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
            $0.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        }
        await withCheckedContinuation { continuation in
            persistentContainer.loadPersistentStores { [weak self] description, error in
                if let error = error {
                    fatalError("Error loading load persistent stores: \(error)")
                }
                self?.excludeStoreFromiTunesBackup(url: description.url)

                continuation.resume()
            }
        }
        addBackgroundObserver()
        addViewObserver()
    }

    private func setDescriptionProtection(description: NSPersistentStoreDescription) {
        description.setOption(
            FileProtectionType.complete as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )
    }

    private func excludeStoreFromiTunesBackup(url: URL?) {
        guard var url = url else { return }
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try? url.setResourceValues(resourceValues)
    }

    private(set) lazy var viewContext: NSManagedObjectContext = {
        let local = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType
        )
        local.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        local.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return local
    }()

    private(set) lazy var backgroundContext: NSManagedObjectContext = {
        let local = NSManagedObjectContext(
            concurrencyType: .privateQueueConcurrencyType
        )
        local.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        local.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return local
    }()

    private func addViewObserver() {
        notificationCenter.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: viewContext,
            queue: .main,
            using: { [weak self] notification in
                self?.backgroundContext.mergeChanges(fromContextDidSave: notification)
            }
        )
    }

    private func addBackgroundObserver() {
        notificationCenter.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: backgroundContext,
            queue: .main,
            using: { [weak self] notification in
                self?.viewContext.mergeChanges(fromContextDidSave: notification)
            }
        )
    }
}

public protocol CoreDataRepositoryInterface {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }

    func load() async throws
}
