import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TravelServiceTests {
    let mockTravelServiceClient: MockTravelServiceClient
    let mockTravelRepository: MockTravelRepository
    let sut: TravelService

    init() {
        mockTravelServiceClient = MockTravelServiceClient()
        mockTravelRepository = MockTravelRepository()
        sut = TravelService(
            travelServiceClient: mockTravelServiceClient,
            analyticsService: MockAnalyticsService(),
            repository: mockTravelRepository
        )
    }

    @Test
    func getGroups_cacheAvailable_returnsCachedGroups() async throws {
        mockTravelRepository._fetchGroupsResult = Self.cachedGroups

        let result = await withCheckedContinuation { continuation in
            sut.getGroups { result in
                continuation.resume(returning: result)
            }
        }

        let groups = try #require(try? result.get())
        #expect(groups == Self.cachedGroups)
        #expect(mockTravelServiceClient._fetchGroupsCallCount == 0)
    }

    @Test
    func getGroups_cacheUnavailable_fetchesFromClientAndStores() async throws {
        mockTravelRepository._fetchGroupsResult = nil

        let result = await withCheckedContinuation { continuation in
            sut.getGroups { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient
                ._receivedFetchGroupsCompletion?(.success(Self.remoteGroups))
        }

        let groups = try #require(try? result.get())
        #expect(groups == Self.remoteGroups)
        #expect(mockTravelServiceClient._fetchGroupsCallCount == 1)
        #expect(mockTravelRepository._storedGroups == Self.remoteGroups)
    }

    @Test
    func getGroups_forceRefresh_overridesCache() async throws {
        mockTravelRepository._fetchGroupsResult = Self.cachedGroups

        let result = await withCheckedContinuation { continuation in
            sut.getGroups(forceRefresh: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient
                ._receivedFetchGroupsCompletion?(.success(Self.remoteGroups))
        }

        let groups = try #require(try? result.get())
        #expect(groups == Self.remoteGroups)
        #expect(mockTravelServiceClient._fetchGroupsCallCount == 1)
    }

    @Test
    func getGroups_clientFailure_doesNotStoreCache() async {
        mockTravelRepository._fetchGroupsResult = nil

        let result = await withCheckedContinuation { continuation in
            sut.getGroups { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient
                ._receivedFetchGroupsCompletion?(.failure(.apiUnavailable))
        }

        #expect(result.getError() == .apiUnavailable)
        #expect(mockTravelRepository._storedGroups == nil)
    }

    @Test
    func invalidateCache_clearsRepository() {
        sut.invalidateCache()
        #expect(mockTravelRepository._clearCalled)
    }



    @Test
    func getCountries_clientReturnsCountries_returnsValues() async throws {
        mockTravelRepository._fetchCountriesResult = nil

        let result = await withCheckedContinuation { continuation in
            sut.getCountries { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient
                ._receivedFetchCountriesCompletion?(.success(Self.remoteCountries))
        }

        let groups = try #require(try? result.get())
        #expect(groups == Self.remoteCountries)
        #expect(mockTravelServiceClient._fetchCountriesCallCount == 0)
    }

}

private extension TravelServiceTests {
    static let cachedGroups: [TravelGroup] = [
        TravelGroup(namespace: "travel-advice", group: "travel-group-1", subgroup: "travel-subgroup-1")
    ]

    static let remoteGroups: [TravelGroup] = [
        TravelGroup(namespace: "travel-advice", group: "travel-group-2", subgroup: "travel-subgroup-2")
    ]

    static let cachedCountries: [Country] = [
        Country(country: "United Kingdom", slug: "united-kingdom", lastUpdate: "2024-01-01", synonyms: ["UK"]),
        Country(country: "France", slug: "france", lastUpdate: "2024-01-01", synonyms: [])
    ]

    static let remoteCountries: [Country] = [
        Country(country: "France", slug: "france", lastUpdate: "", synonyms: []),
        Country(country: "Germany", slug: "germany", lastUpdate: "", synonyms: []),
        Country(country: "Spain", slug: "spain", lastUpdate: "", synonyms: [])
    ]
}
