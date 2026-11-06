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
    class DateProvider {
        var currentDate: Date {
            Date()
        }
    }

    private struct CacheEntry<T> {
        private let travelExpiration: TimeInterval = 300

        let data: T
        let lastUpdate: Date

        func hasExpired(with date: Date) -> Bool {
            date.timeIntervalSince(lastUpdate) > travelExpiration
        }
    }

    private var groups: CacheEntry<[TravelGroup]>?
    private var countries: CacheEntry<[Country]>?
    private var dateProvider: DateProvider

    init(dateProvider: DateProvider = .init()) {
        self.dateProvider = dateProvider
    }

    func fetchGroups() -> [TravelGroup]? {
        guard let groups else { return nil }
        return groups.hasExpired(with: dateProvider.currentDate) ? nil : groups.data
    }

    func store(groups: [TravelGroup]) {
        self.groups = .init(data: groups, lastUpdate: dateProvider.currentDate)
    }

    func fetchCountries() -> [Country]? {
        guard let countries else { return nil }
        return countries.hasExpired(with: dateProvider.currentDate) ? nil : countries.data
    }

    func store(countries: [Country]) {
        self.countries = .init(data: countries, lastUpdate: dateProvider.currentDate)
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
