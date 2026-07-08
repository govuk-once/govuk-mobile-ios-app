import SwiftUI
import GovKitUI

struct DrivingLicenceSummaryView: View {
    let viewModel: DrivingLicenceSummaryViewModel
    private static let standardPadding: CGFloat = 16.0
    private static let iconSize: CGFloat = 36.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            Text(viewModel.licenceNumber)
                .font(.govUK.title1Bold)
                .multilineTextAlignment(.leading)
                .padding(.vertical, Self.standardPadding)
                .padding(.horizontal, Self.standardPadding)
                .accessibilityLabel(
                    Text(viewModel.licenceNumberAccessibilityLabelPrefix) +
                    Text(viewModel.licenceNumber.lowercased())
                        .speechSpellsOutCharacters()
                )
                .background(Color(uiColor: .govUK.fills.surfaceList))
                .roundedBorder(borderColor: .clear)
            addressView
            Divider()
                .overlay(Color(uiColor: .govUK.strokes.listDivider))
                .padding(.horizontal, Self.standardPadding)
                .padding(.top, 8)
            ValidityStatusView(viewModel: viewModel.licenceStatusViewModel)
        }
    }

    var headerView: some View {
        HStack(alignment: .center) {
            Text(viewModel.licenceType)
                .accessibilityLabel(viewModel.licenceTypeAccessibilityLabel)
            Spacer()
            Menu {
                Button {
                    viewModel.copyToClipbaord()
                } label: {
                    Text(viewModel.copyLicenceButtonTitle)
                }
                Button {
                    viewModel.openUrl(options: .changeAddress)
                } label: {
                    Text(viewModel.changeAddressMenuTitle)
                }
                Button {
                    viewModel.openUrl(options: .changeNameAndGender)
                } label: {
                    Text(viewModel.changeNameAndGender)
                }
                Button {
                    viewModel.openUrl(options: .replaceLicence)
                } label: {
                    Text(viewModel.replaceLicenceMenuTitle)
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.govUK.title1Bold)
                    .frame(
                        width: Self.iconSize,
                        height: Self.iconSize
                    )
                    .foregroundColor(Color(UIColor.govUK.text.link))
            }
            .accessibilityLabel(viewModel.moreOptionsButtonAccessibilityLabel)
        }
        .padding(.top, Self.standardPadding)
        .padding(.bottom, 8)
        .padding(.horizontal, Self.standardPadding)
    }

    @ViewBuilder
    var addressView: some View {
        if !viewModel.address.isEmpty || !viewModel.fullName.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                    .overlay(Color(uiColor: .govUK.strokes.listDivider))
                    .padding(.bottom, 8)
                Text(viewModel.fullName)
                    .font(.govUK.bodySemibold)
                    .multilineTextAlignment(.leading)
                    .padding(.top, Self.standardPadding)
                    .padding(.bottom, 4)
                    .accessibilityLabel(viewModel.fullNameAccessibilityLabel)
                if !viewModel.address.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.address, id: \.self) { addressLine in
                            Text(addressLine)
                                .font(.govUK.body)
                                .padding(.top, 4)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(viewModel.addressAccessibilityLabel)
                }
            }
            .padding(.horizontal, Self.standardPadding)
            .padding(.bottom, Self.standardPadding)
        }
    }
}
