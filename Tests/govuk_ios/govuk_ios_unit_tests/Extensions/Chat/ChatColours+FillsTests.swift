import Foundation
import UIKit
import Testing

@testable import GovKitUI

@Suite
@MainActor
struct ChatColours_fillsTests {
    @Test
    func surfaceChatAnswer_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatAnswer

        #expect(result.lightMode == .white)
    }

    @Test
    func surfaceChatAnswer_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatAnswer

        #expect(result.darkMode == .blueShade70)
    }

    @Test
    func surfaceChatAction_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatAction

        #expect(result.lightMode == .white)
    }

    @Test
    func surfaceChatAction_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatAction

        #expect(result.darkMode == .blueShade50)
    }

    @Test
    func surfaceChatQuestion_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatQuestion

        #expect(result.lightMode == .blueShade50)
    }

    @Test
    func surfaceChatQuestion_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatQuestion

        #expect(result.darkMode == .primaryBlue)
    }

    @Test
    func surfaceChatBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatBackground

        #expect(result.lightMode == .blueTint90)
    }

    @Test
    func surfaceChatBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatBackground

        #expect(result.darkMode == .blueShade80)
    }

    @Test
    func surfaceChatOnboardingListBackground_light_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatOnboardingListBackground

        #expect(result.lightMode == .blueTint90)
    }

    @Test
    func surfaceChatOnboardingListBackground_dark_returnsExpectedResult() {
        let result = UIColor.govUK.fills.surfaceChatOnboardingListBackground

        #expect(result.darkMode == .blueShade70)
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
