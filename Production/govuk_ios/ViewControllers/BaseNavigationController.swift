import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    private let statusBarStyle: UIStatusBarStyle
    init(statusBarStyle: UIStatusBarStyle) {
        self.statusBarStyle = statusBarStyle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
}
