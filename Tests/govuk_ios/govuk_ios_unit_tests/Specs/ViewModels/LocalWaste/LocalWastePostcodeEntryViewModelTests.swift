//import Combine
import Foundation
import GovKit
import Testing
import UIKit

@testable import govuk_ios

@Suite
struct LocalWastePostcodeEntryViewModelTests {
    
    @Test
    func cancelButton_returnsCorrectValue() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let expected = String.common.localized(
            "cancel"
        )
        #expect(sut.cancelButton == expected)
    }

    @Test
    func viewTitle_returnsCorrectValue() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewTitle"
        )
        #expect(sut.viewTitle == expected)
    }

    @Test
    func exampleText_returnsCorrectValue() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewExampleText"
        )
        #expect(sut.exampleText == expected)
    }

    @Test
    func descriptionTitle_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewDescriptionTitle"
        )
        #expect(sut.descriptionTitle == expected)
    }

    @Test
    func descriptionBody_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewDescriptionBody"
        )
        #expect(sut.descriptionBody == expected)
    }

    @Test
    func entryFieldAccessibilityLabel_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewEntryAccessibilityLabel"
        )
        #expect(sut.entryFieldAccessibilityLabel == expected)
    }

    @Test
    func primaryButtonViewModel_returnsCorrectTitle() throws {
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )
        let expected = String.localWaste.localized(
            "localWastePostcodeEntryViewPrimaryButton"
        )
        #expect(sut.primaryButtonViewModel.localisedTitle == expected)
    }

    /*
    @Test
    func fetchLocalAuthority_addressList_returnsExpectedResults() async throws {
        let addresses:[LocalAuthorityAddress] = [
            LocalAuthorityAddress(
                address: "address1",
                slug: "slug1",
                name: "name1"
            ),
            LocalAuthorityAddress(
                address: "address2",
                slug: "slug2",
                name: "name2"
            )
        ]

        let authorities = [
            Authority(
                name: "name1",
                homepageUrl: "https://authority1",
                tier: "tier1",
                slug: "slug1"
            ),
            Authority(
                name: "name2",
                homepageUrl: "https://authority2",
                tier: "tier2",
                slug: "slug2"
            )
        ]

        let expectedAddressResponse = LocalAuthorityResponse(localAuthorityAddresses: addresses)
        let mockService = MockLocalAuthorityService()
        mockService._stubbedFetchLocalPostcodeResult = .success(expectedAddressResponse)
        mockService._stubbedLocalAuthoritiesResult = .success(authorities)

        var expectedAddresses = [LocalAuthorityAddress]()
        _ = await withCheckedContinuation { continuation in
            let sut = LocalWastePostcodeEntryViewModel(
                service: mockService,
                analyticsService: MockAnalyticsService(),
                resolveAmbiguityAction: { authorities, postCode in
                    expectedAddresses = authorities.addresses
                    continuation.resume()
                }, localAuthoritySelected: {_ in },
                dismissAction: {}
            )
            sut.postCode = "test"
            sut.primaryButtonViewModel.action()
        }
        #expect(expectedAddresses.count == addresses.count)
        #expect(expectedAddresses.first?.address == addresses.first?.address)
    }
     */

    @Test
    func returnErrorMessage_emptyString_returnsExpectedResult() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: mockAnalyticsService,
            dismissAction: {}
        )
        sut.primaryButtonViewModel.action()
        #expect(sut.error?.errorMessage == "Enter your postcode")
        #expect(sut.textFieldColour == UIColor.govUK.strokes.error)
        #expect(mockAnalyticsService._trackedEvents.count == 0)
    }

    /*
    @Test
    func returnErrorMessage_invalidPostcode_returnsExpectedResult() async throws {
        let mockService = MockLocalAuthorityService()
        mockService._stubbedFetchLocalPostcodeResult = .failure(.invalidPostcode)

        let sut = LocalWastePostcodeEntryViewModel(
            service: mockService,
            analyticsService: MockAnalyticsService(),
            resolveAmbiguityAction: { _, _ in },
            localAuthoritySelected: {_ in },
            dismissAction: {}
        )

        sut.postCode = "test"
        sut.primaryButtonViewModel.action()
        #expect(sut.error?.errorMessage == "Enter a postcode in the correct format")
    }


    @Test
    func returnErrorMessage_postcodeNotFound_returnsExpectedResult() async throws {
        let mockService = MockLocalAuthorityService()
        mockService._stubbedFetchLocalPostcodeResult = .failure(.unknownPostcode)

        let sut = LocalWastePostcodeEntryViewModel(
            service: mockService,
            analyticsService: MockAnalyticsService(),
            resolveAmbiguityAction: { _, _ in },
            localAuthoritySelected: {_ in},
            dismissAction: {}
        )
        sut.postCode = "test"
        sut.primaryButtonViewModel.action()
        #expect(sut.error?.errorMessage == "We could not find a council for this postcode. Check the postcode and try again.")
    }
*/
    @Test
    func primaryButtonViewModel_action_trackNavigationEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: mockAnalyticsService,
            dismissAction: {}
        )
        sut.postCode = "SW1A 0AA"
        sut.primaryButtonViewModel.action()
        let receivedTitle = mockAnalyticsService._trackedEvents.first?.params?["text"] as? String
        #expect(receivedTitle == "Find address")
    }

    @MainActor
    @Test
    func trackScreen_sendsEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWastePostcodeEntryViewModel(
            analyticsService: mockAnalyticsService,
            dismissAction: {}
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
}
