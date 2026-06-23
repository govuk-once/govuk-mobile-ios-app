import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLAAccountViewSnapshotTests: SnapshotTestCase {
    func test_loadVehicleInNavigationController_light_rendersCorrectly() async {
        let mockDvlaService = MockDVLAService()
        mockDvlaService._stubbedFetchVehicleResult = .success(.arrange)
        let viewModel = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .vehicle
        )
        let view = DVLAAccountView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.fetchContent()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_loadShareCodesInNavigationController_light_rendersCorrectly() async {
        let mockDvlaService = MockDVLAService()
        mockDvlaService._stubbedFetchShareCodesResult = .success(.arrange)
        let viewModel = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .shareCodeList
        )
        let view = DVLAAccountView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.fetchContent()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_loadCreateShareCodeInNavigationController_light_rendersCorrectly() async {
        let mockDvlaService = MockDVLAService()
        mockDvlaService._stubbedCreateShareCodeResult = .success(.arrange)
        let viewModel = DVLAAccountViewModel(
            dvlaService: mockDvlaService,
            viewType: .createShareCode
        )
        let view = DVLAAccountView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.fetchContent()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }
}
