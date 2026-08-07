import Foundation
import Testing
import UIKit

@testable import govuk_ios

@MainActor
@Suite
class DVLAAuthenticationCoordinatorTests {

    @Test
    func start_tokenRefreshSuccess_makesHashRequest() async throws {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .success(.arrange)
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(
                token: "test-token",
            )
        )

        let sut = DVLAAuthenticationCoordinator(
            navigationController: UINavigationController(),
            urlOpener: MockURLOpener(),
            authenticationService: mockAuthenticationService,
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService()
        )
        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))
        #expect(mockAuthenticationService._fetchIdentityVerificationCalled == true)
    }

    @Test
    func start_tokenRefreshFailure_presentsAlert() async throws {
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .failure(.genericError)
        let mockNavigationController = MockNavigationController()

        let sut = DVLAAuthenticationCoordinator(
            navigationController: mockNavigationController,
            urlOpener: MockURLOpener(),
            authenticationService: mockAuthenticationService,
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService()
        )
        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))
        #expect(mockNavigationController._setViewControllers?.first != nil)
    }

    @Test
    func start_hashRequestSuccess_opensURLWithVerificationToken() async throws {
        let mockURLOpener = MockURLOpener()
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedTokenRefreshRequest = .success(.arrange)
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(
                token: "test-token",
            )
        )
        let mockAppEnvironmentService = MockAppEnvironmentService()
        mockAppEnvironmentService.dvlaAuthenticationURL = URL(
            string: "https://customer-account-external-ui-ext.dvla.gov.uk/govuk-app"
        )!

        let sut = DVLAAuthenticationCoordinator(
            navigationController: UINavigationController(),
            urlOpener: mockURLOpener,
            authenticationService: mockAuthenticationService,
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: mockAppEnvironmentService,
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        let openedURL = try #require(mockURLOpener._receivedOpenIfPossibleUrl)
        #expect(openedURL.host == "customer-account-external-ui-ext.dvla.gov.uk")
        let queryItems = URLComponents(url: openedURL, resolvingAgainstBaseURL: false)?.queryItems
        let verificationItem = queryItems?.first { $0.name == "verification" }
        #expect(verificationItem?.value == "test-token")
    }

    @Test
    @MainActor
    func start_hashRequestSuccess_doesNotPresentAlert() async throws {
        let mockURLOpener = MockURLOpener()
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .success(
            .init(
                token: "test-token",
            )
        )
        let mockNavigationController = MockNavigationController()
        let sut = DVLAAuthenticationCoordinator(
            navigationController: mockNavigationController,
            urlOpener: mockURLOpener,
            authenticationService: mockAuthenticationService,
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService(),
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        #expect(mockNavigationController._presentedViewController == nil)
    }

    @Test
    @MainActor
    func start_hashRequestFailure_presentsErrorAlert() async throws {
        let mockURLOpener = MockURLOpener()
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .failure(.apiUnavailable)
        let mockNavigationController = MockNavigationController()
        let sut = DVLAAuthenticationCoordinator(
            navigationController: mockNavigationController,
            urlOpener: mockURLOpener,
            authenticationService: mockAuthenticationService,
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService(),
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        #expect(mockNavigationController._setViewControllers?.first != nil)
        #expect(mockURLOpener._receivedOpenIfPossibleUrl == nil)
    }

    @Test
    @MainActor
    func start_hashRequestFailure_doesNotOpenURL() async throws {
        let mockURLOpener = MockURLOpener()
        let mockAuthenticationService = MockAuthenticationService()
        mockAuthenticationService._stubbedFetchIdentityVerificationResult = .failure(.networkUnavailable)
        let sut = DVLAAuthenticationCoordinator(
            navigationController: UINavigationController(),
            urlOpener: mockURLOpener,
            authenticationService: mockAuthenticationService,
            analyticsService: MockAnalyticsService(),
            appEnvironmentService: MockAppEnvironmentService(),
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        #expect(mockURLOpener._receivedOpenIfPossibleUrl == nil)
    }
}
