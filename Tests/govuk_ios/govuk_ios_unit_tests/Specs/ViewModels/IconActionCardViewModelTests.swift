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

    @Test
    func accessibilityLabel_includesTitleAndDescription_whenBothPresent() {
        let sut = IconActionCardViewModel(
            iconName: "plus.circle",
            title: "Title",
            description: "Description",
            action: {}
        )

        #expect(sut.accessibilityLabel == "Title, Description")
    }

    @Test
    func accessibilityLabel_includesOnlyDescription_whenTitleIsNil() {
        let sut = IconActionCardViewModel(
            iconName: "plus.circle",
            title: nil,
            description: "Description",
            action: {}
        )

        #expect(sut.accessibilityLabel == "Description")
    }

    @Test
    func accessibilityLabel_isEmpty_whenTitleAndDescriptionAreNil() {
        let sut = IconActionCardViewModel(
            iconName: "plus.circle",
            title: nil,
            description: nil,
            action: {}
        )

        #expect(sut.accessibilityLabel == "")
    }
}
