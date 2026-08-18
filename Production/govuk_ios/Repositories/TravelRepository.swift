import Foundation

protocol TravelRepositoryInterface {
    func fetchGroups() -> [TravelGroup]?
    func store(groups: [TravelGroup])
    func clear()
}

final class TravelRepository: TravelRepositoryInterface {
    private var groups: [TravelGroup]?

    func fetchGroups() -> [TravelGroup]? {
        groups
    }

    func store(groups: [TravelGroup]) {
        self.groups = groups
    }

    func clear() {
        groups = nil
    }
}
