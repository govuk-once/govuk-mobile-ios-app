import SwiftUI
import GovKitUI

struct VehicleSummaryView: View {
    let viewModel: VehicleSummaryViewModel

    private static let standardPadding: CGFloat = 16.0
    private static let iconSize: CGFloat = 36.0

    var body: some View {
        VStack(spacing: 0) {
            headerView
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
            ValidityStatusView(viewModel: viewModel.taxStatusViewModel)
            Divider()
                .overlay(Color(uiColor: .govUK.strokes.listDivider))
                .padding(.horizontal, Self.standardPadding)
                .padding(.vertical, 8)
            ValidityStatusView(viewModel: viewModel.motStatusViewModel)
            Divider()
                .overlay(Color(uiColor: .govUK.strokes.listDivider))
                .padding(.top, 8)
            detailsButton
        }
    }

    var headerView: some View {
        HStack {
            Text(viewModel.registrationNumber)
                .font(.govUK.vehicleRegistrationMarkBody)
                .foregroundStyle(Color.black)
                .padding([.top, .leading, .trailing], 7)
                .padding(.bottom, 4)
                .background(Color(uiColor: GOVUKColors.Fills.registrationPlate))
                .roundedBorder(
                    cornerRadius: 7,
                    borderColor: .black
                )
                .accessibilityLabel(registrationNumberAccessibilityLabel)
            Spacer()
            menuView
        }
        .padding(.top, Self.standardPadding)
        .padding(.bottom, 8)
        .padding(.horizontal, Self.standardPadding)
    }

    private var menuView: some View {
        Menu {
            Button(
                action: { viewModel.openSornRulesURL() },
                label: {
                    Text(.DVLA.vehicleMenuSornRulesTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
            Button(
                action: { viewModel.openSoldVehicleURL() },
                label: {
                    Text(.DVLA.vehicleMenuSoldVehicleTitle)
                        .accessibilityLabel(.DVLA.vehicleMenuSoldVehicleAccessibilityLabelTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
            Button(
                action: { viewModel.openMakeSornURL() },
                label: {
                    Text(.DVLA.vehicleMenuMakeSornTitle)
                        .accessibilityLabel(.DVLA.vehicleMenuMakeSornAccessibilityLabelTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
            Button(
                action: { viewModel.openGetLogbookURL() },
                label: {
                    Text(.DVLA.vehicleMenuGetLogbookTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
            Button(
                action: { viewModel.openChangeLogbookAddressURL() },
                label: {
                    Text(.DVLA.vehicleMenuChangeLogbookAddressTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
            Button(
                action: { viewModel.openCancelTaxURL() },
                label: {
                    Text(.DVLA.vehicleMenuCancelTaxTitle)
                        .accessibilityLabel(.DVLA.vehicleMenuCancelTaxAccessibilityLabelTitle)
                        .accessibilityHint(String.common.localized("openWebLinkHint"))
                }
            )
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.govUK.title1Bold)
                .frame(
                    minWidth: Self.iconSize,
                    minHeight: Self.iconSize
                )
                .foregroundColor(Color(UIColor.govUK.text.link))
        }
        .accessibilityLabel(String.dvla.localized("moreOptionsButtonAccessibilityLabel"))
    }

    private var detailsButton: some View {
        Button {
            viewModel.detailAction()
        } label: {
            HStack {
                Text(String.dvla.localized("detailsButtonTitle"))
                    .font(Font.govUK.body)
                    .foregroundStyle(Color(uiColor: .govUK.text.primary))
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(UIColor.govUK.text.link))
                    .font(Font.govUK.bodySemibold)
                    .frame(width: Self.iconSize)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, Self.standardPadding)
        }
    }

    private var registrationNumberAccessibilityLabel: Text {
        Text(viewModel.regNumberAccessibilityLabelPrefix)
        + Text(viewModel.registrationNumber.lowercased()).speechSpellsOutCharacters()
    }
}
