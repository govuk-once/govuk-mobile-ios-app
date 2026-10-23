import Foundation
import UIKit
import Testing

@testable import GovKitUI

@Suite
@MainActor
struct GOVUKColors_DVLA {

    // MARK: - Fills: Registration Plate
    @Test
    func registrationPlate_returnsExpectedColor() {
        let result = UIColor.govUK.fills.registrationPlate
        let resolved = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolved == #colorLiteral(red: 1, green: 0.7843137255, blue: 0, alpha: 1))
    }

    // MARK: - Fills: Cancel Button Background
    @Test
    func cancelButtonBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.cancelButtonBackground
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight == #colorLiteral(red: 0.9414063096, green: 0.94140625, blue: 0.9414063096, alpha: 1))
    }

    @Test
    func cancelButtonBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.cancelButtonBackground
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark != #colorLiteral(red: 0.03922517225, green: 0.1529186666, blue: 0.2510053813, alpha: 1))
    }

    // MARK: - Fills: State Label Error Background Color
    @Test
    func stateLabelErrorBackgroundColor_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.stateLabelErrorBackgroundColor
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight == #colorLiteral(red: 0.03922517225, green: 0.1529186666, blue: 0.2510053813, alpha: 1))
    }

    @Test
    func stateLabelErrorBackgroundColor_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.stateLabelErrorBackgroundColor
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark == #colorLiteral(red: 0.03922517225, green: 0.1529186666, blue: 0.2510053813, alpha: 1))
    }

    // MARK: - Fills: Registration Form Background Color
    @Test
    func registrationFormBackgroundColor_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.registrationFormBackgroundColor
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight == GOVUKColors.fills.surfaceCardDefault)
    }

    @Test
    func registrationFormBackgroundColor_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.registrationFormBackgroundColor
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark == #colorLiteral(red: 0.05878055841, green: 0.2196403742, blue: 0.360727191, alpha: 1))
    }

    // MARK: - Text: State Label Error Foreground Color
    @Test
    func stateLabelErrorForegroundColor_light_returnsExpectedResult() {
        let result = UIColor.govUK.text.stateLabelErrorForegroundColor
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight == UIColor.govUK.text.primary.lightMode)
    }

    @Test
    func stateLabelErrorForegroundColor_dark_returnsExpectedResult() {
        let result = UIColor.govUK.text.stateLabelErrorForegroundColor
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark == #colorLiteral(red: 0.9983258843, green: 0.8655689955, blue: 0.0169921387, alpha: 1))
    }
}
