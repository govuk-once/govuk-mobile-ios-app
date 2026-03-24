import Foundation
import Testing

@testable import govuk_ios

@Suite
struct LocalWasteServiceTests {

    @Test
    func fetchAddresses_callsServiceClient() async throws {
        let mockServiceClient = MockLocalWasteServiceClient()
        mockServiceClient._dataFetchAddresses = []
        let sut = LocalWasteService(
            serviceClient: mockServiceClient,
            repository: MockLocalWasteRepository()
        )
        let expectedPostcode = "BS153FL"
        
        let _ = try await sut.fetchAddresses(postcode: expectedPostcode)
        #expect(mockServiceClient._postcodeFetchAddresses == expectedPostcode)
    }
    
    @Test
    func fetchAddresses_returnsAddresses() async throws {
        let expectedAddresses = [
            LocalWasteAddress(
                addressFull: "address1",
                uprn: "uprn1",
                localCustodianCode: "code1"
            ),
            LocalWasteAddress(
                addressFull: "address2",
                uprn: "uprn2",
                localCustodianCode: "code2"
            ),
        ]
        let mockServiceClient = MockLocalWasteServiceClient()
        mockServiceClient._dataFetchAddresses = expectedAddresses
        let sut = LocalWasteService(
            serviceClient: mockServiceClient,
            repository: MockLocalWasteRepository()
        )

        let actualAddresses = try await sut.fetchAddresses(postcode: "BS153FL")
        #expect(actualAddresses == expectedAddresses)
    }
    
    @Test
    func fetchAddresses_throwsError() async throws {
        let expectedError = LocalWasteAddressesApiError.networkUnavailable
        let mockServiceClient = MockLocalWasteServiceClient()
        mockServiceClient._errorFetchAddresses = expectedError
        let sut = LocalWasteService(
            serviceClient: mockServiceClient,
            repository: MockLocalWasteRepository()
        )

        let actualError = try await #require(throws: LocalWasteAddressesApiError.self) {
            try await sut.fetchAddresses(postcode: "BS153FL")
        }
        #expect(actualError == expectedError)
    }

    @Test
    func fetchAddress_fetchesFromRepository() async throws {
        let mockRepository = MockLocalWasteRepository()
        let sut = LocalWasteService(
            serviceClient: MockLocalWasteServiceClient(),
            repository: mockRepository
        )
        _ = sut.fetchAddress()
        #expect(mockRepository._didFetchAddress)
    }

    @Test
    func saveAddress_fetchesFromRepository() async throws {
        let mockRepository = MockLocalWasteRepository()
        let sut = LocalWasteService(
            serviceClient: MockLocalWasteServiceClient(),
            repository: mockRepository
        )
        sut.saveAddress(.init(addressFull: "1", uprn: "1", localCustodianCode: "1"))
        #expect(mockRepository._didSaveAddress)
    }

    @Test
    func popSchedule_whenEmpty_returnsNil() async throws {
        let sut = LocalWasteService(
            serviceClient: MockLocalWasteServiceClient(),
            repository: MockLocalWasteRepository()
        )
        let actual = sut.popScheduleCache()
        #expect(actual == nil)
    }

    @Test
    func popSchedule_whenNotEmpty_returnsScheduleAndSetsCacheToNil() async throws {
        let sut = LocalWasteService(
            serviceClient: MockLocalWasteServiceClient(),
            repository: MockLocalWasteRepository()
        )
        sut.pushScheduleCache(Constants.schedule)

        let actual1 = sut.popScheduleCache()
        #expect(actual1 == Constants.schedule)

        let actual2 = sut.popScheduleCache()
        #expect(actual2 == nil)
    }

    struct Constants {
        static let schedule = [
            LocalWasteBin(date: LocalWasteServiceClient.dateFormatter.date(from: "2026-03-16")!,
                          name: "Black",
                          color: .black,
                          content: "general waste"),
            LocalWasteBin(date: LocalWasteServiceClient.dateFormatter.date(from: "2026-03-15")!,
                          name: "Green",
                          color: .green,
                          content: "recycling")
        ]
    }
}
