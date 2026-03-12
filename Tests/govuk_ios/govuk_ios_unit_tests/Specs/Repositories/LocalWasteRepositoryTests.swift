import Foundation
import Testing
import CoreData

@testable import govuk_ios

@Suite
@MainActor
struct LocalWasteRepositoryTests {

    @Test
    func noAddress() {
        let coreData = CoreDataRepository.arrangeAndLoad
        let sut = LocalWasteRepository(coreData: coreData)

        let actualAddress = sut.fetchAddress()
        #expect(actualAddress == nil)
    }

    @Test
    func saveAddress_savesObject() {
        let coreData = CoreDataRepository.arrangeAndLoad
        let sut = LocalWasteRepository(coreData: coreData)

        let address = LocalWasteAddress(
            addressFull: "address1",
            uprn: "uprn1",
            localCustodianCode: "code1")

        sut.saveAddress(address)

        let actualAddress = sut.fetchAddress()
        #expect(actualAddress == address)
    }

    @Test func saveAddress_replacesOldAddress() {
        let coreData = CoreDataRepository.arrangeAndLoad
        let sut = LocalWasteRepository(coreData: coreData)

        let address1 = LocalWasteAddress(
            addressFull: "address1",
            uprn: "uprn1",
            localCustodianCode: "code1")
        sut.saveAddress(address1)

        let address2 = LocalWasteAddress(
            addressFull: "address2",
            uprn: "uprn2",
            localCustodianCode: "code2")
        sut.saveAddress(address2)

        let actualAddress = sut.fetchAddress()
        #expect(actualAddress == address2)
    }
}
