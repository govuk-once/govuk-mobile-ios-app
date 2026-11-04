import Foundation
import UIKit
import GovKit

final class CategoriesListCoordinator: BaseCoordinator {
    init(
        navigationController: UINavigationController,
        viewControllerBuilder: ViewControllerBuilder,
        analyticsService: AnalyticsServiceInterface,
        dvlaService: DVLAServiceInterface,
        configService: AppConfigServiceInterface,
        userService: UserServiceInterface,
        urlOpener: URLOpener,
        notificationCenter: NotificationCenter,
    ) {
        super.init(navigationController: navigationController)
    }
}
