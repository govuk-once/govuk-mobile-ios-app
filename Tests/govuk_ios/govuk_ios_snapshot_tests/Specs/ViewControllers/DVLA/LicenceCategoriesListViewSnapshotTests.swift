import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor
class LicenceCategoriesListViewSnapshotTests: SnapshotTestCase {

//    override func setUp() {
//        super.setUp()
//       self.recordMode = true
//    }


    // MARK: - Full list (both sections + links)

    func test_fullList_light_rendersCorrectly() {
        let hostingViewController = HostingViewController(rootView: LicenceCategoriesView(viewModel: fullListViewModel))
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    func test_fullList_dark_rendersCorrectly() {
        let hostingViewController = HostingViewController(rootView: LicenceCategoriesView(viewModel: fullListViewModel))
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark,
            prefersLargeTitles: true
        )
    }

    // MARK: - Only "you can drive" section (exercises provisional empty guard)

    func test_entitledOnlySection_light_rendersCorrectly() {
        let viewModel = LicenceCategoriesViewModel(
            entitledToDrive: [
                EntitlementGroup(group: .cars, entitlements: [
                    .arrange(categoryCode: "B"),
                    .arrange(categoryCode: "BE")
                ])
            ],
            provisionallyEntitledToDrive: [],
            actions: CategoriesActions(
                didSelectAction: { _ in },
                openURLAction: { _ in },
                dismissAction: {}
            ),
            links: [
                CategoryLink(text: "Check penalty points", url: URL(string: "https://www.gov.uk/penalty-points-endorsements")!)
            ],
            analyticsService: MockAnalyticsService()
        )
        let hostingViewController = HostingViewController(rootView: LicenceCategoriesView(viewModel: viewModel))
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    // MARK: - Non-tappable rows (exercises EntitlementRowView without button, RowHighlightButtonStyle showsHighlight:false)

    func test_nonTappableRows_light_rendersCorrectly() {
        let viewModel = LicenceCategoriesViewModel(
            entitledToDrive: [
                EntitlementGroup(group: .cars, entitlements: [.arrange(categoryCode: "B")])
            ],
            provisionallyEntitledToDrive: [],
            showsRowHighlight: false,
            actions: CategoriesActions(
                didSelectAction: nil,
                openURLAction: nil,
                dismissAction: {}
            ),
            links: [],
            analyticsService: MockAnalyticsService()
        )
        let hostingViewController = HostingViewController(rootView: LicenceCategoriesView(viewModel: viewModel))
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light,
            prefersLargeTitles: true
        )
    }

    // MARK: - Helpers

    private var fullListViewModel: LicenceCategoriesViewModel {
        LicenceCategoriesViewModel(
            entitledToDrive: [
                EntitlementGroup(group: .cars, entitlements: [
                    .arrange(categoryCode: "B"),
                    .arrange(categoryCode: "BE")
                ]),
                EntitlementGroup(group: .otherVehicles, entitlements: [
                    .arrange(categoryCode: "l")
                ])
            ],
            provisionallyEntitledToDrive: [
                EntitlementGroup(group: .motorcycles, entitlements: [
                    .arrange(categoryCode: "A", categoryType: .provisional)
                ])
            ],
            actions: CategoriesActions(
                didSelectAction: { _ in },
                openURLAction: { _ in },
                dismissAction: {}
            ),
            links: [
                CategoryLink(
                    text: "Check penalty points",
                    url: URL(string: "https://www.gov.uk/penalty-points-endorsements")!
                ),
                CategoryLink(
                    text: "Driving theory test",
                    url: URL(string: "https://www.gov.uk/theory-test")!
                )
            ],
            analyticsService: MockAnalyticsService()
        )
    }
}
