import Testing
import UIKit
import Testing

@testable import GovKitUI

@Suite
@MainActor
struct ChatColoursFillsTests {
    @Test
    func surfaceChatAction_light_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatAction

        #expect(result.lightMode == .white)
    }

    @Test
    func surfaceChatAction_dark_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatAction

        #expect(result.darkMode == .blueDarker50)
    }

    @Test
    func surfaceChatQuestion_light_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatQuestion

        #expect(result.lightMode == .white.withAlphaComponent(0.5))
    }

    @Test
    func surfaceChatQuestion_dark_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatQuestion

        #expect(result.darkMode == .blueDarker80.withAlphaComponent(0.5))
    }

    @Test
    func surfaceChatBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatBackground

        #expect(result.lightMode == .blueLighter90)
    }

    @Test
    func surfaceChatBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatBackground

        #expect(result.darkMode == .blueDarker80)
    }

    @Test
    func surfaceChatOnboardingListBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatOnboardingListBackground

        #expect(result.lightMode == .blueLighter90)
    }

    @Test
    func surfaceChatOnboardingListBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.Fills.surfaceChatOnboardingListBackground

        #expect(result.darkMode == .blueDarker70)
    }
}


extension UIColor {

    var lightMode: UIColor? {
        resolvedColor(with: .init(userInterfaceStyle: .light))
    }

    var darkMode: UIColor? {
        resolvedColor(with: .init(userInterfaceStyle: .dark))
    }

}
