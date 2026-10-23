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
        
        #expect(resolved != nil)
    }

    // MARK: - Fills: Cancel Button Background
    @Test
    func cancelButtonBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.cancelButtonBackground
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight != nil)
    }

    @Test
    func cancelButtonBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.cancelButtonBackground
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark != nil)
    }

    // MARK: - Fills: State Label Error Background Color
    @Test
    func stateLabelErrorBackgroundColor_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.stateLabelErrorBackgroundColor
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight != nil)
    }

    @Test
    func stateLabelErrorBackgroundColor_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.stateLabelErrorBackgroundColor
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark != nil)
    }

    // MARK: - Fills: Registration Form Background Color
    @Test
    func registrationFormBackgroundColor_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.registrationFormBackgroundColor
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight != nil)
    }

    @Test
    func registrationFormBackgroundColor_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.registrationFormBackgroundColor
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark != nil)
    }

    // MARK: - Text: State Label Error Foreground Color
    @Test
    func stateLabelErrorForegroundColor_light_returnsExpectedResult() {
        let result = UIColor.govUK.text.stateLabelErrorForegroundColor
        let resolvedLight = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        
        #expect(resolvedLight != nil)
    }

    @Test
    func stateLabelErrorForegroundColor_dark_returnsExpectedResult() {
        let result = UIColor.govUK.text.stateLabelErrorForegroundColor
        let resolvedDark = result.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
        
        #expect(resolvedDark != nil)
    }
}
