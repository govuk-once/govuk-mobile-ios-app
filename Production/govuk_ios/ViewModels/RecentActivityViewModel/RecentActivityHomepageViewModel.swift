import Foundation
import CoreData
import GovKitUI
import GovKit

class RecentActivityHomepageWidgetViewModel: NSObject,
                                             ObservableObject,
                                             NSFetchedResultsControllerDelegate {
    @Published private(set) var sections = [GroupedListSection]()
    private let activityService: ActivityServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let lastVisitedFormatter = DateFormatter.recentActivityLastVisited
    let seeAllAction: () -> Void
    let openURLAction: (URL) -> Void

    init(analyticsService: AnalyticsServiceInterface,
         activityService: ActivityServiceInterface,
         seeAllAction: @escaping () -> Void,
         openURLAction: @escaping (URL) -> Void) {
        self.analyticsService = analyticsService
        self.activityService = activityService
        self.seeAllAction = seeAllAction
        self.openURLAction = openURLAction
        super.init()
        self.setupFetchResultsController()
    }

    let title: String = String.recentActivity.localized(
        "recentActivityNavigationTitle"
    )
    let emptyActivityStateTitle: String = String.recentActivity.localized(
        "emptyActivityStateTitle"
    )
    let seeAllButtonTitle: String = String.recentActivity.localized(
        "recentActivitySeeAllButtonTitle"
    )

//    private func setupFetchResultsController() {
//        try? activityService.activitiesFetchResultsController.performFetch()
//        let activities = activityService.activitiesFetchResultsController.fetchedObjects ?? []
//        let mappedActivities = activities.compactMap { $0 as? ActivityItem }
//        sections = createSections(activities: mappedActivities )
//    }

    private func createSections(activities: [ActivityItem]) -> [GroupedListSection] {
        guard activities.count > 0 else {
            return []
        }

        return [
            GroupedListSection(
                heading: nil,
                rows: activities
                    .prefix(activityService.fetchRequest.fetchLimit).map { activity in
                        LinkRow(
                            id: UUID().uuidString,
                            title: activity.title,
                            body: lastVisitedString(activity: activity),
                            showLinkImage: false,
                            action: { [weak self] in
                                guard let url = URL(string: activity.url) else {
                                    return
                                }
                                self?.openURLAction(url)
                            }
                        )
                    },
                footer: nil)
        ]
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            let activities =  activityService.activitiesFetchResultsController.fetchedObjects ?? []
            let mappedActivities = activities.compactMap { $0 as? ActivityItem }
            sections = createSections(activities: mappedActivities)
        }

    private func lastVisitedString(activity: ActivityItem) -> String {
        let copy = String.recentActivity.localized(
            "recentActivityFormattedDateStringComponent"
        )
        let formattedDateString = lastVisitedFormatter.string(from: activity.date)
        return "\(copy) \(formattedDateString)"
    }
}
