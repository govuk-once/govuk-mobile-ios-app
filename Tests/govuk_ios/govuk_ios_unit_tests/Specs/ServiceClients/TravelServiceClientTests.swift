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
        #expect(countries?.first?.country == "Test Country")
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
