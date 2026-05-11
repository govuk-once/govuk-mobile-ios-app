import Foundation

@testable import govuk_ios

class MockAppConfigServiceClient: AppConfigServiceClientInterface {
    var _fetchAppConfigReturn: FetchAppConfigResult? = .failure(.configAPI)
    func fetchAppConfig(completion: @escaping FetchAppConfigCompletion) {
        if let _fetchAppConfigReturn {
            completion(_fetchAppConfigReturn)
        }
    }
}
