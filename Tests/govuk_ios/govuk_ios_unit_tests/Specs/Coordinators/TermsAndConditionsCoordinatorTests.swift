import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct TermsAndConditionsCoordinatorTests {

    @Test func start_invalidAcceptance_setsViewController() async throws {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let navigationController = UINavigationController()

        let sut = TermsAndConditionsCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            termsAndConditionsService: MockTermsAndConditionsService(),
            completion: { }
        )

        sut.start()

        #expect(navigationController.viewControllers.first is
                HostingViewController<InfoView<TermsAndConditionsViewModel>>)
    }

    @Test func start_validAcceptance_callCompletion() async throws {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockTermsAndConditionsService = MockTermsAndConditionsService()
        let navigationController = UINavigationController()

        mockTermsAndConditionsService._stubbedTermsAcceptanceIsValid = true
        var completionCalled = false
        let sut = TermsAndConditionsCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            termsAndConditionsService: mockTermsAndConditionsService,
            completion: {
                completionCalled = true
            }
        )

        sut.start()

        #expect(navigationController.viewControllers.isEmpty)
        #expect(completionCalled)
    }
}
