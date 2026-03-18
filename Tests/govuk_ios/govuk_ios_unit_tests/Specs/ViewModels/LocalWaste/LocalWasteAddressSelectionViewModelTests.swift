import Foundation
import Testing
import UIKit

@testable import govuk_ios

@MainActor
@Suite
struct LocalWasteAddressSelectionViewModelTests {
    
    @Test
    func cancelButton_returnsCorrectValue() throws {
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: {},
            doneAction: {}
        )
        let expected = String.common.localized(
            "cancel"
        )
        #expect(sut.cancelButton == expected)
    }

    @Test
    func title_returnsCorrectValue() throws {
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: {},
            doneAction: {}
        )
        let expected = String.localWaste.localized(
            "localWasteAddressSelectionViewTitle"
        )
        #expect(sut.title == expected)
    }

    @Test
    func subtitle_returnsCorrectValue() throws {
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: {},
            doneAction: {}
        )
        let expected = String.localWaste.localized(
            "localWasteAddressSelectionViewSubtitle"
        )
        #expect(sut.subtitle == expected)
    }

    @Test
    func primaryButton_returnsCorrectValue() throws {
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: {},
            doneAction: {}
        )
        let expected = String.localWaste.localized(
            "localWasteAddressSelectionViewPrimaryButton"
        )
        #expect(sut.primaryButton == expected)
    }

    @Test
    func addresses_returnsCorrectValue() throws {
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: {},
            doneAction: {}
        )
        #expect(sut.addresses == addresses)
    }

    @Test
    func confirmAddress_noSelectedAddress() async throws {
        var dismissCalled = false
        var doneCalled = false
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: {
                dismissCalled = true
            },
            doneAction: {
                doneCalled = true
            }
        )
        sut.selectedAddress = nil
        sut.confirmAddress()
        #expect(doneCalled == false)
        #expect(dismissCalled == false)
    }
 
    @Test
    func confirmAddress_addressSelected_callsDoneAction() async throws {
        var dismissCalled = false
        var doneCalled = false
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: MockAnalyticsService(),
            addresses: addresses,
            dismissAction: {
                dismissCalled = true
            },
            doneAction: {
                doneCalled = true
            }
        )
        sut.selectedAddress = addresses[0]
        sut.confirmAddress()
        #expect(doneCalled == true)
        #expect(dismissCalled == false)
    }
    
    @Test
    func confirmAddress_addressSelected_savesAddress() async throws {
       let mockService = MockLocalWasteService()
       let sut = LocalWasteAddressSelectionViewModel(
           service: mockService,
           analyticsService: MockAnalyticsService(),
           addresses: addresses,
           dismissAction: {},
           doneAction: {}
       )
       sut.selectedAddress = addresses[0]
       sut.confirmAddress()
       #expect(mockService._addressSaveAddress == addresses[0])
    }

    @Test
    func fetchAddresses_trackNavigationEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: mockAnalyticsService,
            addresses: addresses,
            dismissAction: {},
            doneAction: {}
        )
        sut.selectedAddress = addresses[0]
        sut.confirmAddress()
        let receivedTitle = mockAnalyticsService._trackedEvents.first?.params?["text"] as? String
        #expect(receivedTitle == "Confirm address")
    }

    @Test
    func trackScreen_sendsEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = LocalWasteAddressSelectionViewModel(
            service: MockLocalWasteService(),
            analyticsService: mockAnalyticsService,
            addresses: addresses,
            dismissAction: {},
            doneAction: {}
        )
        let view = LocalWasteAddressSelectionView(viewModel: sut)
        sut.trackScreen(screen: view)
        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingName == view.trackingName)
        #expect(screens.first?.trackingTitle == view.trackingTitle)
    }
    
    let addresses: [LocalWasteAddress] = [
        .init(addressFull: "address1", uprn: "uprn1", localCustodianCode: "code1"),
        .init(addressFull: "address2", uprn: "uprn2", localCustodianCode: "code2"),
        .init(addressFull: "address3", uprn: "uprn3", localCustodianCode: "code3")
    ]
}
