import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct AppUnavailableCoordinatorTests {
    @Test
    func start_whenErrorIsNil_callsDismiss() async {
        await withCheckedContinuation { continuation in
            let sut = AppUnavailableCoordinator(
                navigationController: UINavigationController(),
                error: nil,
                retryAction: { _ in },
                dismissAction: {
                    continuation.resume()
                }
            )
            sut.start()
        }
    }

    @Test
    func start_whenErrorIsNotNil_doesntCallDismiss() async throws {
        let started: Bool = try await withCheckedThrowingContinuation { continuation in
            let sut = AppUnavailableCoordinator(
                navigationController: UINavigationController(),
                error: .appConfig,
                retryAction: { _ in },
                dismissAction: {
                    continuation.resume(throwing: TestError.unexpectedMethodCalled)
                }
            )
            sut.start()
            continuation.resume(returning: true)
        }
        #expect(started)
    }
}
