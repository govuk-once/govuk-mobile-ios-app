import XCTest
import SwiftUI
import FactoryKit
@testable import govuk_ios

@MainActor
final class RegistrationNumberFormModalSnapshotTests: SnapshotTestCase {

    // MARK: - Snapshot Tests (Synchronous / No Delay)

    func test_modal_lightMode() {
        let view = makeModalView()
        verifyModalSnapshot(view: view, mode: .light)
    }

    func test_modal_darkMode() {
        let view = makeModalView()
        verifyModalSnapshot(view: view, mode: .dark)
    }

    func test_modal_withPrefilledText() {
        let viewModel = makeViewModel()
        viewModel.numberPlate = "SW54 YUP"

        let view = makeModalView(viewModel: viewModel)
        verifyModalSnapshot(view: view, mode: .light)
    }


    // MARK: - Synchronous Verification Helper

    private func verifyModalSnapshot(
        view: some View,
        mode: UIUserInterfaceStyle,
        overallTolerance: CGFloat = 0.001,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let hostingController = UIHostingController(rootView: view)
        hostingController.overrideUserInterfaceStyle = mode
        hostingController.view.backgroundColor = .clear

        wrapInWindow(hostingController)

        // force synchronous layout passes for SwiftUI and UIKit
        if let window = UIApplication.shared.window {
            hostingController.view.frame = window.bounds
            window.layoutIfNeeded()
        }
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        CATransaction.flush()

        // verify immediately using base class helper
        VerifySnapshotInWindow(
            hostingController,
            overallTolerance: overallTolerance,
            file: file,
            line: line
        )
    }

    // MARK: - Factory Helpers

    private func makeModalView(
        viewModel: RegistrationNumberFormViewModel? = nil
    ) -> RegistrationNumberFormModal {
        RegistrationNumberFormModal(
            viewModel: viewModel ?? makeViewModel(),
            cancelAction: {},
            submitAction: { _ in }
        )
    }

    private func makeViewModel() -> RegistrationNumberFormViewModel {
        let stubbedSubmitAction: RegistrationNumberSubmitAction = { _ in
            .success(VehicleEnquiryResponse.Vehicle.arrange)
        }
        return RegistrationNumberFormViewModel(submitAction: stubbedSubmitAction)
    }
}
