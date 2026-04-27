import Foundation
import  CoreData
import GovKit

@testable import govuk_ios

class MockActivityService: ActivityServiceInterface {
    private static var sharedRepository: CoreDataRepository?

    static func setUp() async {
        if sharedRepository == nil {
            sharedRepository = await CoreDataRepository.arrangeAndLoad
        }
    }

    func returnContext() -> NSManagedObjectContext {
        guard let repository = Self.sharedRepository else {
            fatalError("MockActivityService.setup() was not called!")
        }
        return repository.viewContext
    }

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
