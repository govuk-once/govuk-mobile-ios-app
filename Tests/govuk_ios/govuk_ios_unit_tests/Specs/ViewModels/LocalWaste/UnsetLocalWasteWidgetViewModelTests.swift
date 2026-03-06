import Foundation
import Testing

@testable import govuk_ios

struct UnsetLocalWasteWidgetViewModelTests {

    @Test
    func title_returnsCorrectValue() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let title = String.localWaste.localized(
            "localWasteTitle"
        )
        #expect(sut.title == title)
    }

    @Test
    func widgetTitle_returnsCorrectValue() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let widgetTitle = String.localWaste.localized(
            "unsetLocalWasteWidgetViewTitle"
        )
        #expect(sut.widgetTitle == widgetTitle)
    }

    @Test
    func widgetDescription_returnsCorrectValue() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let widgetDescription = String.localWaste.localized(
            "unsetLocalWasteWidgetViewDescription"
        )
        #expect(sut.widgetDescription == widgetDescription)
    }

    @Test
    func primaryButtonViewModel_returnsCorrectTitle() throws {
        let sut = UnsetLocalWasteWidgetViewModel(
            primaryAction: {}
        )
        let primaryButton = String.localWaste.localized(
            "unsetLocalWasteWidgetViewPrimaryButton"
        )
        #expect(sut.primaryButtonViewModel.localisedTitle == primaryButton)
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
