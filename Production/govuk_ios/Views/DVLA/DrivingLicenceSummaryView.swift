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
                    Text(String.dvla.localized("licenceNumberAccessibilityLabel")) +
                    Text(viewModel.licenceNumber.lowercased())
                        .speechSpellsOutCharacters()
                )
                .background(Color(uiColor: .govUK.fills.surfaceList))
                .roundedBorder(borderColor: .clear)
                .contextMenu {
                    Button {
                        viewModel.copyToClipboardAction?(viewModel.licenceNumber)
                    } label: {
                        Text(String.chat.localized("copyToClipboardTitle"))
                        Image(systemName: "doc.on.doc.fill")
                    }
                }
            addressView
            Divider()
                .overlay(Color(uiColor: .govUK.strokes.listDivider))
                .padding(.horizontal, Self.standardPadding)
                .padding(.top, 8)
            ValidityStatusView(viewModel: viewModel.licenceStatusViewModel)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(viewModel.licenceStatusAccessibilityLabel)
        }
    }

    var headerView: some View {
        HStack(alignment: .center) {
            Text(viewModel.licenceType)
                .accessibilityLabel(viewModel.licenceTypeAccessibilityLabel)
            Spacer()
            Button {
                print("more options tapped - todo")
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.govUK.title1Bold)
                    .frame(
                        width: Self.iconSize,
                        height: Self.iconSize
                    )
                    .foregroundColor(Color(UIColor.govUK.text.link))
            }
            .accessibilityLabel(String.dvla.localized("moreOptionsButtonAccessibilityLabel"))
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
                Text(viewModel.fullName)
                    .font(.govUK.title3Semibold)
                    .multilineTextAlignment(.leading)
                    .padding(.top, Self.standardPadding)
                    .padding(.bottom, 4)
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.address, id: \.self) { addressLine in
                        Text(addressLine)
                            .padding(.top, 4)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(viewModel.addressAccessibilityLabel)
            }
            .padding(.horizontal, Self.standardPadding)
            .padding(.bottom, Self.standardPadding)
        }
    }
}

#Preview {
    let viewModel = DrivingLicenceSummaryViewModel(
        licenceType: "Full licence",
        licenceNumber: "ABC1234567DE",
        fullName: "Mr Joe Bloggs",
        address: [
            "1 Lower Moseley Street",
            "Manchester",
            "M2 3WS"
        ],
        licenceStatusViewModel: ValidityStatusViewModel(
            title: nil,
            status: "Valid until 1 March 2027"
        ),
        licenceTypeAccessibilityLabel: "",
        licenceStatusAccessibilityLabel: "",
        addressAccessibilityLabel: ""
    )
    return DrivingLicenceSummaryView(viewModel: viewModel)
}
