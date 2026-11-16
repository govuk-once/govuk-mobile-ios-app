import Foundation
import GovKit
import SwiftUI
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct ViewControllerBuilderDVLATests {

    @Test
    func vehicleDetail_returnsExpectedResult() {
        let subject = ViewControllerBuilder()
        let result = subject.vehicleDetail(
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            vehicleId: 123
        )

        let hostingController = result as? HostingViewController<VehicleDetailView>
        #expect(hostingController?.rootView != nil)
        #expect(hostingController?.hidesBottomBarWhenPushed == true)
    }

    @Test
    func dvlaAuthentication_returnsExpectedResult() {
        let subject = ViewControllerBuilder()
        let result = subject.dvlaAuthentication(
            authenticationService: MockAuthenticationService(),
            appEnvironmentService: MockAppEnvironmentService(),
            completionAction: { _ in },
            errorAction: { }
        )

        let rootView = (result as? HostingViewController<DVLAAuthenticationView>)?.rootView
        #expect(rootView != nil)
    }

    @Test
    func vehicleCheckResult_returnsExpectedResult() {
        let subject = ViewControllerBuilder()
        let result = subject.vehicleCheckResult(
            vehicle: .arrange,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            actions: VehicleCheckResultActions(
                openURLAction: { _ in },
                searchAction: { },
                dismissAction: { }
            )
        )

        let hostingController = result as? HostingViewController<VehicleCheckResultView>
        #expect(hostingController?.rootView != nil)
        #expect(hostingController?.shouldAutoFocusVoiceover == false)
    }

    @Test
    func vehicleRegistrationInput_returnsExpectedResult() {
        let subject = ViewControllerBuilder()
        let result = subject.vehicleRegistrationInput(
            analyticsService: MockAnalyticsService(),
            dvlaService: MockDVLAService(),
            cancelAction: { },
            completionAction: { _ in }
        )

        let hostingController = result as? UIHostingController<RegistrationNumberFormModal>
        #expect(hostingController?.rootView != nil)
        #expect(hostingController?.view.backgroundColor == .clear)
    }

    @Test
    func licenceCategoryList_withDefaultUrls_returnsExpectedResult() {
        let configService = MockAppConfigService()
        configService._dvlaUrls = nil

        let subject = ViewControllerBuilder()
        let result = subject.licenceCategoryList(
            entitlements: [.arrange],
            analyticsService: MockAnalyticsService(),
            configService: configService,
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: { }
            )
        )

        let rootView = (result as? HostingViewController<LicenceCategoriesView>)?.rootView
        #expect(rootView != nil)
    }

    @Test
    func licenceCategoryList_withConfiguredUrls_returnsExpectedResult() {
        let configService = MockAppConfigService()
        let dvlaURLs = DvlaURLs.arrange
        configService._dvlaUrls = dvlaURLs

        let subject = ViewControllerBuilder()
        let result = subject.licenceCategoryList(
            entitlements: [.arrange],
            analyticsService: MockAnalyticsService(),
            configService: configService,
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: { }
            )
        )

        let rootView = (result as? HostingViewController<LicenceCategoriesView>)?.rootView
        #expect(rootView != nil)
    }

    @Test
    func licenceCategoryDetail_returnsExpectedResult() {
        let subject = ViewControllerBuilder()
        let result = subject.licenceCategoryDetail(
            entitlement: .arrange,
            analyticsService: MockAnalyticsService(),
            dismissAction: { }
        )

        let rootView = (result as? HostingViewController<LicenceCategoryDetailView>)?.rootView
        #expect(rootView != nil)
    }
}
