import SwiftUI
import GovKit
import GovKitUI

struct VehicleCheckResultView: View {
    let viewModel: VehicleCheckResultViewModel
    private static let standardPadding: CGFloat = 16.0

    private var registrationNumberAccessibilityLabel: Text {
        Text(viewModel.regNumberAccessibilityLabelPrefix)
        + Text(viewModel.registrationNumber.lowercased()).speechSpellsOutCharacters()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(viewModel.make)
                    .font(.govUK.title1Bold)
                    .multilineTextAlignment(.leading)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.top, Self.standardPadding)
                    .padding(.horizontal, Self.standardPadding)
                VehicleSpecView(viewModel: viewModel.vehicleSpecViewModel)
                Text(.DVLA.status)
                    .font(.govUK.title2Bold)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.top, 16)
                    .accessibilityAddTraits(.isHeader)
                TaxValidityStatusView(viewModel: viewModel.taxStatusViewModel)
                Divider()
                    .overlay(Color(uiColor: .govUK.strokes.listDivider))
                    .padding(.horizontal, Self.standardPadding)
                    .padding(.vertical, 8)
                ValidityStatusView(viewModel: viewModel.motStatusViewModel)
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
                GroupedList(
                    content: [viewModel.specificationSection],
                    sectionBackgroundColor: .clear
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .tint(Color(uiColor: .govUK.text.link))
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                menuView
                Button {
                    viewModel.search()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .tint(Color(uiColor: .govUK.text.link))
                }
            }
        }
    }

    private var menuView: some View {
        Menu {
            VStack {
                ForEach(viewModel.menuItems, id: \.id) { item in
                    Button(
                        action: { item.openURLAction(item.title) },
                        label: {
                            Text(item.title)
                                .accessibilityLabel(item.accessibilityLabel ?? item.title)
                                .accessibilityHint(String.common.localized("openWebLinkHint"))
                        }
                    )
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .tint(Color(uiColor: .govUK.text.link))
        }
    }
}

extension VehicleCheckResultView: TrackableScreen {
    var trackingTitle: String? { trackingName }
    var trackingName: String { "VehicleDetailsScreenSearchResult" }
}
