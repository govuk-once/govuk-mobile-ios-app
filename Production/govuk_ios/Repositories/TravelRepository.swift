import Foundation

protocol TravelRepositoryInterface {
    func fetchGroups() -> [TravelGroup]?
    func store(groups: [TravelGroup])
    func fetchCountries() -> [Country]?
    func store(countries: [Country])
    func invalidateGroups()
    func invalidateCountries()
    func clear()
}

final class TravelRepository: TravelRepositoryInterface {
    private var groups: [TravelGroup]?
    private var countries: [Country]?

    func fetchGroups() -> [TravelGroup]? {
        groups
    }

    func store(groups: [TravelGroup]) {
        self.groups = groups
    }

    func fetchCountries() -> [Country]? {
        countries
    }

    func store(countries: [Country]) {
        self.countries = countries
    }

    func invalidateGroups() {
        groups = nil
    }

    func invalidateCountries() {
        countries = nil
    }

    func clear() {
        groups = nil
        countries = nil
    }
}
