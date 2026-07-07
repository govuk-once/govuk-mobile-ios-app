import Foundation

@testable import govuk_ios

extension DvlaURLs {
    static var arrange: DvlaURLs {
        .arrange()
    }

    static func arrange(
        addVehicle: String = "https://dvla.gov.uk/addVehicle",
        renewLicence: String = "https://dvla.gov.uk/renewLicence",
        soldVehicle: String = "https://www.gov.uk/sold-bought-vehicle",
        sornRules: String = "https://www.gov.uk/sorn-statutory-off-road-notification",
        makeSorn: String = "https://www.gov.uk/make-a-sorn",
        getLogbook: String = "https://www.gov.uk/vehicle-log-book",
        changeLogbookAddress: String = "https://www.gov.uk/change-address-v5c",
        cancelTax: String = "https://www.gov.uk/vehicle-tax-refund",
        driverDetails: String = "https://www.gov.uk/driver-details",
        account: String = "https://www.gov.uk/account"
    ) -> DvlaURLs {
        DvlaURLs(
            addVehicle: URL(string: addVehicle)!,
            renewLicence: URL(string: renewLicence)!,
            soldVehicle: URL(string: soldVehicle)!,
            sornRules: URL(string: sornRules)!,
            makeSorn: URL(string: makeSorn)!,
            getLogbook: URL(string: getLogbook)!,
            changeLogbookAddress: URL(string: changeLogbookAddress)!,
            cancelTax: URL(string: cancelTax)!,
            driverDetails: URL(string: driverDetails)!,
            account: URL(string: account)!
        )
    }
}
