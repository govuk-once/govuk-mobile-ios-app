import Foundation
import UIKit
import Testing

@testable import govuk_ios


@Suite
struct AppConfigServiceTests {
    private var sut: AppConfigService!
    private var mockAppConfigServiceClient: MockAppConfigServiceClient!
    private var mockTermsAndConditionsServiceClient: MockTermsAndConditionsServiceClient!
    private var mockAnalyticsService: MockAnalyticsService!

    init() {
        mockAppConfigServiceClient = MockAppConfigServiceClient()
        mockAnalyticsService = MockAnalyticsService()
        mockTermsAndConditionsServiceClient = MockTermsAndConditionsServiceClient()
        sut = AppConfigService(
            appConfigServiceClient: mockAppConfigServiceClient,
            termsAndConditionsServiceClient: mockTermsAndConditionsServiceClient,
            analyticsService: mockAnalyticsService
        )
    }

    @Test
    func fetchAppConfig_termsAndConditionsNetworkError_setsForUpdate() async {
        mockAppConfigServiceClient._fetchAppConfigReturn = Config.arrange().toResult()
        mockTermsAndConditionsServiceClient._stubbedTermsAndConditionsResponse =
            .failure(.networkUnavailable)
        let result = await sut.fetchAppConfig()

        #expect(result.getError() == .networkUnavailable)
    }

    @Test
    func fetchAppConfig_termsAndConditionsAPIError_setsForUpdate() async {
        mockAppConfigServiceClient._fetchAppConfigReturn = Config.arrange().toResult()
        mockTermsAndConditionsServiceClient._stubbedTermsAndConditionsResponse =
            .failure(.apiUnavailable)
        let result = await sut.fetchAppConfig()

        #expect(result.getError() == .termsAndConditionsAPI)
        #expect(mockAnalyticsService._trackErrorReceivedErrors.count == 1)
    }

    @Test
    func fetchAppConfig_termsAndConditionsParsingError_setsForUpdate() async {
        mockAppConfigServiceClient._fetchAppConfigReturn = Config.arrange().toResult()
        mockTermsAndConditionsServiceClient._stubbedTermsAndConditionsResponse =
            .failure(.parsingError)
        let result = await sut.fetchAppConfig()

        #expect(result.getError() == .termsAndConditionsAPI)
        #expect(mockAnalyticsService._trackErrorReceivedErrors.count == 1)
    }

    @Test
    func fetchAppConfig_invalidSignatureError_setsForUpdate() async {
        mockAppConfigServiceClient._fetchAppConfigReturn = .failure(.invalidSignature)
        let result = await sut.fetchAppConfig()

        #expect(result.getError() == .invalidSignature)
        #expect(mockAnalyticsService._trackErrorReceivedErrors.count == 1)
    }

    @Test
    func fetchAppConfig_existingConfigValue_replacesValue() async {
        let configResult = Config.arrange(releaseFlags: [Feature.search.rawValue: false])
        mockAppConfigServiceClient._fetchAppConfigReturn = configResult.toResult()
        _ = await sut.fetchAppConfig()

        let updatedConfigResult = Config.arrange(releaseFlags: [Feature.search.rawValue: true])
        mockAppConfigServiceClient._fetchAppConfigReturn = updatedConfigResult.toResult()
        _ = await sut.fetchAppConfig()

        #expect(sut.isFeatureEnabled(key: .search))
    }

    @Test
    func fetchAppConfig_updatesChatPollingInterval() async {
        let configResult = Config.arrange(chatPollIntervalSeconds: 10).toResult()
        mockAppConfigServiceClient._fetchAppConfigReturn = configResult
        _ = await sut.fetchAppConfig()

        #expect(sut.chatPollIntervalSeconds == 10.0)
    }

    @Test
    func fetchAppConfig_missingPollingInterval_setsDefaultValue() async {
        let configResult = Config.arrange(chatPollIntervalSeconds: nil).toResult()
        mockAppConfigServiceClient._fetchAppConfigReturn = configResult
        _ = await sut.fetchAppConfig()

        #expect(sut.chatPollIntervalSeconds == 3.0)
    }

