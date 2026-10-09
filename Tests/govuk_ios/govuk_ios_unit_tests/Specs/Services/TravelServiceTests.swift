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
    func invalidateGroups_clearGroupsCache() {
        sut.invalidateGroups()
        #expect(mockTravelRepository._invalidateGroupsCalled)
    }

    @Test
    func invalidateCountries_clearCountriesCache() {
        sut.invalidateCountries()
        #expect(mockTravelRepository._invalidateCountriesCalled)
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

        let countries = try #require(try? result.get())
        #expect(countries == Self.remoteCountries)
        #expect(mockTravelServiceClient._fetchCountriesCallCount == 1)
        #expect(mockTravelRepository._storedCountries == Self.remoteCountries)
    }

    @Test
    func subscribeToGroups_success_callsClient() async throws {
        let slug = "travel-group-1"

        let result = await withCheckedContinuation { continuation in
            sut.subscribeToCountry(slug: slug, notificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedSubscribeCompletion?(.success(()))
        }

        #expect(result.getError() == nil)
        #expect(mockTravelServiceClient._subscribeToGroupsCallCount == 1)
        #expect(mockTravelServiceClient._receivedSubscribeSlug == slug)
    }

    @Test
    func subscribeToGroups_success_invalidatesGroupsCache() async throws {
        let slug = "travel-group-1"

        let result = await withCheckedContinuation { continuation in
            sut.subscribeToCountry(slug: slug, notificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedSubscribeCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelRepository._invalidateGroupsCalled)
    }

    @Test
    func subscribeToGroups_failure_doesNotInvalidateCache() async {
        let slug = "travel-group-1"

        let result = await withCheckedContinuation { continuation in
            sut.subscribeToCountry(slug: slug, notificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedSubscribeCompletion?(.failure(.apiUnavailable))
        }

        #expect(result.getError() == .apiUnavailable)
        #expect(mockTravelRepository._invalidateGroupsCalled == false)
    }

    @Test
    func subscribeToCountry_withNotificationsDisabled_success() async throws {
        let slug = "travel-group-1"

        let result = await withCheckedContinuation { continuation in
            sut.subscribeToCountry(slug: slug, notificationsEnabled: false) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedSubscribeCompletion?(.success(()))
        }

        #expect(result.getError() == nil)
        #expect(mockTravelServiceClient._subscribeToGroupsCallCount == 1)
        #expect(mockTravelServiceClient._receivedSubscribeSlug == slug)
        #expect(mockTravelServiceClient._receivedSubscribeBool == false)
    }

    @Test
    func subscribeToCountry_failure_returnsError() async throws {
        let slug = "travel-group-1"

        let result = await withCheckedContinuation { continuation in
            sut.subscribeToCountry(slug: slug, notificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedSubscribeCompletion?(.failure(.networkUnavailable))
        }

        #expect(result.getError() == .networkUnavailable)
        #expect(mockTravelRepository._invalidateGroupsCalled == false)
    }

    @Test
    func getCountries_cacheAvailable_returnsCachedCountries() async throws {
        mockTravelRepository._fetchCountriesResult = Self.cachedCountries

        let result = await withCheckedContinuation { continuation in
            sut.getCountries { result in
                continuation.resume(returning: result)
            }
        }

        let countries = try #require(try? result.get())
        #expect(countries == Self.cachedCountries)
        #expect(mockTravelServiceClient._fetchCountriesCallCount == 0)
    }

    @Test
    func getCountries_forceRefresh_overridesCache() async throws {
        mockTravelRepository._fetchCountriesResult = Self.cachedCountries

        let result = await withCheckedContinuation { continuation in
            sut.getCountries(forceRefresh: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient
                ._receivedFetchCountriesCompletion?(.success(Self.remoteCountries))
        }

        let countries = try #require(try? result.get())
        #expect(countries == Self.remoteCountries)
        #expect(mockTravelServiceClient._fetchCountriesCallCount == 1)
        #expect(mockTravelRepository._storedCountries == Self.remoteCountries)
    }

    @Test
    func getCountries_clientFailure_doesNotStoreCache() async {
        mockTravelRepository._fetchCountriesResult = nil

        let result = await withCheckedContinuation { continuation in
            sut.getCountries { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient
                ._receivedFetchCountriesCompletion?(.failure(.networkUnavailable))
        }

        #expect(result.getError() == .networkUnavailable)
        #expect(mockTravelRepository._storedCountries == nil)
    }

    @Test
    func getCountries_cacheUnavailable_fetchesFromClientAndStores() async throws {
        mockTravelRepository._fetchCountriesResult = nil

        let result = await withCheckedContinuation { continuation in
            sut.getCountries { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient
                ._receivedFetchCountriesCompletion?(.success(Self.remoteCountries))
        }

        let countries = try #require(try? result.get())
        #expect(countries == Self.remoteCountries)
        #expect(mockTravelServiceClient._fetchCountriesCallCount == 1)
        #expect(mockTravelRepository._storedCountries == Self.remoteCountries)
    }

    @Test
    func toggleNotifications_enabledTrue_success_invalidatesGroupsCache() async throws {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: slug, enabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedToggleCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._toggleNotificationsCallCount == 1)
        #expect(mockTravelRepository._invalidateGroupsCalled)
    }

    @Test
    func toggleNotifications_enabledFalse_success_invalidatesGroupsCache() async throws {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: slug, enabled: false) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedToggleCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._toggleNotificationsCallCount == 1)
        #expect(mockTravelRepository._invalidateGroupsCalled)
    }

    @Test
    func toggleNotifications_failure_doesNotInvalidateCache() async {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: slug, enabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedToggleCompletion?(.failure(.apiUnavailable))
        }

        #expect(result.getError() == .apiUnavailable)
        #expect(mockTravelRepository._invalidateGroupsCalled == false)
    }

    @Test
    func toggleNotifications_enabledTrue_passesEnabledParameter() async throws {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: slug, enabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedToggleCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._receivedToggleSlug == slug)
        #expect(mockTravelServiceClient._receivedToggleEnabled == true)
    }

    @Test
    func toggleNotifications_enabledFalse_passesEnabledParameter() async throws {
        let slug = "spain"

        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: slug, enabled: false) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedToggleCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._receivedToggleSlug == slug)
        #expect(mockTravelServiceClient._receivedToggleEnabled == false)
    }

    @Test
    func toggleNotifications_callsClientWithCorrectParameters() async throws {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: slug, enabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedToggleCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._toggleNotificationsCallCount == 1)
        #expect(mockTravelServiceClient._receivedToggleSlug == slug)
        #expect(mockTravelServiceClient._receivedToggleEnabled == true)
    }

    @Test
    func unfollowCountry_withNotificationsEnabled_success_invalidatesGroupsCache() async throws {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: slug, currentNotificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedUnfollowCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._unfollowCallCount == 1)
        #expect(mockTravelRepository._invalidateGroupsCalled)
    }

    @Test
    func unfollowCountry_withoutNotificationsEnabled_success_invalidatesGroupsCache() async throws {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: slug, currentNotificationsEnabled: false) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedUnfollowCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._unfollowCallCount == 1)
        #expect(mockTravelRepository._invalidateGroupsCalled)
    }

    @Test
    func unfollowCountry_failure_doesNotInvalidateCache() async {
        let slug = "france"

        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: slug, currentNotificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedUnfollowCompletion?(.failure(.authenticationError))
        }

        #expect(result.getError() == .authenticationError)
        #expect(mockTravelRepository._invalidateGroupsCalled == false)
    }

    @Test
    func unfollowCountry_withNotificationsEnabled_passesCorrectParameters() async throws {
        let slug = "spain"

        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: slug, currentNotificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedUnfollowCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._receivedUnfollowSlug == slug)
        #expect(mockTravelServiceClient._receivedUnfollowEnabled == true)
    }

    @Test
    func unfollowCountry_withoutNotificationsEnabled_passesCorrectParameters() async throws {
        let slug = "germany"

        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: slug, currentNotificationsEnabled: false) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedUnfollowCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._receivedUnfollowSlug == slug)
        #expect(mockTravelServiceClient._receivedUnfollowEnabled == false)
    }

    @Test
    func unfollowCountry_callsClientWithCorrectParameters() async throws {
        let slug = "spain"

        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: slug, currentNotificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
            mockTravelServiceClient._receivedUnfollowCompletion?(.success(()))
        }

        _ = try #require(try? result.get())
        #expect(mockTravelServiceClient._unfollowCallCount == 1)
        #expect(mockTravelServiceClient._receivedUnfollowSlug == slug)
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
        Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
        Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
        Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: [])
    ]

    static let remoteCountries: [Country] = [
        Country(name: "France", slug: "france", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
        Country(name: "Germany", slug: "germany", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: []),
        Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-01-01T00:00:00Z", synonyms: [])
    ]
}
