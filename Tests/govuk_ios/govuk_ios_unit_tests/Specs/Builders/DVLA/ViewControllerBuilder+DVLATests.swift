import Foundation
import Testing
import UIKit
import GovKit

@testable import govuk_ios

@Suite
@MainActor
struct ViewControllerBuilderDVLATests {

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

        let rootView = (result as? HostingViewController<VehicleCheckResultView>)?.rootView
        #expect(rootView != nil)
    }

    @Test
    func licenceCategoryDetail_returnsExpectedResult() throws {
        let sut = ViewControllerBuilder()
        let result = sut.licenceCategoryDetail(
            entitlement: .arrange,
            analyticsService: MockAnalyticsService(),
            dismissAction: {}
        )

        let rootView = (result as? HostingViewController<LicenceCategoryDetailView>)?.rootView
        #expect(rootView != nil)
    }
}
