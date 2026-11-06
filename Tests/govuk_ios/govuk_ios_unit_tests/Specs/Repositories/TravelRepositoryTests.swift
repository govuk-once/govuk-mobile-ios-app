import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TravelRepositoryTests {
    class MockDateProvider: TravelRepository.DateProvider {
        var _mockDate: Date = Date()

        override var currentDate: Date {
            _mockDate
        }
    }

    @Test
    func initialState_isEqualToNil() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)

        #expect(repository.fetchGroups() == nil)
        #expect(repository.fetchCountries() == nil)
    }

    @Test
    func fetchGroups_returnGroups() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let sampleGroups = [
            TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1"),
            TravelGroup(namespace: "travel-namespace-2", group: "travel-group-2", subgroup: "travel-subgroup-2")
        ]

        repository.store(groups: sampleGroups)

        #expect(repository.fetchGroups() == sampleGroups)
    }

    @Test
    func fetchGroups_returnsGroups_thenClearsCache() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let sampleGroups = [TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1")]

        repository.store(groups: sampleGroups)
        #expect(repository.fetchGroups() != nil) // Verify store succeeded first

        repository.clear()

        #expect(repository.fetchGroups() == nil)
    }

    @Test
    func fetchGroups_retunsEmptyArray() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)

        repository.store(groups: [])

        let fetched = repository.fetchGroups()
        #expect(fetched != nil)
        #expect(fetched?.isEmpty == true)
    }

    @Test
    func fetchGroups_returnsGroups_then_fetchGroups_returnsNewGroups() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let initialGroups = [TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1")]
        let newGroups = [TravelGroup(namespace: "travel-namespace-2", group: "travel-group-2", subgroup: "travel-subgroup-2")]

        repository.store(groups: initialGroups)
        repository.store(groups: newGroups)

        #expect(repository.fetchGroups() == newGroups)
    }

    @Test
    func fetchCountries_returnCountries() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let sampleCountry = [
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: []),
            Country(name: "Spain", slug: "spain", rawLastUpdate: "", synonyms: []),
        ]

        repository.store(countries: sampleCountry)

        #expect(repository.fetchCountries() == sampleCountry)
    }

    @Test
    func fetchCountries_returnCountries_thenClearsCache() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let sampleCountries = [
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: []),
            Country(name: "Spain", slug: "spain", rawLastUpdate: "", synonyms: []),
        ]

        repository.store(countries: sampleCountries)
        #expect(repository.fetchCountries() != nil) // Verify store succeeded first

        repository.clear()

        #expect(repository.fetchCountries() == nil)
    }

    @Test
    func fetchCountries_retunsEmptyArray() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)

        repository.store(countries: [])

        let fetched = repository.fetchCountries()
        #expect(fetched != nil)
        #expect(fetched?.isEmpty == true)
    }

    @Test
    func fetchGroups_afterExpiration_returnsNil() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let baseDate = Date()
        let sampleGroups = [
            TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1")
        ]

        mockDateProvider._mockDate = baseDate
        repository.store(groups: sampleGroups)

        mockDateProvider._mockDate = baseDate.addingTimeInterval(301)

        #expect(repository.fetchGroups() == nil)
    }

    @Test
    func fetchGroups_beforeExpiration_returnsGroups() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let baseDate = Date()
        let sampleGroups = [
            TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1")
        ]

        mockDateProvider._mockDate = baseDate
        repository.store(groups: sampleGroups)

        mockDateProvider._mockDate = baseDate.addingTimeInterval(299)

        #expect(repository.fetchGroups() == sampleGroups)
    }

    @Test
    func fetchCountries_afterExpiration_returnsNil() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let baseDate = Date()
        let sampleCountries = [
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: []),
            Country(name: "Spain", slug: "spain", rawLastUpdate: "", synonyms: [])
        ]

        mockDateProvider._mockDate = baseDate
        repository.store(countries: sampleCountries)

        mockDateProvider._mockDate = baseDate.addingTimeInterval(301)

        #expect(repository.fetchCountries() == nil)
    }

    @Test
    func fetchCountries_beforeExpiration_returnsCountries() {
        let mockDateProvider = MockDateProvider()
        let repository = TravelRepository(dateProvider: mockDateProvider)
        let baseDate = Date()
        let sampleCountries = [
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: []),
            Country(name: "Spain", slug: "spain", rawLastUpdate: "", synonyms: [])
        ]

        mockDateProvider._mockDate = baseDate
        repository.store(countries: sampleCountries)

        mockDateProvider._mockDate = baseDate.addingTimeInterval(299)

        #expect(repository.fetchCountries() == sampleCountries)
    }

}
