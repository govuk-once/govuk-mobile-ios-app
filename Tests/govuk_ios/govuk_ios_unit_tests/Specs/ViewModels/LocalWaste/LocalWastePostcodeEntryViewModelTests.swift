import Foundation
import Testing
import UIKit

@testable import govuk_ios

@MainActor
@Suite
struct LocalWastePostcodeEntryViewModelTests {
    
    @Test
    func cancelButton_returnsCorrectValue() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.common.localized(
            "cancel"
        )
        #expect(sut.cancelButton == expected)
    }

    @Test
    func viewTitle_returnsCorrectValue() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewTitle"
        )
        #expect(sut.viewTitle == expected)
    }

    @Test
    func exampleText_returnsCorrectValue() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewExampleText"
        )
        #expect(sut.exampleText == expected)
    }

    @Test
    func descriptionTitle_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewDescriptionTitle"
        )
        #expect(sut.descriptionTitle == expected)
    }

    @Test
    func descriptionBody_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewDescriptionBody"
        )
        #expect(sut.descriptionBody == expected)
    }

    @Test
    func loadingAccessibilityLabel_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewLoadingAccessibilityLabel"
        )
        #expect(sut.loadingAccessibilityLabel == expected)
    }

    @Test
    func entryFieldAccessibilityLabel_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewEntryAccessibilityLabel"
        )
        #expect(sut.entryFieldAccessibilityLabel == expected)
    }

    @Test
    func primaryButton_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewPrimaryButton"
        )
        #expect(sut.primaryButton == expected)
    }

    @Test
    func fetchAddresses_emptyPostcode_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddresses = []
        var actualAddresses: [LocalWasteAddress]? = nil
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = ""
        await sut.fetchAddresses()
        #expect(sut.error == .textFieldEmpty)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }
 
    @Test
    func postcodeChanged_errorCleared() async throws {
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        sut.postcode = ""
        await sut.fetchAddresses()
        #expect(sut.error != nil)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)

        sut.postcode = "B"
        #expect(sut.error == nil)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.listDivider)
    }

    @Test
    func fetchAddresses_serviceThrowsPostcodeNotFound_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .apiError(.postcodeNotFound)
        var actualAddresses: [LocalWasteAddress]? = nil
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "ABC 123"
        await sut.fetchAddresses()
        #expect(sut.error == .pageNotWorking)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }

    @Test
    func fetchAddresses_serviceThrowsInvalidPostcode_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .apiError(.invalidPostcode)
        var actualAddresses: [LocalWasteAddress]? = nil

        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "ABC 123"
        await sut.fetchAddresses()
        #expect(sut.error == .pageNotWorking)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }

    @Test
    func fetchAddresses_serviceThrowsCouncilNotSupported_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .apiError(.councilNotSupported)
        var actualAddresses: [LocalWasteAddress]? = nil

        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "ABC 123"
        await sut.fetchAddresses()
        #expect(sut.error == .pageNotWorking)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }

    @Test
    func fetchAddresses_serviceThrowsUnknownError_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .apiError(.unknownError)
        var actualAddresses: [LocalWasteAddress]? = nil

        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "ABC 123"
        await sut.fetchAddresses()
        #expect(sut.error == .pageNotWorking)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }

    @Test
    func fetchAddresses_serviceThrowsApiUnavailable_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .apiUnavailable
        var actualAddresses: [LocalWasteAddress]? = nil
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "ABC 123"
        await sut.fetchAddresses()
        #expect(sut.error == .pageNotWorking)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }
    
    @Test
    func fetchAddresses_serviceThrowsDecodingError_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .decodingError
        var actualAddresses: [LocalWasteAddress]? = nil
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "ABC 123"
        await sut.fetchAddresses()
        #expect(sut.error == .pageNotWorking)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }

    @Test
    func fetchAddresses_serviceThrowsNetworkUnavailable_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .networkUnavailable
        var actualAddresses: [LocalWasteAddress]? = nil
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "ABC 123"
        await sut.fetchAddresses()
        #expect(sut.error == .pageNotWorking)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }

    @Test
    func fetchAddresses_serviceReturnsEmptyArray_showError() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddresses = []
        var actualAddresses: [LocalWasteAddress]? = nil
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "SW1A 0AA"
        await sut.fetchAddresses()
        #expect(sut.error == .textFieldEmpty)
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(actualAddresses == nil)
    }

    @Test
    func fetchAddresses_serviceThrows_isLoading() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._errorFetchAddresses = .networkUnavailable

        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        sut.postcode = "SW1A 0AA"
        mockLocalWasteService._fetchAddressesPreCall = {
            #expect(sut.isLoading == true)
        }

        #expect(sut.isLoading == false)

        await sut.fetchAddresses()

        #expect(sut.isLoading == false)
    }

    @Test
    func fetchAddresses_sanitisedPostcodeIsSent() async throws {
        let expectedAddresses: [LocalWasteAddress] = [
            .init(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1")
        ]
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddresses = expectedAddresses
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        sut.postcode = "sw1a 0aa"
        await sut.fetchAddresses()
        #expect(mockLocalWasteService._postcodeFetchAddresses == "SW1A0AA")
    }

    @Test
    func fetchAddresses_serviceReturnsNonEmptyArray_callDoneAction() async throws {
        let expectedAddresses: [LocalWasteAddress] = [
            .init(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1")
        ]
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddresses = expectedAddresses
        var actualAddresses: [LocalWasteAddress]? = nil
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { receivedAddresses in
                actualAddresses = receivedAddresses
            }
        )
        sut.postcode = "SW1A 0AA"
        await sut.fetchAddresses()
        #expect(actualAddresses == expectedAddresses)
    }

    @Test
    func fetchAddresses_serviceReturnsNonEmptyArray_isLoading() async throws {
        let expectedAddresses: [LocalWasteAddress] = [
            .init(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1")
        ]
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddresses = expectedAddresses
        
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: MockAnalyticsService(),
            dismissAction: {},
            doneAction: { _ in }
        )
        sut.postcode = "SW1A 0AA"
        mockLocalWasteService._fetchAddressesPreCall = {
            #expect(sut.isLoading == true)
        }

        #expect(sut.isLoading == false)

        await sut.fetchAddresses()

        #expect(sut.isLoading == false)
    }

    @Test
    func fetchAddresses_trackNavigationEvent() async throws {
        let mockLocalWasteService = MockLocalWasteService()
        mockLocalWasteService._dataFetchAddresses = [
            .init(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1")
        ]
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWastePostcodeEntryViewModel(
            service: mockLocalWasteService,
            analyticsService: mockAnalyticsService,
            dismissAction: {},
            doneAction: { _ in }
        )
        sut.postcode = "SW1A 0AA"
        await sut.fetchAddresses()
        let receivedTitle = mockAnalyticsService._trackedEvents.first?.params?["text"] as? String
        #expect(receivedTitle == "Find address")
    }

    @Test
    func trackScreen_sendsEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWastePostcodeEntryViewModel(
            service: MockLocalWasteService(),
            analyticsService: mockAnalyticsService,
            dismissAction: {},
            doneAction: { _ in }
        )
        let view = LocalWastePostcodeEntryView(viewModel: sut)
        sut.trackScreen(screen: view)
        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingName == view.trackingName)
        #expect(screens.first?.trackingTitle == view.trackingTitle)
    }

    @Test
    func postcodeError_textFieldEmpty_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel.PostcodeError.textFieldEmpty
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewEmptyPostcode"
        )
        #expect(sut.errorMessage == expected)
    }

    @Test
    func postcodeError_pageNotWorking_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel.PostcodeError.pageNotWorking
        let expected = String.localWaste.localized(
            "localWastePageNotWorking"
        )
        #expect(sut.errorMessage == expected)
    }
}
