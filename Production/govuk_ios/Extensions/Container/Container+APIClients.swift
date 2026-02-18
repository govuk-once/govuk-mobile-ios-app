import Foundation

import FactoryKit
import GovKit

extension Container {
    var govukAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: Constants.API.govukBaseUrl,
                session: URLSession(configuration: .default),
                requestBuilder: RequestBuilder()
            )
        }
    }

    var appAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: self.appEnvironmentService().baseURL,
                session: URLSession(configuration: .default),
                requestBuilder: RequestBuilder()
            )
        }
    }

    func reregisterSearchAPIClient(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.path = ""
        components?.queryItems = nil
        let newClient = newSearchAPIClient(
            url: components?.url ?? Constants.API.defaultSearchUrl
        )
        searchAPIClient.register { newClient }
    }

    var searchAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            self.newSearchAPIClient(url: Constants.API.defaultSearchUrl)
        }
    }

    private func newSearchAPIClient(url: URL) -> APIServiceClient {
        APIServiceClient(
            baseUrl: url,
            session: self.urlSession(),
            requestBuilder: RequestBuilder()
        )
    }

    var localAuthorityAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: Constants.API.defaultLocalAuthorityURL,
                session: self.urlSession(),
                requestBuilder: RequestBuilder(),
                responseHandler: LocalAuthorityResponseHandler()
            )
        }
    }

    var revokeTokenAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: self.appEnvironmentService().tokenBaseURL,
                session: self.urlSession(),
                requestBuilder: URLEncodedRequestBuilder()
            )
        }
    }

    var chatAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: self.appEnvironmentService().chatBaseURL,
                session: self.urlSession(),
                requestBuilder: RequestBuilder(),
                responseHandler: ChatResponseHandler(),
                tokenProvider: self.authenticationService()
            )
        }
    }

    var userAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            // move to GovKit when hostname is final
            let defaultUserStateUrl: URL = URL(string: "https://d2nndycdmjjz2u.cloudfront.net")!
            return APIServiceClient(baseUrl: defaultUserStateUrl,
                                    session: self.urlSession(),
                                    requestBuilder: RequestBuilder(),
                                    responseHandler: UserResponseHandler(),
                                    tokenProvider: self.authenticationService())
        }
    }

    var urlSession: Factory<URLSession> {
        Factory(self) {
            URLSession(configuration: .default)
        }
    }
}
