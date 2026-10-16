import SwiftUI
import GovKit
import GovKitUI

struct DVLAAccountSummaryView: View {
    @StateObject private var viewModel: DVLAAccountSummaryViewModel

    init(viewModel: DVLAAccountSummaryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            viewPicker
                .padding(.bottom, 16)
            switch viewModel.selectedScreen {
            case .drivingLicence:
                DrivingLicenceView(viewModel: viewModel.licenceViewModel)
            case .vehicles:
                VehiclesView(viewModel: viewModel.vehiclesViewModel)
                VehicleCheckSectionView(viewModel: viewModel.vehicleCheckSectionViewModel)
                     .padding(.top, 24)
                    .padding([.horizontal], 16)
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

#if DEBUG
@available(iOS 17.0, *)
#Preview("Vehicles tab") {
    @Previewable @StateObject var viewModel: DVLAAccountSummaryViewModel = {
        let dvlaService = MockDVLAService()
        let customerVehicles = Array(CustomerVehicles.Vehicle.PreviewsData.collection[0..<2])
        dvlaService._stubbedCustomerVehiclesResult = .success(
            .arrange(
                customerVehicles: customerVehicles
                    )
        )
        dvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(
                tokenValidToDate: .arrange("15/06/2035"),
                licenceStatus: .valid
            )
        )

        let analyticsService = MockAnalyticsService()
        let configService = MockAppConfigService()

        let vehiclesVM = VehiclesViewModel(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            detailAction: { _ in
                /* no-op */
            },
            openURLAction: { _ in
                /* no-op */
            }
        )
        let licenceVM = DrivingLicenceViewModel(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            openURLAction: { _ in
                /* no-op */
            }
        )

        let vehicleCheckSectionVM = VehicleCheckSectionViewModel(action: { _ in
            /* no-op */
        })

        return DVLAAccountSummaryViewModel(
            vehiclesViewModel: vehiclesVM,
            licenceViewModel: licenceVM,
            vehicleCheckSectionViewModel: vehicleCheckSectionVM
        )
    }()

    NavigationStack {
        ScrollView {
            DVLAAccountSummaryView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Driving")
    }
}

@available(iOS 17.0, *)
#Preview("Licence tab") {
    @Previewable @StateObject var viewModel: DVLAAccountSummaryViewModel = {
        let dvlaService = MockDVLAService()
        let customerVehicles = [CustomerVehicles.Vehicle.PreviewsData.collection[0]]

        dvlaService._stubbedCustomerVehiclesResult = .success(
            .arrange(customerVehicles: customerVehicles)
        )
        dvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(
                licenceNumber: "JONES810200HJ9NK",
                driverTitle: "MR",
                driverFirstNames: "HYWEL",
                driverLastName: "JONES",
                driverFullAddress: "42 HEOL FAWR\nSWANSEA\nSA1 5DF",
                tokenValidToDate: .arrange("01/03/2023"),
                licenceStatus: .expired
            )
        )

        let analyticsService = MockAnalyticsService()
        let configService = MockAppConfigService()

        let vehiclesVM = VehiclesViewModel(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            detailAction: { _ in
                /* no-op */
            },
            openURLAction: { _ in
                /* no-op */
            }
        )
        let licenceVM = DrivingLicenceViewModel(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            openURLAction: { _ in
                /* no-op */
            }
        )

        let vehicleCheckSectionVM = VehicleCheckSectionViewModel(action: { _ in
            /* no-op */
        })

        let viewModel = DVLAAccountSummaryViewModel(
            vehiclesViewModel: vehiclesVM,
            licenceViewModel: licenceVM,
            vehicleCheckSectionViewModel: vehicleCheckSectionVM
        )
        viewModel.selectedScreen = .drivingLicence
        return viewModel
    }()

    NavigationStack {
        ScrollView {
            DVLAAccountSummaryView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Driving")
    }
}
#endif // DEBUG
