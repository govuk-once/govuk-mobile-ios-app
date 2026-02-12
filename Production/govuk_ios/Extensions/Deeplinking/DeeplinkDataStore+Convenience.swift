import Foundation
import UIKit
import GovKit

extension DeeplinkDataStore {
    static func home(coordinatorBuilder: CoordinatorBuilder,
                     analyticsService: AnalyticsServiceInterface,
                     root: UIViewController) -> DeeplinkDataStore {
        DeeplinkDataStore(
            routes: [
                HomeDeeplinkRoute(coordinatorBuilder: coordinatorBuilder),
                WebDeeplinkRoute(coordinatorBuilder: coordinatorBuilder),
                SearchDeeplinkRoute(coordinatorBuilder: coordinatorBuilder),
                EditTopicsDeeplinkRoute(coordinatorBuilder: coordinatorBuilder),
                RecentActivityDeeplinkRoute(coordinatorBuilder: coordinatorBuilder),
                DVLAServiceDeeplinkRoute(
                    coordinatorBuilder: coordinatorBuilder,
                    analyticsService: analyticsService
                ),
                NotificationCentreDetailDeeplinkRoute(coordinatorBuilder: coordinatorBuilder)
            ],
            root: root
        )
    }

    static func settings(coordinatorBuilder: CoordinatorBuilder,
                         root: UIViewController) -> DeeplinkDataStore {
        DeeplinkDataStore(
            routes: [
                SettingsDeeplinkRoute(coordinatorBuilder: coordinatorBuilder)
            ],
            root: root
        )
    }

    static func chat(coordinatorBuilder: CoordinatorBuilder,
                     root: UIViewController) -> DeeplinkDataStore {
        DeeplinkDataStore(
            routes: [
                ChatDeeplinkRoute(coordinatorBuilder: coordinatorBuilder)
            ],
            root: root
        )
    }
}
