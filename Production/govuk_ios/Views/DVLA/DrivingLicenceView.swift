import SwiftUI
import GovKit
import GovKitUI

struct DrivingLicenceView: View {
    @StateObject private var viewModel: DrivingLicenceViewModel

    init(viewModel: DrivingLicenceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded(let licenceSummaryViewModel, let drivingRecordViewModel):
                VStack(spacing: 24) {
                    DrivingLicenceSummaryView(viewModel: licenceSummaryViewModel)
                        .background(Color(UIColor.govUK.fills.surfaceList))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    DrivingRecordView(viewModel: drivingRecordViewModel)
                }
                .padding(.horizontal, 16)
            case .notice(let noticeViewModel):
                makeNoticeView(for: noticeViewModel)
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
                .accessibilityLabel(String.dvla.localized("loadingLicenceAccessibilityLabel"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceList))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }

    private func makeNoticeView(
        for noticeViewModel: DrivingLicenceNoticeViewModel
    ) -> some View {
        DrivingLicenceNoticeView(viewModel: noticeViewModel)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }

    private func makeErrorView(for errorViewModel: InlineActionErrorViewModel) -> some View {
        InlineActionErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(UIColor.govUK.fills.surfaceList))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Valid licence") {
    @Previewable @StateObject var viewModel: DrivingLicenceViewModel = {
        let dvlaService = MockDVLAService()
        dvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(
                licenceType: "Full",
                licenceNumber: "MORGA753116SM9IJ",
                driverTitle: "MRS",
                driverFirstNames: "SARAH",
                driverLastName: "MORGAN",
                driverFullAddress: "10 KING'S ROAD\nCARDIFF\nCF10 3AB",
                tokenValidToDate: .arrange("15/06/2035"),
                licenceStatus: .valid
            )
        )

        return DrivingLicenceViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
    }()

    NavigationStack {
        ScrollView {
            DrivingLicenceView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Driving licence")
    }
}

@available(iOS 17.0, *)
#Preview("Expired licence") {
    @Previewable @StateObject var viewModel: DrivingLicenceViewModel = {
        let dvlaService = MockDVLAService()
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

        return DrivingLicenceViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
    }()

    NavigationStack {
        ScrollView {
            DrivingLicenceView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Driving licence")
    }
}

@available(iOS 17.0, *)
#Preview("Revoked licence") {
    @Previewable @StateObject var viewModel: DrivingLicenceViewModel = {
        let dvlaService = MockDVLAService()
        dvlaService._stubbedFetchDrivingLicenceResult = .success(
            .arrange(licenceStatus: .revoked)
        )

        return DrivingLicenceViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
    }()

    NavigationStack {
        ScrollView {
            DrivingLicenceView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Driving licence")
    }
}

@available(iOS 17.0, *)
#Preview("Error") {
    @Previewable @StateObject var viewModel: DrivingLicenceViewModel = {
        let dvlaService = MockDVLAService()
        dvlaService._stubbedFetchDrivingLicenceResult = .failure(.apiUnavailable)

        return DrivingLicenceViewModel(
            analyticsService: MockAnalyticsService(),
            dvlaService: dvlaService,
            configService: MockAppConfigService(),
            openURLAction: { _ in }
        )
    }()

    NavigationStack {
        ScrollView {
            DrivingLicenceView(viewModel: viewModel)
                .padding(.vertical)
        }
        .background(Color(uiColor: .govUK.fills.surfaceBackground))
        .navigationTitle("Driving licence")
    }
}
#endif // DEBUG
