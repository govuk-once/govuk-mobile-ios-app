import Foundation

@testable import govuk_ios

extension DrivingLicence {
    static var arrange: DrivingLicence {
        arrange()
    }

    static func arrange(
        licenceNumber: String = "DECER607085K99AE",
        licenceType: String = "Full",
        licenceStatus: String = "Valid",
        validFrom: Date = .init(timeIntervalSince1970: 0),
        validTo: Date = .init(timeIntervalSince1970: 30)
    ) -> DrivingLicence {
        .init(
            driver: Driver(
                drivingLicenceNumber: licenceNumber
            ),
            licence: Licence(
                type: licenceType,
                status: licenceStatus
            ),
            token: DrivingLicenceToken(
                validFromDate: validFrom,
                validToDate: validTo
            )
        )
    }
}
