import Foundation
import CoreData

protocol ActivityServiceInterface {
    func fetch() -> NSFetchedResultsController<ActivityItem>
    func save(activity: ActivityItemCreateParams)
    func delete(objectIds: [NSManagedObjectID])
    func activityItem(for objectId: NSManagedObjectID) throws -> ActivityItem?
  //  var activitiesFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> { get }
   // var fetchRequest: NSFetchRequest<NSFetchRequestResult> { get }
}

class ActivityService: NSObject,
                       ActivityServiceInterface,
                       NSFetchedResultsControllerDelegate {
    private let repository: ActivityRepositoryInterface
    private var retainedResultsController: NSFetchedResultsController<ActivityItem>?

    init(repository: ActivityRepositoryInterface) {
        self.repository = repository
    }

    func fetch() {
        retainedResultsController = repository.fetch()
        // takes a fetch and rreturns a NSFetchedResultsController base
        // give the repositrory the fetch request then
        /// then it will return the controller it needes
        /// then the context only gets exposes in the repository 
    }

//    private func setupFetchResultsController() {
//        try? repository.activitiesFetchResultsController.performFetch()
//        let activities = repository.activitiesFetchResultsController.fetchedObjects ?? []
//        let mappedActivities = activities.compactMap { $0 as? ActivityItem }
//        sections = createSections(activities: mappedActivities )
//    }


    func save(activity: ActivityItemCreateParams) {
        repository.save(params: activity)
    }

    var fetchRequest:
    NSFetchRequest<NSFetchRequestResult> = ActivityItem.homepagefetchRequest()

//    internal lazy var activitiesFetchResultsController:
//    NSFetchedResultsController<NSFetchRequestResult> = {
//        let controller = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: self.repository.returnContext(),
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        controller.delegate = self
//        return controller
//    }()

    // repo should return the fetch ocntrolle

    func delete(objectIds: [NSManagedObjectID]) {
        repository.delete(objectIds: objectIds)
    }

    func activityItem(for objectId: NSManagedObjectID) throws -> ActivityItem? {
        try repository.activityItem(for: objectId)
    }
}
