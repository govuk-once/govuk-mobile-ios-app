import Testing
import UIKit

@testable import govuk_ios
@testable import GovKit
@testable import GovKitUI

struct IconActionCardViewModelTests {

    @Test
    func init_setsAllProperties() {
        let sut = IconActionCardViewModel(
            iconName: "plus.circle",
            title: "Add local authority",
            description: "Set your local authority to personalise content",
            action: {}
        )

        #expect(sut.iconName == "plus.circle")
        #expect(sut.title == "Add local authority")
        #expect(sut.description == "Set your local authority to personalise content")
    }

    @Test
    func action_callsCompletion() {
        var didCallAction = false

        let sut = IconActionCardViewModel(
            iconName: "plus.circle",
            title: "Title",
            description: "Description",
            action: {
                didCallAction = true
            }
        )

        sut.action()

        #expect(didCallAction)
    }
}
