import Foundation
import FactoryKit
import GovKit

protocol AppConfigServiceInterface {
    func fetchAppConfig() async -> FetchAppConfigResult
    func isFeatureEnabled(key: Feature) -> Bool
    var chatPollIntervalSeconds: TimeInterval { get }
    var alertBanner: AlertBanner? { get }
    var chatBanner: ChatBanner? { get }
    var userFeedbackBanner: UserFeedbackBanner? { get }
    var emergencyBanners: [EmergencyBanner]? { get }
    var chatUrls: ChatURLs? { get }
    var refreshTokenExpirySeconds: Int? { get }
    var termsAndConditions: TermsAndConditions? { get }
}

public final class AppConfigService: AppConfigServiceInterface {
    private var featureFlags: [String: Bool] = [:]

    private let appConfigServiceClient: AppConfigServiceClientInterface
    private let termsAndConditionsServiceClient: TermsAndConditionsServiceClientInterface
    private let analyticsService: AnalyticsServiceInterface
    private var retryInterval: Int?

    var chatPollIntervalSeconds: TimeInterval = 3.0
    var alertBanner: AlertBanner?
    var chatBanner: ChatBanner?
    var userFeedbackBanner: UserFeedbackBanner?
    var emergencyBanners: [EmergencyBanner]?
    private(set) var chatUrls: ChatURLs?
    private(set) var refreshTokenExpirySeconds: Int?
    private(set) var termsAndConditions: TermsAndConditions?

    init(appConfigServiceClient: AppConfigServiceClientInterface,
         termsAndConditionsServiceClient: TermsAndConditionsServiceClientInterface,
         analyticsService: AnalyticsServiceInterface) {
        self.appConfigServiceClient = appConfigServiceClient
        self.termsAndConditionsServiceClient = termsAndConditionsServiceClient
        self.analyticsService = analyticsService
    }

    func fetchAppConfig() async -> FetchAppConfigResult {
        let result  = await withCheckedContinuation { continuation in
            appConfigServiceClient.fetchAppConfig(
                completion: { result in
                    continuation.resume(returning: result)
                }
            )
        }
        return await configuredResult(result)
    }

    private func configuredResult(_ result: FetchAppConfigResult) async -> FetchAppConfigResult {
        switch result {
        case .success(let appConfig):
            let config = appConfig.config
            setConfig(config)

            let termsResult = await updateTermsAndConditions(
                config.termsAndConditions.contentItemApiPath
            )

            switch termsResult {
            case .success:
                return .success(appConfig)
            case .failure(let error):
                return .failure(error)
            }

        case .failure(let error):
            analyticsService.track(error: error)
            return .failure(error)
        }
    }

    private func setConfig(_ config: Config) {
        self.featureFlags = self.featureFlags.merging(
            config.releaseFlags,
            uniquingKeysWith: { _, new in
                new
            }
        )

        updateSearch(urlString: config.searchApiUrl)
        updateChatPollInterval(config.chatPollIntervalSeconds)
        updateTokenExpirySeconds(config.refreshTokenExpirySeconds)

        emergencyBanners = config.emergencyBanners
        chatBanner = config.chatBanner
        userFeedbackBanner = config.userFeedbackBanner
        chatUrls = config.chatUrls
        termsAndConditions = config.termsAndConditions
    }

    private func updateChatPollInterval(_ interval: TimeInterval?) {
        guard let pollInterval = interval,
              pollInterval > 0 else {
            return
        }
        chatPollIntervalSeconds = pollInterval
    }

    private func updateTokenExpirySeconds(_ expiry: Int?) {
        refreshTokenExpirySeconds = expiry
    }

    private func updateSearch(urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return }
        Constants.API.defaultSearchPath = components.path
        Container.shared.reregisterSearchAPIClient(url: url)
    }

    private func updateTermsAndConditions(_ path: String) async -> Result<Void, AppConfigError> {
        let result: TermsAndConditionsResult = await
        termsAndConditionsServiceClient.termsAndConditions(path: path)

        switch result {
        case .success(let terms):
            termsAndConditions?.lastUpdated = terms.publicUpdatedAt
            return .success(())
        case .failure(let error):
            if error == .networkUnavailable {
                return .failure(.networkUnavailable)
            } else {
                analyticsService.track(error: error)
                return .failure(.termsAndConditionsAPI)
            }
        }
    }

    func isFeatureEnabled(key: Feature) -> Bool {
        return featureFlags[key.rawValue] ?? false
    }
}
