import Foundation
import Testing

@testable import govuk_ios

@Suite
struct TravelRepositoryTests {
    @Test
    func initialState_isEqualToNil() {
        let repository = TravelRepository()

        #expect(repository.fetchGroups() == nil)
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

}
