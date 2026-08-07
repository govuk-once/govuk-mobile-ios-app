import Foundation

final class DVLAAuthenticationViewModel: ObservableObject {
    private let authenticationService: AuthenticationServiceInterface
    private let appEnvironmentService: AppEnvironmentServiceInterface
    private let completionAction: (URL) -> Void
    private let errorAction: () -> Void

    init(authenticationService: AuthenticationServiceInterface,
         appEnvironmentService: AppEnvironmentServiceInterface,
         completionAction: @escaping (URL) -> Void,
         errorAction: @escaping () -> Void) {
        self.authenticationService = authenticationService
        self.appEnvironmentService = appEnvironmentService
        self.completionAction = completionAction
        self.errorAction = errorAction
    }

    @MainActor
    func fetchIdentityVerification() async {
        let result = await authenticationService.fetchIdentityVerification()
        switch result {
        case .success(let result):
            authenticate(
                token: result.token,
            )
        case .failure:
            errorAction()
        }
    }

    @MainActor
    private func authenticate(token: String) {
        let authenticationUrl = appEnvironmentService.dvlaAuthenticationURL
        var components = URLComponents(
            url: authenticationUrl,
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = [
            .init(name: "token", value: token),
        ]
        if let url = components?.url {
            completionAction(url)
        } else {
            errorAction()
        }
    }
}
