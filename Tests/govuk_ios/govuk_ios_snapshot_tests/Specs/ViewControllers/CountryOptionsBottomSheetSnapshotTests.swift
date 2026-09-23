import Foundation
import XCTest
import UIKit
import SwiftUI
import GovKit

@testable import govuk_ios

@MainActor
final class CountryOptionsBottomSheetSnapshotTests: SnapshotTestCase {

    func test_notificationsDisabled_light_rendersCorrectly() {
        let view = CountryOptionsBottomSheet(
            country: Self.testCountry,
            notificationsEnabled: .constant(false),
            isTogglingNotifications: false,
            isUnfollowing: false,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_notificationsDisabled_dark_rendersCorrectly() {
        let view = CountryOptionsBottomSheet(
            country: Self.testCountry,
            notificationsEnabled: .constant(false),
            isTogglingNotifications: false,
            isUnfollowing: false,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_notificationsEnabled_light_rendersCorrectly() {
        let view = CountryOptionsBottomSheet(
            country: Self.testCountry,
            notificationsEnabled: .constant(true),
            isTogglingNotifications: false,
            isUnfollowing: false,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_notificationsEnabled_dark_rendersCorrectly() {
        let view = CountryOptionsBottomSheet(
            country: Self.testCountry,
            notificationsEnabled: .constant(true),
            isTogglingNotifications: false,
            isUnfollowing: false,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_unfollowing_light_rendersCorrectly() {
        let view = CountryOptionsBottomSheet(
            country: Self.testCountry,
            notificationsEnabled: .constant(true),
            isTogglingNotifications: false,
            isUnfollowing: true,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_unfollowing_dark_rendersCorrectly() {
        let view = CountryOptionsBottomSheet(
            country: Self.testCountry,
            notificationsEnabled: .constant(true),
            isTogglingNotifications: false,
            isUnfollowing: true,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_longCountryName_light_rendersCorrectly() {
        let longNameCountry = Country(
            name: "Bosnia and Herzegovina",
            slug: "bosnia-and-herzegovina",
            rawLastUpdate: "2024-01-01T00:00:00.000Z",
            synonyms: []
        )
        let view = CountryOptionsBottomSheet(
            country: longNameCountry,
            notificationsEnabled: .constant(false),
            isTogglingNotifications: false,
            isUnfollowing: false,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_longCountryName_dark_rendersCorrectly() {
        let longNameCountry = Country(
            name: "Bosnia and Herzegovina",
            slug: "bosnia-and-herzegovina",
            rawLastUpdate: "2024-01-01T00:00:00.000Z",
            synonyms: []
        )
        let view = CountryOptionsBottomSheet(
            country: longNameCountry,
            notificationsEnabled: .constant(false),
            isTogglingNotifications: false,
            isUnfollowing: false,
            toggleError: nil,
            onNotificationsToggle: { _ in },
            onUnfollow: {},
            onClearToggleError: {}
        )
        let viewController = makeViewController(view: view)

        VerifySnapshotInNavigationController(
            viewController: viewController,
            mode: .dark,
            navBarHidden: true
        )
    }

    private func makeViewController(view: CountryOptionsBottomSheet) -> UIViewController {
        let viewController = HostingViewController(rootView: view)
        viewController.view.backgroundColor = .govUK.fills.surfaceModal
        return viewController
    }
}

private extension CountryOptionsBottomSheetSnapshotTests {
    static let testCountry = Country(
        name: "France",
        slug: "france",
        rawLastUpdate: "2024-01-01T00:00:00.000Z",
        synonyms: []
    )
}
