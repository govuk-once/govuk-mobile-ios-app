import Foundation
import UIKit
import GovKitUI

extension GOVUKColors.Fills {
    public static let registrationPlate: UIColor = {
        #colorLiteral(red: 1, green: 0.7843137255, blue: 0, alpha: 1)
    }()

    public static let cancelButtonBackground: UIColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return #colorLiteral(red: 0.03922517225, green: 0.1529186666, blue: 0.2510053813, alpha: 1)
            default:
                return #colorLiteral(red: 0.9414063096, green: 0.94140625, blue: 0.9414063096, alpha: 1)
            }
        }
}
