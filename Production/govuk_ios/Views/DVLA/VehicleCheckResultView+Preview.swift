import SwiftUI

struct VehicleCheckResultViewContainer: View {
    let viewModel: VehicleCheckResultViewModel

    init() {
        let actions = VehicleCheckResultActions(
            openURLAction: { _ in },
            searchAction: { },
            dismissAction: { }
        )

        let analyticsService = MockAnalyticsService()
        let configService = MockAppConfigService()

        self.viewModel = VehicleCheckResultViewModel(
            vehicle: Self.mockVehicle,
            analyticsService: analyticsService,
            configService: configService,
            actions: actions
        )
    }

    var body: some View {
        VehicleCheckResultView(viewModel: viewModel)
    }
}

extension VehicleCheckResultViewContainer {
    private static var mockVehicle: VehicleEnquiryResponse.Vehicle {
        .init(
            vehicleId: 100830769,
            registrationNumber: "DF04 FSY",
            taxStatus: .taxed,
            taxedUntil: Date(timeIntervalSince1970: 1793491200),
            motStatus: .valid,
            motExpiryDate: Date(timeIntervalSince1970: 1793491200),
            make: "FORD",
            dateOfFirstRegistration: Date(timeIntervalSince1970: 1083369600),
            engineCapacity: 1242,
            exhaustEmissionsCo2: 147,
            fuelType: .petrol,
            colour: "BLACK",
            secondaryColour: nil
        )
    }
}

#Preview("VehicleCheckResultView") {
    VehicleCheckResultViewContainer()
}

import GovKit

class MockAnalyticsService: AnalyticsServiceInterface {
    var _setExistingConsentCalled: Bool = false
    func setExistingConsent() {
        _setExistingConsentCalled = true
    }

    var _launchCalled: Bool = false
    func launch() {
        _launchCalled = true
    }

    var _trackedEvents: [AppEvent] = []
    func track(event: AppEvent) {
        _trackedEvents.append(event)
    }

    var _trackScreenReceivedScreens: [TrackableScreen] = []
    func track(screen: TrackableScreen) {
        _trackScreenReceivedScreens.append(screen)
    }

    var _trackErrorReceivedErrors: [Error] = []
    func track(error: any Error) {
        _trackErrorReceivedErrors.append(error)
    }

    var _trackSetUserPropertyReceivedProperty: UserProperty?
    func set(userProperty: UserProperty) {
        _trackSetUserPropertyReceivedProperty = userProperty
    }

    var _resetConsentCalled: Bool = false
    func resetConsent() {
        _resetConsentCalled = true
    }

    var _setAcceptedAnalyticsAccepted: Bool = true
    func setAcceptedAnalytics(accepted: Bool) {
        _setAcceptedAnalyticsAccepted = accepted
        _stubbedPermissionState = accepted ? .accepted : .denied
    }

    var _stubbedPermissionState: AnalyticsPermissionState = .accepted
    var permissionState: AnalyticsPermissionState {
        _stubbedPermissionState
    }
}

class MockAppConfigService: AppConfigServiceInterface {
    var _stubbedChatExampleQuestions: [String]?
    var chatExampleQuestions: [String]? {
        _stubbedChatExampleQuestions
    }

    var refreshTokenExpirySeconds: Int?

    var _stubbedChatPollIntervalSeconds: TimeInterval = 3.0
    var chatPollIntervalSeconds: TimeInterval {
        _stubbedChatPollIntervalSeconds
    }

    var isAppAvailable: Bool = false

    var isAppForcedUpdate: Bool = false

    var isAppRecommendUpdate: Bool = false

    var features: [Feature] = [
        .onboarding,
        .search,
        .topics,
        .recentActivity,
        .localServices,
        .dvla,
        .messages,
        .travelAlerts,
        .quarterlySurvey
    ]

    var _stubbedAlertBanner: AlertBanner?
    var alertBanner: AlertBanner? {
        _stubbedAlertBanner
    }

    var _stubbedChatBanner: ChatBanner?
    var chatBanner: ChatBanner? {
        _stubbedChatBanner
    }

    var _stubbedChatBannerLink: ChatBanner.Link = .init(
        title: "test",
        url: URL(string: "https://test.com")!
    )
    var chatBannerLink: ChatBanner.Link {
        _stubbedChatBannerLink
    }

    var _stubbedEmergencyBanners: [EmergencyBanner]?
    var emergencyBanners: [EmergencyBanner]? {
        _stubbedEmergencyBanners
    }

    var _stubbedEmergencyBannerLink: EmergencyBanner.Link = .init(
        title: "test",
        url: URL(string: "https://test.com")!
    )

    var _stubbedChatUrls: ChatURLs?
    var chatUrls: ChatURLs? {
        _stubbedChatUrls
    }

    var _dvlaUrls: DvlaURLs?
    var dvlaUrls: DvlaURLs? {
        _dvlaUrls
    }

    var _receivedFetchAppConfigCompletion: FetchAppConfigCompletion?
    var _stubbedFetchAppConfigResult: FetchAppConfigResult = .failure(.configAPI)
    var _stubbedTermsAndConditions: TermsAndConditions?
    var termsAndConditions: TermsAndConditions? {
        _stubbedTermsAndConditions
    }

    func fetchAppConfig() async -> FetchAppConfigResult {
        _stubbedFetchAppConfigResult
    }

    func isFeatureEnabled(key: Feature) -> Bool {
        features.contains(key)
    }

    var _stubbedPromoBanners: [PromoBanner]? = nil
    var promoBanners: [PromoBanner]? {
        _stubbedPromoBanners
    }

    var _stubbedPromoBannersLink: PromoBanner.Link = .init(
        title: "test",
        url: URL(string: "https://test.com")!
    )
    var promoBannersLink: PromoBanner.Link {
        _stubbedPromoBannersLink
    }
}
