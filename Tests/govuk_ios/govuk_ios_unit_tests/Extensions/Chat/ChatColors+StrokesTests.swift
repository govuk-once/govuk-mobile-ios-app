import Foundation
import Testing
import UIKit

@testable import GovKitUI

struct ChatColors_strokesTests {
    @Test
    func focusedChatTextBox_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.focusedChatTextBox

        #expect(result.lightMode == .primaryBlue)
        #expect(result.darkMode == .accentBlue)
    }

    @Test
    func chatDivider_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.chatDivider

        #expect(result.lightMode == .blueTint80)
        #expect(result.darkMode == .blueShade25)
    }

    @Test
    func chatAnswer_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.chatAnswer

        #expect(result.lightMode == .clear)
        #expect(result.darkMode == .blueShade25)
    }

    @Test
    func chatAction_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.chatAction

        #expect(result.lightMode == .grey300)
        #expect(result.darkMode == .blueTint25)
    }

    @Test
    func chatOnboardingListDivider_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.chatOnboardingListDivider

        #expect(result.lightMode == .blueTint80)
        #expect(result.darkMode == .blueShade50)
    }
}
