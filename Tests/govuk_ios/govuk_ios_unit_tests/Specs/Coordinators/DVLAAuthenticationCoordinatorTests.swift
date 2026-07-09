import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
class DVLAAuthenticationCoordinatorTests {

    @Test
    @MainActor
    func start_success_opensURLWithVerificationToken() async throws {
        let mockURLOpener = MockURLOpener()
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedFetchIdentityVerificationResult = .success(
            .init(verificationHash: "test-token")
        )
        let sut = DVLAAuthenticationCoordinator(
            navigationController: UINavigationController(),
            urlOpener: mockURLOpener,
            dvlaService: mockDVLAService,
            analticsService: MockAnalyticsService(),
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        let openedURL = try #require(mockURLOpener._receivedOpenIfPossibleUrl)
        #expect(openedURL.host == "architecture-link-account-service-ui-ext.dvla.gov.uk")
        let queryItems = URLComponents(url: openedURL, resolvingAgainstBaseURL: false)?.queryItems
        let verificationItem = queryItems?.first { $0.name == "verification" }
        #expect(verificationItem?.value == "test-token")
    }

    @Test
    @MainActor
    func start_success_doesNotPresentAlert() async throws {
        let mockURLOpener = MockURLOpener()
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedFetchIdentityVerificationResult = .success(
            .init(verificationHash: "test-token")
        )
        let mockNavigationController = MockNavigationController()
        let sut = DVLAAuthenticationCoordinator(
            navigationController: mockNavigationController,
            urlOpener: mockURLOpener,
            dvlaService: mockDVLAService,
            analticsService: MockAnalyticsService(),
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        #expect(mockNavigationController._presentedViewController == nil)
    }

    @Test
    @MainActor
    func start_failure_presentsErrorAlert() async throws {
        let mockURLOpener = MockURLOpener()
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedFetchIdentityVerificationResult = .failure(.apiUnavailable)
        let mockNavigationController = MockNavigationController()
        let sut = DVLAAuthenticationCoordinator(
            navigationController: mockNavigationController,
            urlOpener: mockURLOpener,
            dvlaService: mockDVLAService,
            analticsService: MockAnalyticsService(),
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        #expect(mockNavigationController._setViewControllers?.first != nil)
        #expect(mockURLOpener._receivedOpenIfPossibleUrl == nil)
    }

    @Test
    @MainActor
    func start_failure_doesNotOpenURL() async throws {
        let mockURLOpener = MockURLOpener()
        let mockDVLAService = MockDVLAService()
        mockDVLAService._stubbedFetchIdentityVerificationResult = .failure(.networkUnavailable)
        let sut = DVLAAuthenticationCoordinator(
            navigationController: UINavigationController(),
            urlOpener: mockURLOpener,
            dvlaService: mockDVLAService,
            analticsService: MockAnalyticsService(),
        )

        sut.start(url: nil)
        try await Task.sleep(for: .milliseconds(100))

        #expect(mockURLOpener._receivedOpenIfPossibleUrl == nil)
    }
}
