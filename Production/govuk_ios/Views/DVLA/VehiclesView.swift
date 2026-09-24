import SwiftUI
import GovKit
import GovKitUI

struct VehiclesView: View {
    @StateObject private var viewModel: VehiclesViewModel

    private static let iconSize: CGFloat = 36.0

    init(viewModel: VehiclesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded(let vehicleViewModels):
                makeVehiclesView(for: vehicleViewModels)
            case .error(let errorViewModel):
                makeErrorView(for: errorViewModel)
            }
        }
        .task {
            await viewModel.viewDidAppear()
        }
    }

    private var loadingView: some View {
        ZStack {
            ProgressView()
                .accessibilityLabel(viewModel.loadingAccessibilityLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }

    private func makeVehiclesView(for vehicleViewModels: [VehicleSummaryViewModel]) -> some View {
        LazyVStack(spacing: 16) {
            ForEach(vehicleViewModels) {
                VehicleSummaryView(viewModel: $0)
            }
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            addVehiclesCard(large: vehicleViewModels.isEmpty)
        }
        .padding(.horizontal, 16)
    }

    private func addVehiclesCard(large: Bool) -> some View {
        Button {
            viewModel.addNewVehiclesAction(largeCard: large)
        } label: {
            if large {
                addVehiclesLargeCard
            } else {
                addVehiclesSmallCard
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.isLink)
        .accessibilityHint(String.common.localized("openWebLinkHint"))
    }

    private var addVehiclesLargeCard: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "plus.circle")
                .font(.govUK.largeTitle.weight(.light))
                .foregroundColor(
                    Color(.govUK.text.iconTertiary)
                )
                .font(.title)
                .accessibilityHidden(true)
            Text(String.dvla.localized("dvlaAddNewVehiclesTitle"))
                .multilineTextAlignment(.center)
                .font(.govUK.body)
                .foregroundColor(
                    Color(.govUK.text.primary))
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 52)
        .background(Color(.govUK.fills.surfaceList))
        .roundedBorder(borderColor: .clear)
    }

    private var addVehiclesSmallCard: some View {
        HStack {
            Text(String.dvla.localized("dvlaAddNewVehicleTitle"))
                .font(.govUK.body)
                .foregroundStyle(Color(.govUK.text.primary))
                .multilineTextAlignment(.leading)
            Spacer()
            Image(systemName: "plus.circle")
                .font(.govUK.title3Semibold)
                .frame(minWidth: Self.iconSize, minHeight: Self.iconSize)
                .foregroundStyle(Color(.govUK.text.iconTertiary))
                .accessibilityHidden(true)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.govUK.fills.surfaceCardDefault))
        .roundedBorder(borderColor: .clear)
    }

    private func makeErrorView(for errorViewModel: InlineActionErrorViewModel) -> some View {
        InlineActionErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Multiple vehicles") {
    @Previewable @StateObject var viewModel: VehiclesViewModel = {
        let dvlaService = MockDVLAService()
        dvlaService._stubbedCustomerVehiclesResult = .success(
            .arrange(
                customerVehicles: [
                    .arrange(
                        vehicleId: 1,
                        registrationNumber: "AB71 CDE",
                        make: "MITSUBISHI",
                        model: "MIRAGE",
                        taxStatus: .taxed,
                        taxedUntil: .arrange("15/09/2030"),
                        motStatus: "Valid",
                        motExpiryDate: .arrange("15/09/2030")
                    ),
                    .arrange(
                        vehicleId: 2,
                        registrationNumber: "XY19 ZAB",
                        make: "LAND ROVER",
                        model: "RANGE ROVER SPORT",
                        taxStatus: .sorn,
                        motStatus: "Not valid",
                        motExpiryDate: .arrange("01/03/2024"),
                        sornStart: .arrange("01/01/2025")
                    ),
                    .arrange(
                        vehicleId: 3,
                        registrationNumber: "MN65 PQR",
                        make: "VOLKSWAGEN",
                        model: "GOLF",
                        taxStatus: .untaxed,
                        motStatus: "Valid",
                        motExpiryDate: .arrange("20/11/2030")
                    )
                ]
            )
        )

        return VehiclesViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            detailAction: { _ in
                /* no-op */
            },
            openURLAction: { _ in
                /* no-op */
            }
        )
    }()

    NavigationStack {
        ScrollView {
            VehiclesView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Vehicles")
    }
}

@available(iOS 17.0, *)
#Preview("Single vehicle") {
    @Previewable @StateObject var viewModel: VehiclesViewModel = {
        let dvlaService = MockDVLAService()
        dvlaService._stubbedCustomerVehiclesResult = .success(
            .arrange(
                customerVehicles: [
                    .arrange(
                        vehicleId: 1,
                        registrationNumber: "FG23 HIJ",
                        make: "TESLA",
                        model: "MODEL 3",
                        taxStatus: .taxed,
                        taxedUntil: .arrange("01/04/2031"),
                        motStatus: "Valid",
                        motExpiryDate: .arrange("01/04/2031")
                    )
                ]
            )
        )

        return VehiclesViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            detailAction: { _ in
                /* no-op */
            },
            openURLAction: { _ in
                /* no-op */
            }
        )
    }()

    NavigationStack {
        ScrollView {
            VehiclesView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Vehicles")
    }
}

@available(iOS 17.0, *)
#Preview("No vehicles") {
    @Previewable @StateObject var viewModel: VehiclesViewModel = {
        let dvlaService = MockDVLAService()
        dvlaService._stubbedCustomerVehiclesResult = .success(
            .arrange(customerVehicles: [])
        )

        return VehiclesViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            detailAction: { _ in
                /* no-op */
            },
            openURLAction: { _ in
                /* no-op */
            }
        )
    }()

    NavigationStack {
        ScrollView {
            VehiclesView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Vehicles")
    }
}

@available(iOS 17.0, *)
#Preview("Error") {
    @Previewable @StateObject var viewModel: VehiclesViewModel = {
        let dvlaService = MockDVLAService()
        dvlaService._stubbedCustomerVehiclesResult = .failure(.apiUnavailable)

        return VehiclesViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            detailAction: { _ in
                /* no-op */
            },
            openURLAction: { _ in
                /* no-op */
            }
        )
    }()

    NavigationStack {
        ScrollView {
            VehiclesView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Vehicles")
    }
}
#endif // DEBUG
