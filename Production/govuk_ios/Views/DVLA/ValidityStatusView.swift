import SwiftUI
import GovKitUI

///
/// This view conditionally renders UI elements based on the values in `ValidityStatusViewModel`.
///
/// Optional values that are `nil` don't get displayed.
///
struct ValidityStatusView: View {
    private static let iconSize: CGFloat = 36
    private static let standardPadding: CGFloat = 16.0

    let viewModel: ValidityStatusViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if let title = viewModel.title {
                        Text(title)
                            .font(.govUK.title3Semibold)
                            .multilineTextAlignment(.leading)
                            .accessibilityAddTraits(.isHeader)
                    }

                    if let statusInformation = viewModel.statusInformation {
                        StatusRowView(status: statusInformation)
                    }
                }
                Spacer()
                if let iconName = viewModel.iconName {
                    Image(systemName: iconName)
                        .foregroundStyle(Color(
                            uiColor: viewModel.iconTintColour ?? .govUK.Text.primary
                        ))
                        .font(.govUK.title2)
                        .frame(
                            width: Self.iconSize,
                            height: Self.iconSize
                        )
                        .accessibilityHidden(true)
                }
            }
            if let progressViewModel = viewModel.progressViewModel {
                ExpiryProgressView(viewModel: progressViewModel)
            }
            if let buttonViewModel = viewModel.buttonViewModel {
                SwiftUIButton(
                    viewModel.buttonConfiguration ?? .primary,
                    viewModel: buttonViewModel
                )
                .padding(.top, Self.standardPadding)
            }
            if let footer = viewModel.footer {
                Text(footer)
                    .font(.govUK.footnote)
                    .foregroundStyle(Color(uiColor: .govUK.text.secondary))
                    .padding(.top, Self.standardPadding)
                    .padding(.bottom, 8)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
        }
        .padding(Self.standardPadding)
    }
}

#Preview {
    let statusInformation = StatusInformation(
        "Expired 24 April 2026",
    )

    let viewModel = ValidityStatusViewModel(
        title: nil,
        statusInformation: statusInformation,
        iconName: "exclamationmark.triangle.fill",
        footer: "Your licence status may not update immediately when you renew it",
        buttonTitle: "Renew licence",
        buttonAction: { }
    )
    VStack(spacing: 0) {
        Color(uiColor: .govUK.fills.surfaceBackground)
        ValidityStatusView(viewModel: viewModel)
        Color(uiColor: .govUK.fills.surfaceBackground)
    }
}

#Preview("Not Known status") {
    let notKnownVM: ValidityStatusViewModel = {
            let dummyOpenURLAction: (URL) -> Void = { url in print("click url: \(url)") }

            func openURLAction(text: String, url: URL) {
                dummyOpenURLAction(url)
            }

            let statusUnknown: TaxValidityStatus = .unknown
            let url = URL(string: "https://www.gov.uk/contact-the-dvla")!

            let title = String(localized: .DVLA.taxStatusTitle)
            let formattedStatus = String(localized: .DVLA.notFoundContactDVLA)

            return ValidityStatusViewModel(
                title: title,
                status: statusUnknown,
                statusInformation: StatusInformation(
                    formattedStatus,
                    linkAction: { openURLAction(text: title, url: url) }
                ),
            )
        }()

    ValidityStatusView(viewModel: notKnownVM)
}

#Preview("A Known status") {
    let knownVM: ValidityStatusViewModel = {
        let statusUnknown: TaxValidityStatus = .taxed
        let url = URL(string: "https://www.gov.uk/contact-the-dvla")!

        let title = String(localized: .DVLA.taxStatusTitle)
        let formattedStatus = String(localized: .DVLA.noTaxToPay)

        return ValidityStatusViewModel(
            title: title,
            status: statusUnknown,
            statusInformation: StatusInformation(
                formattedStatus
            )
        )
    }()

    ValidityStatusView(viewModel: knownVM)
}

