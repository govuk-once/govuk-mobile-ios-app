import SwiftUI
import GovKit

struct DVLAAccountWidgetView: View {
    @StateObject private var viewModel: DVLAAccountWidgetViewModel

    init(viewModel: DVLAAccountWidgetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            accountContentView
            vehicleCheckView
        }
        .task {
            await viewModel.viewDidAppear()
        }
    }

    @ViewBuilder
    private var accountContentView: some View {
        switch viewModel.viewState {
        case .loading:
            loadingView
        case .linked(let accountSummaryViewModel):
            makeAccountSummaryView(for: accountSummaryViewModel)
        case .unlinked(let linkCardViewModel):
            makeLinkCardView(for: linkCardViewModel)
        case .error(let errorViewModel):
            makeErrorView(for: errorViewModel)
        }
    }

    @ViewBuilder
    private var vehicleCheckView: some View {
        switch viewModel.viewState {
        case .loading, .unlinked, .error:
            VehicleCheckSectionView(viewModel: viewModel.vehicleCheckSectionViewModel)
                .padding([.horizontal, .top], 16)
        case .linked:
            EmptyView()
        }
    }

    private func makeErrorView(for errorViewModel: InlineActionErrorViewModel) -> some View {
        InlineActionErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }

    private func makeAccountSummaryView(for viewModel: DVLAAccountSummaryViewModel) -> some View {
        DVLAAccountSummaryView(viewModel: viewModel)
    }

    private func makeLinkCardView(for viewModel: ServiceAccountLinkCardViewModel) -> some View {
        ServiceAccountLinkCardView(viewModel: viewModel)
            .padding(.horizontal, 16)
    }

    private var loadingView: some View {
        ZStack {
            ProgressView()
                .accessibilityLabel(String.topics.localized("loading"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("DVLA - linked account") {
    @Previewable @StateObject var viewModel: DVLAAccountWidgetViewModel = {
        let userService = MockUserService()
        userService._stubbedLinkedAccounts = [.dvla]

        let dvlaService = MockDVLAService()
        dvlaService._stubbedCustomerVehiclesResult = .success(
            .arrange(
                customerVehicles: [
                    .arrange(
                        vehicleId: 1,
                        registrationNumber: "AB71 CDE",
                        make: "MITSUBISHI",
                        model: "MIRAGE",
                        taxedUntil: .arrange("12/12/2030"),
                        motStatus: "Valid",
                        motExpiryDate: .arrange("12/12/2030")
                    ),
                    .arrange(
                        vehicleId: 2,
                        registrationNumber: "XY19 ZAB",
                        make: "LAND ROVER",
                        model: "RANGE ROVER SPORT",
                        taxStatus: .sorn,
                        motStatus: "Not valid",
                        motExpiryDate: .arrange("12/12/2030"),
                        sornStart: .arrange("01/01/2025")
                    )
                ]
            )
        )

        dvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(
                tokenValidToDate: .arrange("12/12/2030"),
                licenceStatus: .valid
            )
        )

        return DVLAAccountWidgetViewModel(
            analyticsService: MockAnalyticsService(),
            userService: userService,
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            notificationCenter: NotificationCenter(),
            actions: .init(
                linkAction: {
                    /* no-op */
                },
                vehicleDetailAction: { _ in
                    /* no-op */
                },
                openURLAction: { _ in
                    /* no-op */
                }
            )
        )
    }()

    NavigationStack {
        ScrollView {
            DVLAAccountWidgetView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Driving")
    }
}
#endif // DEBUG
