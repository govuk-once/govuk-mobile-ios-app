import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
class DVLAAuthenticationCoordinatorTests {

    @Test
    @MainActor
    func start_authenticationSuccess_callsCompletion() async {
        let mockAuthenticationService = MockDVLAAuthenticationService()
        mockAuthenticationService._stubbedAuthenticationResult = .success("link-id")

        let mockNavigationController = MockNavigationController()
        let newWindow = UIWindow(frame: UIScreen.main.bounds)
        newWindow.rootViewController = mockNavigationController
        newWindow.makeKeyAndVisible()

        let result = await withCheckedContinuation { continuation in
            let sut = DVLAAuthenticationCoordinator(
                navigationController: mockNavigationController,
                authenticationService: mockAuthenticationService,
                completion: { linkId in
                    continuation.resume(returning: linkId)
                },
                errorAction: { _ in }
            )
            sut.start()
        }
        #expect(result == "link-id")
    }

    @Test
    @MainActor
    func start_authenticationFailure_callsErrorAction() async {
        let mockAuthenticationService = MockDVLAAuthenticationService()
        mockAuthenticationService._stubbedAuthenticationResult = .failure(.tokenNotFound)

        let mockNavigationController = MockNavigationController()
        let newWindow = UIWindow(frame: UIScreen.main.bounds)
        newWindow.rootViewController = mockNavigationController
        newWindow.makeKeyAndVisible()

        let error = await withCheckedContinuation { continuation in
            let sut = DVLAAuthenticationCoordinator(
                navigationController: mockNavigationController,
                authenticationService: mockAuthenticationService,
                completion: { _ in

                },
                errorAction: { error in
                    continuation.resume(returning: error)
                }
            )
            sut.start()
        }
        #expect(error == DVLAAuthError.tokenNotFound)
    }
}
