import SwiftUI
import GovKitUI
import GovKit

struct VehicleDetailView: View {
    let viewModel: VehicleDetailViewModel

    private static let standardPadding: CGFloat = 16.0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(viewModel.vehicleMake)
                    .font(.govUK.title1Bold)
                    .multilineTextAlignment(.leading)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.top, Self.standardPadding)
                    .padding(.horizontal, Self.standardPadding)
                Text(viewModel.vehicleModel)
                    .font(.govUK.title3)
                    .multilineTextAlignment(.leading)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.vertical, 8)
                VehicleSpecView(viewModel: viewModel.vehicleSpecViewModel)
                Text(.DVLA.status)
                    .font(.govUK.title2Bold)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, Self.standardPadding)
                    .accessibilityAddTraits(.isHeader)
                ValidityStatusView(viewModel: viewModel.taxStatusViewModel)
                Divider()
                    .overlay(Color(uiColor: .govUK.strokes.listDivider))
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.vertical, 8)
                ValidityStatusView(viewModel: viewModel.motStatusViewModel)
                Text(.DVLA.registeredTo)
                    .font(.govUK.title2Bold)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding([.top, .leading, .trailing], Self.standardPadding)
                    .accessibilityAddTraits(.isHeader)
                addressView
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
                    .padding([.top, .leading, .trailing], Self.standardPadding)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
                Text(viewModel.registrationNumber)
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
                        registrationNumberAccessibilityLabel
                    )
                // todo: set grouped list section background colour
                GroupedList(
                    content: [viewModel.specificationSection]
                )
            }
        }
        .background(Color(uiColor: .govUK.fills.surfaceFullscreen))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("more options tapped")
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel(viewModel.moreOptionsAccessibilityLabel)
            }
        }
        .onAppear {
            viewModel.trackScreen(screen: self)
        }
    }

    @ViewBuilder
    private var addressView: some View {
        if !viewModel.keeperAddress.isEmpty || !viewModel.keeperFullName.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.keeperFullName)
                    .font(.govUK.title3Semibold)
                    .multilineTextAlignment(.leading)
                    .padding(.top, Self.standardPadding)
                    .padding(.bottom, 4)
                if !viewModel.keeperAddress.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.keeperAddress, id: \.self) { addressLine in
                            Text(addressLine)
                                .padding(.top, 4)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(viewModel.addressAccessibilityLabel)
                }
            }
            .padding(.horizontal, Self.standardPadding)
            .padding(.bottom, Self.standardPadding)
        } else {
            Text(.DVLA.unknown)
                .padding(Self.standardPadding)
        }
    }

    private var registrationNumberAccessibilityLabel: Text {
        Text(viewModel.regNumberAccessibilityLabelPrefix)
        + Text(viewModel.registrationNumber.lowercased()).speechSpellsOutCharacters()
    }
}

extension VehicleDetailView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "VehicleDetailsScreen" }
}

#Preview {
    let unstructuredAddress = UnstructuredAddress(
        line1: "1 Blackfriars Road",
        line2: "Salford",
        line3: nil,
        line4: nil,
        line5: nil,
        postcode: "M3 7AB"
    )
    let keeper = VehicleKeeper(
        title: "Mr",
        firstNames: "Kenneth",
        lastName: "Smith",
        address: .init(unstructuredAddress: unstructuredAddress)
    )
    let vehicle = CustomerSummary.Vehicle(
        vehicleId: 1,
        registrationNumber: "CL75 TFA",
        make: "VOLSKWAGEN",
        model: "POLO TDI",
        taxStatus: "",
        taxedUntil: Date(),
        motStatus: "",
        motExpiryDate: Date(),
        dateOfFirstRegistration: Date(),
        colour: "Yellow",
        secondaryColour: "Black",
        fuelType: .hybridElectric,
        exhaustEmissions: .init(co2: 532),
        engineCapacity: 1995,
        keeper: keeper
    )
    let viewModel = VehicleDetailViewModel(
        analyticsService: nil,
        vehicle: vehicle
    )
    VehicleDetailView(viewModel: viewModel)
}
