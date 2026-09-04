import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TravelRepositoryTests {
    @Test
    func initialState_isEqualToNil() {
        let repository = TravelRepository()

        #expect(repository.fetchGroups() == nil)
        #expect(repository.fetchCountries() == nil)
    }

    @Test
    func fetchGroups_returnGroups() {
        let repository = TravelRepository()
        let sampleGroups = [
            TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1"),
            TravelGroup(namespace: "travel-namespace-2", group: "travel-group-2", subgroup: "travel-subgroup-2")
        ]

        repository.store(groups: sampleGroups)

        #expect(repository.fetchGroups() == sampleGroups)
    }

    @Test
    func fetchGroups_returnsGroups_thenClearsCache() {
        let repository = TravelRepository()
        let sampleGroups = [TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1")]

        repository.store(groups: sampleGroups)
        #expect(repository.fetchGroups() != nil) // Verify store succeeded first

        repository.clear()

        #expect(repository.fetchGroups() == [])
    }

    @Test
    func fetchGroups_retunsEmptyArray() {
        let repository = TravelRepository()

        repository.store(groups: [])

        let fetched = repository.fetchGroups()
        #expect(fetched != nil)
        #expect(fetched?.isEmpty == true)
    }

    @Test
    func fetchGroups_returnsGroups_then_fetchGroups_returnsNewGroups() {
        let repository = TravelRepository()
        let initialGroups = [TravelGroup(namespace: "travel-namespace-1", group: "travel-group-1", subgroup: "travel-subgroup-1")]
        let newGroups = [TravelGroup(namespace: "travel-namespace-2", group: "travel-group-2", subgroup: "travel-subgroup-2")]

        repository.store(groups: initialGroups)
        repository.store(groups: newGroups)

        #expect(repository.fetchGroups() == newGroups)
    }

    @Test
    func fetchCountries_returnCountries() {
        let repository = TravelRepository()
        let sampleCountry = [
            Country(country: "France", slug: "france", lastUpdate: "", synonyms: []),
            Country(country: "Spain", slug: "spain", lastUpdate: "", synonyms: []),
        ]

        repository.store(countries: sampleCountry)

        #expect(repository.fetchCountries() == sampleCountry)
    }

    @Test
    func fetchCountries_returnCountries_thenClearsCache() {
        let repository = TravelRepository()
        let sampleCountries = [
            Country(country: "France", slug: "france", lastUpdate: "", synonyms: []),
            Country(country: "Spain", slug: "spain", lastUpdate: "", synonyms: []),
        ]

        repository.store(countries: sampleCountries)
        #expect(repository.fetchCountries() != nil) // Verify store succeeded first

        repository.clear()

        #expect(repository.fetchCountries() == [])
    }

    @Test
    func fetchCountries_retunsEmptyArray() {
        let repository = TravelRepository()

        repository.store(countries: [])

        let fetched = repository.fetchCountries()
        #expect(fetched != nil)
        #expect(fetched?.isEmpty == true)
    }

}
