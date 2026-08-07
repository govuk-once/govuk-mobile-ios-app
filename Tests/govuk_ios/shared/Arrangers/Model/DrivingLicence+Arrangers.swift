import Foundation

@testable import govuk_ios

extension DrivingLicence {
    static var arrange: DrivingLicence {
        arrange()
    }

    static func arrange(
        licenceType: String = "Full",
        licenceNumber: String = "DECER607085K99AE",
        driverTitle: String? = "MR",
        driverFirstNames: String? = "KENNETH",
        driverLastName: String = "DECERQUEIRA",
        driverFullAddress: String? = "75 ST JOHN'S STREET\nGATESHEAD\nNE8 2ED",
        tokenValidToDate: Date? = .arrange("01/01/1970"),
        licenceStatus: DrivingLicenceStatus = .valid
    ) -> DrivingLicence {
        .init(
            licenceType: licenceType,
            licenceNumber: licenceNumber,
            driverTitle: driverTitle,
            driverFirstNames: driverFirstNames,
            driverLastName: driverLastName,
            driverFullAddress: driverFullAddress,
            tokenValidToDate: tokenValidToDate,
            licenceStatus: licenceStatus
        )
    }
}
