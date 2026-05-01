import UIKit
import Foundation
import GovKit

final class SARSettingsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface) {
        self.analyticsService = analyticsService
        self.userService = userService
        super.init(navigationController: navigationController)
    }
}
