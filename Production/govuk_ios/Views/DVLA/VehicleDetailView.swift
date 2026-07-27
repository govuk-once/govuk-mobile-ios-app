import SwiftUI
import GovKitUI
import GovKit

struct VehicleDetailView: View {
    @ObservedObject var viewModel: VehicleDetailViewModel

    private static let standardPadding: CGFloat = 16.0

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded(let viewVehicleDetails):
                makeVehicleDetailsView(viewVehicleDetails)
            case .error(let errorViewModel):
                makeErrorView(for: errorViewModel)
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(UIColor.govUK.fills.surfaceFullscreen))
        .task {
            await viewModel.viewDidAppear()
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }

    private var loadingView: some View {
        ZStack {
            ProgressView()
                .accessibilityLabel(viewModel.loadingAccessibilityLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 86)
        }
        .background(Color(UIColor.govUK.fills.surfaceFullscreen))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
    }


    @ViewBuilder
    // swiftlint:disable:next function_body_length
    private func makeVehicleDetailsView(
        _ viewVehicleDetails: ViewVehicleDetails
    ) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(viewVehicleDetails.make)
                    .font(.govUK.title1Bold)
                    .multilineTextAlignment(.leading)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.top, Self.standardPadding)
                    .padding(.horizontal, Self.standardPadding)
                Text(viewVehicleDetails.model)
                    .font(.govUK.title3)
                    .multilineTextAlignment(.leading)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.vertical, 8)
                VehicleSpecView(viewModel: viewVehicleDetails.vehicleSpecViewModel)
                Text(.DVLA.status)
                    .font(.govUK.title2Bold)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.top, 16)
                    .accessibilityAddTraits(.isHeader)
                TaxValidityStatusView(viewModel: viewVehicleDetails.taxStatusViewModel)
                Divider()
                    .overlay(Color(uiColor: .govUK.strokes.listDivider))
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.vertical, 8)
                MotValidityStatusView(viewModel: viewVehicleDetails.motStatusViewModel)
                Text(.DVLA.registeredTo)
                    .font(.govUK.title2Bold)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.top, 32)
                    .padding([.horizontal], Self.standardPadding)
                    .accessibilityAddTraits(.isHeader)
                addressView(viewVehicleDetails: viewVehicleDetails)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                Text(.DVLA.specification)
                    .font(.govUK.title2Bold)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.top, 32)
                    .padding([.horizontal], Self.standardPadding)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
                Text(viewVehicleDetails.registrationNumber)
                    .font(.govUK.vehicleRegistrationMarkExtraLarge)
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .background(Color(uiColor: GOVUKColors.Fills.registrationPlate))
                    .roundedBorder(
                        cornerRadius: 16,
                        borderColor: .black
                    )
                    .padding(8)
                    .accessibilityLabel(
                        registrationNumberAccessibilityLabel(viewVehicleDetails: viewVehicleDetails)
                    )
                GroupedList(
                    content: [viewVehicleDetails.specificationSection],
                    sectionBackgroundColor: .govUK.fills.surfaceFullscreen
                )
            }
        }
    }

    @ViewBuilder
    private func addressView(
        viewVehicleDetails: ViewVehicleDetails
    ) -> some View {
        if !viewVehicleDetails.keeperAddress.isEmpty || !viewVehicleDetails.keeperFullName.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewVehicleDetails.keeperFullName)
                    .font(.govUK.bodySemibold)
                    .multilineTextAlignment(.leading)
                    .padding(.top, Self.standardPadding)
                    .padding(.bottom, 4)
                Text(viewVehicleDetails.keeperAddress)
                    .font(.govUK.body)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
                    .accessibilityLabel(viewVehicleDetails.addressAccessibilityLabel)
            }
            .padding(.horizontal, Self.standardPadding)
            .padding(.bottom, Self.standardPadding)
        } else {
            Text(.DVLA.unknown)
                .padding(Self.standardPadding)
        }
    }

    private func registrationNumberAccessibilityLabel(
        viewVehicleDetails: ViewVehicleDetails
    ) -> Text {
        Text(viewVehicleDetails.regNumberAccessibilityLabelPrefix)
        + Text(viewVehicleDetails.registrationNumber.lowercased()).speechSpellsOutCharacters()
    }

    private func makeErrorView(for errorViewModel: InlineActionErrorViewModel) -> some View {
        InlineActionErrorView(viewModel: errorViewModel)
            .frame(maxWidth: .infinity, minHeight: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
    }
}

extension VehicleDetailView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "VehicleDetailsScreen" }
}
