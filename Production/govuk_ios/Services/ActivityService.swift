import Foundation
import CoreData

protocol ActivityServiceInterface {
    func fetch() -> NSFetchedResultsController<ActivityItem>
    func save(activity: ActivityItemCreateParams)
    func delete(objectIds: [NSManagedObjectID])
    func activityItem(for objectId: NSManagedObjectID) throws -> ActivityItem?
    var activitiesFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> { get }
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> { get }
}

class ActivityService: NSObject,
                       ActivityServiceInterface {
    private let repository: ActivityRepositoryInterface

    init(repository: ActivityRepositoryInterface) {
        self.repository = repository
    }

    func fetch() -> NSFetchedResultsController<ActivityItem> {
        repository.fetch()
    }

    func save(activity: ActivityItemCreateParams) {
        repository.save(params: activity)
    }

    var fetchRequest:
    NSFetchRequest<NSFetchRequestResult> = ActivityItem.homepagefetchRequest()

    lazy var activitiesFetchResultsController:
    NSFetchedResultsController<NSFetchRequestResult> = {
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.repository.returnContext(),
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return controller
    }()

    func delete(objectIds: [NSManagedObjectID]) {
        repository.delete(objectIds: objectIds)
    }

    func activityItem(for objectId: NSManagedObjectID) throws -> ActivityItem? {
        try repository.activityItem(for: objectId)
    }
}
