import Foundation
import Testing

@testable import govuk_ios

struct UnsetLocalWasteWidgetViewModelTests {

    @Test
    func title_returnsCorrectValue() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let expected = String.localWaste.localized(
            "localWasteTitle"
        )
        #expect(sut.title == expected)
    }

    @Test
    func widgetTitle_returnsCorrectValue() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let expected = String.localWaste.localized(
            "unsetLocalWasteWidgetViewTitle"
        )
        #expect(sut.widgetTitle == expected)
    }

    @Test
    func widgetDescription_returnsCorrectValue() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let expected = String.localWaste.localized(
            "unsetLocalWasteWidgetViewDescription"
        )
        #expect(sut.widgetDescription == expected)
    }

    @Test
    func primaryButtonViewModel_returnsCorrectTitle() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let expected = String.localWaste.localized(
            "unsetLocalWasteWidgetViewPrimaryButton"
        )
        #expect(sut.primaryButtonViewModel.localisedTitle == expected)
    }

    @Test
    func primaryButtonViewModel_executesAction() {
        var executed = false
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {
                executed = true
            }
        )
        sut.primaryButtonViewModel.action()
        #expect(executed)
    }
}
