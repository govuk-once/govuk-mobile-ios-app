import UIKit
import Foundation

extension UITabBarItem {
    static var home: UITabBarItem {
        .init(
            title: String.home.localized("pageTitle"),
            image: UIImage(systemName: "house.fill"),
            selectedImage: nil
        )
    }

    static var settings: UITabBarItem {
        .init(
            title: String.settings.localized("pageTitle"),
            image: UIImage(systemName: "gearshape.fill"),
            selectedImage: nil
        )
    }

    static var chat: UITabBarItem {
        .init(
            title: String.chat.localized("tabTitle"),
            image: UIImage(named: "chat_tabbar_unselected"),
            selectedImage: UIImage(named: "chat_tabbar_selected")
        )
    }
}
