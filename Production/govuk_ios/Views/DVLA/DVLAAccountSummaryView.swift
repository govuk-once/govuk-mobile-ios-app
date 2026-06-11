import SwiftUI
import GovKit
import GovKitUI
struct DVLAAccountSummaryView: View {
    @StateObject private var viewModel: DVLAAccountSummaryViewModel

    init(viewModel: DVLAAccountSummaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            viewPicker
                .padding(.bottom, 16)
            switch viewModel.selectedScreen {
            case .drivingLicence:
                DrivingLicenceView(viewModel: viewModel.licenceViewModel)
            case .vehicles:
                VehiclesView(viewModel: viewModel.vehiclesViewModel)
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
    }

    private var viewPicker: some View {
        Picker(
            selection: $viewModel.selectedScreen,
            label: Text(viewModel.widgetTitle)) {
                Text(viewModel.vehiclesTabTitle)
                    .foregroundColor(
                        Color(UIColor.govUK.text.primary)
                    )
                    .tag(DrivingSegment.vehicles)
                Text(viewModel.licenceTabTitle)
                    .foregroundColor(
                        Color(UIColor.govUK.text.primary)
                    )
                    .tag(DrivingSegment.drivingLicence)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 16)
    }
}