    @Test
    func fetchAppConfig_updatesRefreshTokenExpiry() async throws {
        let stubbedResult = Config.arrange(refreshTokenExpirySeconds: 5)
        mockAppConfigServiceClient._fetchAppConfigReturn = stubbedResult.toResult()
        let result = await sut.fetchAppConfig()
        #expect(try result.get().config.refreshTokenExpirySeconds == stubbedResult.refreshTokenExpirySeconds)

        mockAppConfigServiceClient._fetchAppConfigReturn = nil
        let stubbedResultTwo = Config.arrange(refreshTokenExpirySeconds: nil)
        mockAppConfigServiceClient._fetchAppConfigReturn = stubbedResultTwo.toResult()
        let resultTwo = await sut.fetchAppConfig()
        #expect(try resultTwo.get().config.refreshTokenExpirySeconds == stubbedResultTwo.refreshTokenExpirySeconds)

        mockAppConfigServiceClient._fetchAppConfigReturn = nil
        let stubbedResultThree = Config.arrange(refreshTokenExpirySeconds: 10)
        mockAppConfigServiceClient._fetchAppConfigReturn = stubbedResultThree.toResult()
        let resultThree = await sut.fetchAppConfig()
        #expect(try resultThree.get().config.refreshTokenExpirySeconds == stubbedResultThree.refreshTokenExpirySeconds)

        mockAppConfigServiceClient._fetchAppConfigReturn = nil
        let stubbedResultFour = Config.arrange(refreshTokenExpirySeconds: 15)
        mockAppConfigServiceClient._fetchAppConfigReturn = stubbedResultFour.toResult()
        let resultFour = await sut.fetchAppConfig()
        #expect(try resultFour.get().config.refreshTokenExpirySeconds == stubbedResultFour.refreshTokenExpirySeconds)
    }

    @Test
    func fetchAppConfig_zeroPollingInterval_setsDefaultValue() async {
        let configResult = Config.arrange(chatPollIntervalSeconds: 0).toResult()
        mockAppConfigServiceClient._fetchAppConfigReturn = configResult
        _ = await sut.fetchAppConfig()

        #expect(sut.chatPollIntervalSeconds == 3.0)
    }

    @Test
    func isFeatureEnabled_whenFeatureFlagIsSetToAvailable_returnsTrue() async {
        let result = Config.arrange(releaseFlags: ["search": true]).toResult()
        mockAppConfigServiceClient._fetchAppConfigReturn = result
        _ = await sut.fetchAppConfig()

        #expect(sut.isFeatureEnabled(key: .search))
    }

    @Test
    func isFeatureEnabled_whenFeatureFlagIsSetToUnavailable_returnsFalse() {
        let result = Config.arrange(releaseFlags: ["search": false]).toResult()
        mockAppConfigServiceClient._fetchAppConfigReturn = result

        #expect(sut.isFeatureEnabled(key: .search) == false)
    }

    @Test
    func isFeatureEnabled_whenFeatureFlagIsNotInConfig_returnsFalse() {
        let result = Config.arrange(releaseFlags: ["test": false]).toResult()
        mockAppConfigServiceClient._fetchAppConfigReturn = result

        #expect(sut.isFeatureEnabled(key: .search) == false)
    }

    @Test
    func isFeatureEnabled_whenFeatureFlagIsChat_returnsFalse() {
        let result = Config.arrange(releaseFlags: ["chat": true]).toResult()
        mockAppConfigServiceClient._fetchAppConfigReturn = result

        #expect(sut.isFeatureEnabled(key: .dvla) == false)
    }
}

private extension Config {
    func toResult() -> Result<AppConfig, AppConfigError> {
        let appConfig = AppConfig.arrange(
            config: self
        )
        return .success(appConfig)
    }
}
