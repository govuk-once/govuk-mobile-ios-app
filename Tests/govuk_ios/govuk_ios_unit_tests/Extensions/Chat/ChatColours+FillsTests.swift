import Testing
import UIKit
import Testing

@testable import GovKitUI

@Suite
@MainActor
struct ChatColoursFillsTests {

    @Test
    func surfaceChatBlue_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatBlue

        #expect(result.lightMode == .white)
    }

    @Test
    func surfaceChatBlue_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatBlue

        #expect(result.darkMode == .blueDarker80)
    }

    @Test
    func surfaceChatAction_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatAction

        #expect(result.lightMode == .white)
    }

    @Test
    func surfaceChatAction_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatAction

        #expect(result.darkMode == .blueDarker50)
    }

    @Test
    func surfaceChatQuestion_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatQuestion

        #expect(result.lightMode == .white.withAlphaComponent(0.5))
    }

    @Test
    func surfaceChatQuestion_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatQuestion

        #expect(result.darkMode == .blueDarker80.withAlphaComponent(0.5))
    }

    @Test
    func surfaceChatBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatBackground

        #expect(result.lightMode == .blueLighter90)
    }

    @Test
    func surfaceChatBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatBackground

        #expect(result.darkMode == .blueDarker80)
    }

    @Test
    func surfaceChatOnboardingListBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatOnboardingListBackground

        #expect(result.lightMode == .blueLighter90)
    }

    @Test
    func surfaceChatOnboardingListBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatOnboardingListBackground

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
