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

        #expect(result.lightMode == .blueLighter80)
        #expect(result.darkMode == .blueDarker25)
    }

    @Test
    func chatAnswer_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.chatAnswer

        #expect(result.lightMode == .clear)
        #expect(result.darkMode == .blueDarker25)
    }

    @Test
    func chatAction_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.chatAction

        #expect(result.lightMode == .grey300)
        #expect(result.darkMode == .blueLighter25)
    }

    @Test
    func chatOnboardingListDivider_returnsExpectedResult() {
        let result = UIColor.govUK.strokes.chatOnboardingListDivider

        #expect(result.lightMode == .blueLighter80)
        #expect(result.darkMode == .blueDarker50)
    }
}