#if DEBUG
#Preview("Both") {
    let knownVM: ValidityStatusViewModel = {
        let statusTaxed: TaxValidityStatus = .taxed
        let url = URL(string: "https://www.gov.uk/contact-the-dvla")!

        let title = String(localized: .DVLA.taxStatusTitle)
        let formattedStatus = String(localized: .DVLA.noTaxToPay)

        return ValidityStatusViewModel(
            title: title,
            status: statusTaxed,
            statusInformation: StatusInformation(
                formattedStatus
            )
        )
    }()

    let notKnownVM: ValidityStatusViewModel = {
            let dummyOpenURLAction: (URL) -> Void = { url in print("click url: \(url)") }

            func openURLAction(text: String, url: URL) {
                dummyOpenURLAction(url)
            }

            let statusUnknown: TaxValidityStatus = .unknown
            let url = URL(string: "https://www.gov.uk/contact-the-dvla")!

            let title = String(localized: .DVLA.taxStatusTitle)
            let formattedStatus = String(localized: .DVLA.notFoundContactDVLA)
            let statusLinkAction = { openURLAction(text: title, url: url) }

            return ValidityStatusViewModel(
                title: title,
                status: statusUnknown,
                statusInformation: StatusInformation(
                    formattedStatus,
                    linkAction: statusLinkAction
                )
            )
        }()

    let motViewModelWithLink =
    ValidityStatusViewModel(
        title: "mot title",
        status: MOTValidityStatus.noResultsReturned,
        statusInformation: StatusInformation(
            "status title",
            linkAction: {}),
        buttonTitle: "buttonTitle",
    )
    let motViewModelWithoutLink =
    ValidityStatusViewModel(
        title: "mot title",
        status: MOTValidityStatus.noResultsReturned,
        statusInformation: StatusInformation("status title")
    )

    ScrollView {
        VStack {
            HStack {
                Spacer()
                Text("known status: .taxed")
                    .padding()
            }
            ValidityStatusView(viewModel: knownVM)
            Divider()

            HStack {
                Spacer()
                Text("unknown status: .unknown")
                    .padding()
            }
            ValidityStatusView(viewModel: notKnownVM)
            Divider()

            HStack {
                Spacer()
                Text("MOTValidity with Link...")
                    .padding()
            }
            ValidityStatusView(viewModel: motViewModelWithLink)
            Divider()

            HStack {
                Spacer()
                Text("MOTValidity without Link...")
                    .padding()
            }
            ValidityStatusView(viewModel: motViewModelWithoutLink)
            Divider()

            HStack {
                Spacer()
                Text("ValidityStatus without Link...")
                    .padding()
            }
            ValidityStatusView(viewModel: motViewModelWithoutLink)
        }
    }
}


#Preview("formattedStatus Lab") {
    let formattedStatus = String(localized: .DVLA.untaxed)
    let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
    let defaultDvlaTaxVehicleUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-tax"
    )!
    let buttonURL =  defaultDvlaTaxVehicleUrl

    let statusInformation = StatusInformation(formattedStatus)

    let viewModel = ValidityStatusViewModel(
        title: String(localized: .DVLA.taxStatusTitle),
        statusInformation: statusInformation,
        iconName: "exclamationmark.triangle.fill",
        footer: String(localized: .DVLA.renewTaxExpiringFooter),
        buttonTitle: buttonTitle,
        buttonAction: { print(buttonURL)}
    )
    ValidityStatusView(viewModel: viewModel)
}

#Preview("formattedStatus 2 Lab") {
    let formattedStatus = String(localized: .DVLA.untaxed)
    let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
    let defaultDvlaTaxVehicleUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-tax"
    )!
    let buttonURL =  defaultDvlaTaxVehicleUrl

    let statusInformation = StatusInformation(formattedStatus)

    let viewModel = ValidityStatusViewModel(
        title: String(localized: .DVLA.taxStatusTitle),
        statusInformation: statusInformation,
        iconName: "exclamationmark.triangle.fill",
        footer: String(localized: .DVLA.renewTaxExpiringFooter),
        buttonTitle: buttonTitle,
        buttonAction: { print(buttonURL)}
    )
    ValidityStatusView(viewModel: viewModel)
}

#Preview("Empty formattedStatus") {
    let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
    let defaultDvlaTaxVehicleUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-tax"
    )!
    let buttonURL =  defaultDvlaTaxVehicleUrl
    let formattedStatus = String(localized: .DVLA.untaxed)
    let statusInformation = StatusInformation(formattedStatus)

    let viewModel = ValidityStatusViewModel(
        title: String(localized: .DVLA.taxStatusTitle),
        statusInformation: statusInformation,
        iconName: "exclamationmark.triangle.fill",
        footer: String(localized: .DVLA.renewTaxExpiringFooter),
        buttonTitle: buttonTitle,
        buttonAction: { print(buttonURL)}
    )
    ValidityStatusView(viewModel: viewModel)
}
#endif // DEBUG
