import Foundation
import XCTest
import UIKit
import GovKit

@testable import govuk_ios

@MainActor class DVLADrivingLicenceViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_light_rendersCorrectly() async {
        let mockDvlaService = MockDVLAService()
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let viewModel = DVLADrivingLicenceViewModel(dvlaService: mockDvlaService)
        let view = DVLADrivingLicenceView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.fetchDrivingLicence()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .light
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() async {
        let mockDvlaService = MockDVLAService()
        mockDvlaService._stubbedFetchDrivingLicenceResult = .success(.arrange)
        let viewModel = DVLADrivingLicenceViewModel(dvlaService: mockDvlaService)
        let view = DVLADrivingLicenceView(viewModel: viewModel)
        let hostingViewController =  HostingViewController(
            rootView: view
        )
        await viewModel.fetchDrivingLicence()
        VerifySnapshotInNavigationController(
            viewController: hostingViewController,
            mode: .dark
        )
    }
}
