import Foundation

@testable import govuk_ios

extension DvlaURLs {
    static var arrange: DvlaURLs {
        .arrange()
    }

    static func arrange(
        addVehicle: String = "https://dvla.gov.uk/addVehicle",
        renewLicence: String = "https://dvla.gov.uk/renewLicence"
    ) -> DvlaURLs {
        DvlaURLs(
            addVehicle: URL(string: addVehicle)!,
            renewLicence: URL(string: renewLicence)!
        )
    }
}
