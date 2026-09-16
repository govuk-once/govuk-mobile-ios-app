#if DEBUG

import SwiftUI
import GovKitUI

#Preview("No title | With a button") {
    let statusInformation = StatusInformation(
        "Expired 24 April 2026",
    )

    let viewModel = ValidityStatusViewModel(
        title: nil,
        statusInformation: statusInformation,
        iconName: "exclamationmark.triangle.fill",
        footer: "Your licence status may not update immediately when you renew it",
        buttonTitle: "Renew licence",
        buttonAction: { print("button tapped") }
    )
    VStack(spacing: 0) {
        Color(uiColor: .govUK.fills.surfaceBackground)
        ValidityStatusView(viewModel: viewModel)
        Color(uiColor: .govUK.fills.surfaceBackground)
    }
}

#Preview("Tax - Not Known status") {
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

#Preview("Tax - Taxed status") {
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

#Preview("ValidityStatusViews with and without links") {
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
            linkAction: {
                // placeholder closure for Preview
            }),
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

#Preview("Empty StatusInformation") {
    let buttonTitle = String(localized: .DVLA.renewTaxButtonTitle)
    let defaultDvlaTaxVehicleUrl: URL = URL(
        string: "https://www.gov.uk/vehicle-tax"
    )!
    let buttonURL =  defaultDvlaTaxVehicleUrl
    let statusInformation = StatusInformation("")

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
