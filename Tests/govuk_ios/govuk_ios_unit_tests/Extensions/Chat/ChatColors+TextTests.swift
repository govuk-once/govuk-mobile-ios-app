import Testing
import Foundation
import UIKit

@testable import GovKitUI

struct ChatColors_TextTests {
    @Test
    func chatTextArea_returnsExpectedResult() {
        let result = UIColor.govUK.Text.chatTextArea

        #expect(result.lightMode == .grey700)
        #expect(result.darkMode == .white)
    }
}
