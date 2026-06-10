import SwiftUI
import GovKit
import GovKitUI

struct DVLAAccountSummaryView: View {
    @StateObject private var viewModel: DVLAAccountSummaryViewModel

    init(viewModel: DVLAAccountSummaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            VStack {
                VehiclesView(viewModel: viewModel.vehiclesViewModel)
                DrivingLicenceView(viewModel: viewModel.licenceViewModel)
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
    }
}
