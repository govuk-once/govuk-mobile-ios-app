import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct EditTopicsDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = EditTopicsDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/topics/edit")
    }
    
    @Test
    func action_EditTopics() async {
        await MockActivityService.setUp()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = EditTopicsDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)
        let parentCoordinator = mockCoordinatorBuilder._mockHomeCoordinator
        #expect(parentCoordinator._didEditTopics == false)
        subject.action(parent: parentCoordinator, params: [:])
        #expect(parentCoordinator._didEditTopics == true)
    }
}
