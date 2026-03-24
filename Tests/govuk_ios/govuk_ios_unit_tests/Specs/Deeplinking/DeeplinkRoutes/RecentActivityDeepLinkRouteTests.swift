import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct RecentActivityDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = RecentActivityDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/visited")
    }
    
    @Test
    func show_last_visited() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = RecentActivityDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        let parentCoordinator = mockCoordinatorBuilder._mockHomeCoordinator
        #expect(parentCoordinator._didShowLastVisited == false)
        subject.action(parent: parentCoordinator, params: [:])
        #expect(parentCoordinator._didShowLastVisited == true)
    }
}
