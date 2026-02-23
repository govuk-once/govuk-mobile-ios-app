import Testing
import Foundation
import UIKit

@testable import GovKitUI

struct ChatColors_textTests {
    @Test
    func chatTextArea_returnsExpectedResult() {
        let result = UIColor.govUK.text.chatTextArea

        #expect(result.lightMode == .grey700)
        #expect(result.darkMode == .white)
    }
}
