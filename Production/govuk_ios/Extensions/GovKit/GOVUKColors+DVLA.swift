import Foundation
import UIKit
import GovKitUI

extension GOVUKColors.Fills {
    public static let registrationPlate: UIColor = {
        #colorLiteral(red: 1, green: 0.7843137255, blue: 0, alpha: 1)
    }()

    public static let cancelButtonBackground: UIColor = UIColor(
        light: #colorLiteral(red: 0.9414063096, green: 0.94140625, blue: 0.9414063096, alpha: 1),
        dark: #colorLiteral(red: 0.03922517225, green: 0.1529186666, blue: 0.2510053813, alpha: 1)
    )

    public static let stateLabelErrorBackgroundColor: UIColor = UIColor(
        light: .yellowTint80,
        dark: #colorLiteral(red: 0.03922517225, green: 0.1529186666, blue: 0.2510053813, alpha: 1)
    )

    public static let registrationFormBackgroundColor: UIColor = UIColor(
        light: GOVUKColors.fills.surfaceCardDefault,
        dark: #colorLiteral(red: 0.05878055841, green: 0.2196403742, blue: 0.360727191, alpha: 1)
    )
}

extension GOVUKColors.Text {
    public static let stateLabelErrorForegroundColor: UIColor = UIColor(
            light: UIColor.govUK.text.primary,
            dark: #colorLiteral(red: 0.9983258843, green: 0.8655689955, blue: 0.0169921387, alpha: 1)
        )
}
