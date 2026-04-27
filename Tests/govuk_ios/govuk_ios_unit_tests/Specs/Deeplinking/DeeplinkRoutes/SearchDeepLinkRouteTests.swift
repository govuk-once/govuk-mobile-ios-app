import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct SearchDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = SearchDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/search")
    }
    
    @Test
    func open_search() async {
        await MockActivityService.setUp()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = SearchDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)
        let parent = mockCoordinatorBuilder._mockHomeCoordinator
        #expect(parent._didOpenSearch == false)
        subject.action(parent: parent, params: [:])
        #expect(parent._didOpenSearch == true)
    }
}
