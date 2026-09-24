import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TravelServiceClientTests {

    let mockAPI: MockAPIServiceClient!
    let sut: TravelServiceClient!

    init() {
        mockAPI = MockAPIServiceClient()
        sut = TravelServiceClient(apiServiceClient: mockAPI)
    }

    @Test
    func fetchGroups_sendsExpectedRequest() {
        sut.fetchGroups { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/groups/v1/groups")
        #expect(mockAPI._receivedSendRequest?.method == .get)
    }

    @Test
    func fetchGroups_success_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(Self.travelGroupsData)
        let result = await withCheckedContinuation { continuation in
            sut.fetchGroups { result in
                continuation.resume(returning: result)
            }
        }
        let groups = try? result.get()
        #expect(groups?.count == 1)
        #expect(groups?.first?.namespace == "Travel-Namespace")
    }

    @Test
    func fetchGroups_networkUnavailable_mapsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.fetchGroups { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func fetchGroups_authenticationError_preservesTypedError() async {
        mockAPI._stubbedSendResponse = .failure(TravelError.authenticationError)
        let result = await withCheckedContinuation { continuation in
            sut.fetchGroups { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .authenticationError)
    }

    @Test
    func fetchGroups_invalidJson_mapsDecodingError() async {
        mockAPI._stubbedSendResponse = .success("invalid".data(using: .utf8)!)
        let result = await withCheckedContinuation { continuation in
            sut.fetchGroups { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .decodingError)
    }

    @Test
    func fetchCountries_sendsExpectedRequest() {
        sut.fetchCountries { _ in }
        #expect(mockAPI._receivedSendRequest?.urlPath == "/app/travel/v1/countries")
        #expect(mockAPI._receivedSendRequest?.method == .get)
    }

    @Test
    func fetchCountries_success_returnsExpectedResult() async {
        mockAPI._stubbedSendResponse = .success(Self.countriesData)
        let result = await withCheckedContinuation { continuation in
            sut.fetchCountries { result in
                continuation.resume(returning: result)
            }
        }
        let countries = try? result.get()
        #expect(countries?.count == 1)
        #expect(countries?.first?.name == "Test Country")
        #expect(countries?.first?.slug == "test-country")
    }

    @Test
    func fetchCountries_networkUnavailable_mapsExpectedError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.fetchCountries { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func fetchCountries_authenticationError_preservesTypedError() async {
        mockAPI._stubbedSendResponse = .failure(TravelError.authenticationError)
        let result = await withCheckedContinuation { continuation in
            sut.fetchCountries { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .authenticationError)
    }

    @Test
    func fetchCountries_invalidJson_mapsDecodingError() async {
        mockAPI._stubbedSendResponse = .success("invalid".data(using: .utf8)!)
        let result = await withCheckedContinuation { continuation in
            sut.fetchCountries { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .decodingError)
    }

    @Test
    func subscribeToCountry_sendsExpectedRequest() {
        sut.followCountry(slug: "france") { _ in }
        #expect(mockAPI._receivedSendRequest != nil)
    }

    @Test
    func subscribeToCountry_success_returnsSuccess() async {
        mockAPI._stubbedSendResponse = .success(Data())
        let result = await withCheckedContinuation { continuation in
            sut.followCountry(slug: "france") { result in
                continuation.resume(returning: result)
            }
        }
        do {
            _ = try result.get()
            #expect(true)
        } catch {
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test
    func subscribeToCountry_networkError_mapsError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.followCountry(slug: "france") { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func subscribeToCountry_authenticationError_preservesError() async {
        mockAPI._stubbedSendResponse = .failure(TravelError.authenticationError)
        let result = await withCheckedContinuation { continuation in
            sut.followCountry(slug: "france") { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .authenticationError)
    }

    @Test
    func subscribeToCountry_genericError_mapsToApiUnavailable() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: -1)
        )
        let result = await withCheckedContinuation { continuation in
            sut.followCountry(slug: "france") { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .apiUnavailable)
    }

    @Test
    func toggleNotifications_enabledTrue_sendsExpectedRequest() {
        sut.toggleNotifications(slug: "france", enabled: true) { _ in }
        #expect(mockAPI._receivedSendRequest != nil)
    }

    @Test
    func toggleNotifications_enabledFalse_sendsExpectedRequest() {
        sut.toggleNotifications(slug: "france", enabled: false) { _ in }
        #expect(mockAPI._receivedSendRequest != nil)
    }

    @Test
    func toggleNotifications_success_returnsSuccess() async {
        mockAPI._stubbedSendResponse = .success(Data())
        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: "france", enabled: true) { result in
                continuation.resume(returning: result)
            }
        }
        do {
            _ = try result.get()
            #expect(true)
        } catch {
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test
    func toggleNotifications_networkError_mapsError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: "france", enabled: true) { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func toggleNotifications_apiError_mapsError() async {
        mockAPI._stubbedSendResponse = .failure(TravelError.apiUnavailable)
        let result = await withCheckedContinuation { continuation in
            sut.toggleNotifications(slug: "france", enabled: false) { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .apiUnavailable)
    }

    @Test
    func unfollowCountry_sendsExpectedRequest() {
        sut.unfollowCountry(slug: "france", currentNotificationsEnabled: true) { _ in }
        #expect(mockAPI._receivedSendRequest != nil)
    }

    @Test
    func unfollowCountry_withNotificationsEnabled_success() async {
        mockAPI._stubbedSendResponse = .success(Data())
        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: "france", currentNotificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
        }
        do {
            _ = try result.get()
            #expect(true)
        } catch {
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test
    func unfollowCountry_withoutNotificationsEnabled_success() async {
        mockAPI._stubbedSendResponse = .success(Data())
        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: "france", currentNotificationsEnabled: false) { result in
                continuation.resume(returning: result)
            }
        }
        do {
            _ = try result.get()
            #expect(true)
        } catch {
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test
    func unfollowCountry_networkError_mapsError() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: NSURLErrorNotConnectedToInternet)
        )
        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: "france", currentNotificationsEnabled: true) { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func unfollowCountry_authenticationError_preservesError() async {
        mockAPI._stubbedSendResponse = .failure(TravelError.authenticationError)
        let result = await withCheckedContinuation { continuation in
            sut.unfollowCountry(slug: "france", currentNotificationsEnabled: false) { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .authenticationError)
    }

    @Test
    func errorMapping_travelErrorPassthrough_preservesError() async {
        let travelError = TravelError.decodingError
        mockAPI._stubbedSendResponse = .failure(travelError)
        let result = await withCheckedContinuation { continuation in
            sut.fetchGroups { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .decodingError)
    }

    @Test
    func errorMapping_genericNSError_mapsToApiUnavailable() async {
        mockAPI._stubbedSendResponse = .failure(
            NSError(domain: "TestError", code: -1000)
        )
        let result = await withCheckedContinuation { continuation in
            sut.fetchGroups { result in
                continuation.resume(returning: result)
            }
        }
        #expect(result.getError() == .apiUnavailable)
    }
}

private extension TravelServiceClientTests {
    static let travelGroupsData =
    """
    [
      {
        "Namespace": "Travel-Namespace",
        "Group": "Travel-Group",
        "Subgroup": "Travel-Subgroup"
      }
    ]
    """.data(using: .utf8)!

    static let countriesData =
    """
    [
      {
        "country": "Test Country",
        "slug": "test-country",
        "lastUpdate": "2024-01-01",
        "synonyms": []
      }
    ]
    """.data(using: .utf8)!
}
