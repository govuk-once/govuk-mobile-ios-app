import Foundation

import FactoryKit
import GovKit

extension Container {
    var govukAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: Constants.API.govukBaseUrl,
                session: URLSession(configuration: .default),
                requestBuilder: RequestBuilder(),
                analyticsService: self.analyticsService()
            )
        }
    }

    var appAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: self.appEnvironmentService().baseURL,
                session: URLSession(configuration: .default),
                requestBuilder: RequestBuilder(),
                analyticsService: self.analyticsService()
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
            requestBuilder: RequestBuilder(),
            analyticsService: self.analyticsService()
        )
    }

    var localAuthorityAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: Constants.API.defaultLocalAuthorityURL,
                session: self.urlSession(),
                requestBuilder: RequestBuilder(),
                analyticsService: self.analyticsService(),
                responseHandler: LocalAuthorityResponseHandler()
            )
        }
    }

    var revokeTokenAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: self.appEnvironmentService().tokenBaseURL,
                session: self.urlSession(),
                requestBuilder: URLEncodedRequestBuilder(),
                analyticsService: self.analyticsService()
            )
        }
    }

    var chatAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(
                baseUrl: self.appEnvironmentService().chatBaseURL,
                session: self.urlSession(),
                requestBuilder: RequestBuilder(),
                analyticsService: self.analyticsService(),
                responseHandler: ChatResponseHandler(),
                tokenProvider: self.authenticationService()
            )
        }
    }

    var userAPIClient: Factory<APIServiceClientInterface> {
        Factory(self) {
            APIServiceClient(baseUrl: self.appEnvironmentService().flexBaseURL,
                             session: self.urlSession(),
                             requestBuilder: RequestBuilder(),
                             analyticsService: self.analyticsService(),
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
