import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
            return topViewController
        }
}
