import Foundation
import  CoreData
import GovKit

@testable import govuk_ios

class MockActivityService: ActivityServiceInterface {
    private let managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }

    var fetchRequest:
    NSFetchRequest<NSFetchRequestResult> = ActivityItem.homepagefetchRequest()

    internal lazy var activitiesFetchResultsController:
    NSFetchedResultsController<NSFetchRequestResult> = {
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return controller
    }()

    var _receivedSaveActivity: ActivityItemCreateParams?
    func save(activity: ActivityItemCreateParams) {
        _receivedSaveActivity = activity
    }

    var _stubbedFetchResultsController: NSFetchedResultsController<ActivityItem>!
    func fetch() -> NSFetchedResultsController<ActivityItem> {
        _stubbedFetchResultsController
    }

    var _receivedDeleteObjectIds: [NSManagedObjectID]?
    func delete(objectIds: [NSManagedObjectID]) {
        _receivedDeleteObjectIds = objectIds
    }

    var _receivedDeleteAll: Bool = false
    func deleteAll() {
        _receivedDeleteAll = true
    }

    func activityItem(for objectId: NSManagedObjectID) throws -> ActivityItem? {
        try _stubbedFetchResultsController
            .managedObjectContext
            .existingObject(with: objectId) as? ActivityItem
    }
}
